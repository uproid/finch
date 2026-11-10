import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:finch/finch_app.dart';
import 'package:finch/finch_route.dart';
import 'package:test/test.dart';

/// Security regression tests for audit finding F-06 (SECURITY_AUDIT_FA.md):
/// request bodies are buffered in memory, so they must be capped by
/// `FinchConfigs.maxBodySize` and answered with `413 Payload Too Large`.
const _limit = 100 * 1024;

void main() async {
  final server = FinchApp(
    configs: FinchConfigs(
      port: 0,
      noStop: false,
      maxBodySize: _limit,
      dbConfig: FinchDBConfig(enable: false),
    ),
  );

  final received = <String>[];
  final socketManager = SocketManager(
    server,
    event: SocketEvent(onMessage: (client, data) {
      received.add((data['text'] ?? '').toString());
    }),
  );

  server.addRouting(() async => [
        FinchRoute(
          path: '/ws',
          index: () async {
            await socketManager.requestHandle(Context.rq);
            return Context.rq.renderSocket();
          },
        ),
        FinchRoute(
          path: '/upload',
          methods: Methods.ONLY_POST,
          index: () => Context.rq.renderData(data: {
            'a': Context.rq.data('a').length,
            'files': (Context.rq.getFile('f') as List?)?.length ?? 0,
          }),
        ),
        FinchRoute(
          path: '/api/upload',
          methods: Methods.ONLY_POST,
          index: () => Context.rq.renderString(text: 'OK'),
        ),
      ]);

  final httpServer = await server.start([], false);
  final client = HttpClient();

  tearDownAll(() async {
    client.close(force: true);
    await httpServer.close(force: true);
  });

  /// Streams [total] bytes of body (between [prefix] and [suffix]) without
  /// holding them all in memory. With [chunked] no Content-Length is sent.
  /// Returns the status code, or -1 if the server cut the connection first.
  Future<({int status, String body})> post({
    required ContentType contentType,
    required int total,
    List<int> prefix = const [],
    List<int> suffix = const [],
    bool chunked = false,
    String path = '/upload',
  }) async {
    try {
      final req = await client.post('localhost', httpServer.port, path);
      req.headers.contentType = contentType;
      req.contentLength = chunked ? -1 : prefix.length + total + suffix.length;
      req.add(prefix);
      final chunk = List<int>.filled(16 * 1024, 0x61); // 'a'
      var sent = 0;
      while (sent < total) {
        final n = (total - sent) < chunk.length ? total - sent : chunk.length;
        req.add(n == chunk.length ? chunk : chunk.sublist(0, n));
        sent += n;
      }
      req.add(suffix);
      final res = await req.close().timeout(const Duration(seconds: 30));
      final body = await utf8.decodeStream(res);
      return (status: res.statusCode, body: body);
    } on SocketException {
      return (status: -1, body: '');
    } on HttpException {
      return (status: -1, body: '');
    }
  }

  final form = ContentType('application', 'x-www-form-urlencoded');
  final formPrefix = utf8.encode('a=');
  const boundary = 'finchboundary';
  final multipartType = ContentType(
    'multipart',
    'form-data',
    parameters: {'boundary': boundary},
  );
  final multipartPrefix = utf8.encode('--$boundary\r\n'
      'Content-Disposition: form-data; name="f"; filename="x.bin"\r\n'
      'Content-Type: application/octet-stream\r\n\r\n');
  final multipartSuffix = utf8.encode('\r\n--$boundary--\r\n');

  group('F-06: maxBodySize', () {
    test('maxBodySize can be overridden', () {
      expect(FinchApp.config.maxBodySize, _limit);
    });

    test('maxBodySize defaults to 10 MiB', () {
      expect(FinchConfigs().maxBodySize, 10 * 1024 * 1024);
    });

    test('bodies under the limit are still accepted', () async {
      var res =
          await post(contentType: form, prefix: formPrefix, total: _limit ~/ 2);
      expect(res.status, 200);
      expect(jsonDecode(res.body)['a'], _limit ~/ 2);
    });

    test('multipart upload under the limit is still accepted', () async {
      var res = await post(
        contentType: multipartType,
        prefix: multipartPrefix,
        total: _limit ~/ 2,
        suffix: multipartSuffix,
      );
      expect(res.status, 200);
      expect(jsonDecode(res.body)['files'], _limit ~/ 2);
    });

    test('declared Content-Length over the limit gets 413', () async {
      var res = await post(
        contentType: form,
        prefix: formPrefix,
        total: _limit + 1024,
      );
      expect(res.status, 413);
    });

    test('streamed (chunked) body over the limit gets 413', () async {
      var res = await post(
        contentType: form,
        prefix: formPrefix,
        total: _limit + 1024,
        chunked: true,
      );
      expect(res.status, 413);
    });

    test('oversized application/json body is rejected', () async {
      var res = await post(
        contentType: ContentType.json,
        prefix: utf8.encode('{"a":"'),
        total: _limit * 10,
        suffix: utf8.encode('"}'),
        chunked: true,
      );
      expect(res.status, anyOf(413, -1));
    });

    test('oversized multipart/form-data file is rejected', () async {
      var res = await post(
        contentType: multipartType,
        prefix: multipartPrefix,
        total: _limit + 1024,
        suffix: multipartSuffix,
        chunked: true,
      );
      expect(res.status, 413);
    });

    test('oversized body of an unknown content type is rejected', () async {
      var res = await post(
        contentType: ContentType('application', 'octet-stream'),
        total: _limit + 1024,
        chunked: true,
      );
      expect(res.status, 413);
    });

    test('413 on an API endpoint is a JSON error', () async {
      var res = await post(
        contentType: form,
        prefix: formPrefix,
        total: _limit + 1024,
        path: '/api/upload',
      );
      expect(res.status, 413);
      expect(jsonDecode(res.body)['success'], false);
    });

    test('the server keeps working after rejecting a large body', () async {
      await post(
        contentType: form,
        prefix: formPrefix,
        total: _limit * 5,
        chunked: true,
      );
      var res = await post(contentType: form, prefix: formPrefix, total: 10);
      expect(res.status, 200);
    });
  });

  group('F-06: maxSocketMessageSize', () {
    test('maxSocketMessageSize defaults to 1 MiB', () {
      expect(FinchConfigs().maxSocketMessageSize, 1024 * 1024);
    });

    test('a message over the limit closes the socket with 1009', () async {
      received.clear();
      final ws =
          await WebSocket.connect('ws://localhost:${httpServer.port}/ws');
      final closed = Completer<int?>();
      ws.listen((_) {}, onDone: () => closed.complete(ws.closeCode));

      ws.add(jsonEncode({'path': 'x', 'text': 'small'}));
      ws.add(jsonEncode({
        'path': 'x',
        'text': 'a' * (FinchApp.config.maxSocketMessageSize + 1),
      }));

      expect(
        await closed.future.timeout(const Duration(seconds: 10)),
        WebSocketStatus.messageTooBig,
      );
      expect(received, ['small']);
    });
  });
}
