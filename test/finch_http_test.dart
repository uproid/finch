import 'dart:io';

import 'package:finch/src/tools/http/http.dart';
import 'package:test/test.dart';

void main() {
  group('FinchHttp.download', () {
    late HttpServer server;
    late Directory tmp;
    late Uri base;
    final payload = List<int>.generate(100000, (i) => i % 256);

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('finch_download_');
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      base = Uri.parse('http://127.0.0.1:${server.port}');
      server.listen((req) async {
        switch (req.uri.path) {
          case '/file':
            req.response.headers.contentLength = payload.length;
            for (var i = 0; i < payload.length; i += 10000) {
              req.response.add(payload.sublist(i, i + 10000));
              await req.response.flush();
            }
            break;
          case '/chunked':
            req.response.headers.chunkedTransferEncoding = true;
            req.response.add(payload.sublist(0, 5000));
            break;
          case '/auth':
            req.response
                .add(req.headers.value('x-token') == 'abc' ? [1, 2, 3] : [0]);
            break;
          case '/empty':
            req.response.headers.contentLength = 0;
            break;
          case '/broken':
            final socket = await req.response.detachSocket(writeHeaders: false);
            socket.write('HTTP/1.1 200 OK\r\ncontent-length: 50000\r\n\r\n');
            socket.add(payload.sublist(0, 1000));
            await socket.flush();
            socket.destroy();
            return;
          default:
            req.response.statusCode = 404;
        }
        await req.response.close();
      });
    });

    tearDown(() async {
      await server.close(force: true);
      await tmp.delete(recursive: true);
    });

    test('streams progress and saves the file', () async {
      final path = '${tmp.path}/out.bin';
      final events =
          await FinchHttp.download(base.resolve('/file'), path).toList();

      expect(events.first.received, 0);
      expect(events.first.total, payload.length);
      expect(events.last.isDone, isTrue);
      expect(events.last.received, payload.length);
      expect(events.last.remaining, 0);
      expect(events.last.percent, 100);
      expect(events.where((e) => e.isDone).length, 1);

      // monotonic progress, remaining decreases
      for (var i = 1; i < events.length; i++) {
        expect(
            events[i].received, greaterThanOrEqualTo(events[i - 1].received));
        expect(
            events[i].remaining!, lessThanOrEqualTo(events[i - 1].remaining!));
      }
      expect(events.length, greaterThan(2));
      expect(await File(path).readAsBytes(), payload);
    });

    test('unknown size gives null total/remaining/percent', () async {
      final path = '${tmp.path}/chunked.bin';
      final events =
          await FinchHttp.download(base.resolve('/chunked'), path).toList();

      expect(events.last.total, isNull);
      expect(events.last.remaining, isNull);
      expect(events.last.percent, isNull);
      expect(events.last.isDone, isTrue);
      expect(events.last.received, 5000);
      expect(await File(path).length(), 5000);
    });

    test('creates missing parent directories', () async {
      final path = '${tmp.path}/a/b/c.bin';
      await FinchHttp.download(base.resolve('/file'), path).drain<void>();
      expect(await File(path).length(), payload.length);
    });

    test('sends custom headers', () async {
      final path = '${tmp.path}/auth.bin';
      await FinchHttp.download(base.resolve('/auth'), path,
          headers: {'x-token': 'abc'}).drain<void>();
      expect(await File(path).readAsBytes(), [1, 2, 3]);
    });

    test('empty file reports 100 percent', () async {
      final path = '${tmp.path}/empty.bin';
      final events =
          await FinchHttp.download(base.resolve('/empty'), path).toList();
      expect(events.last.isDone, isTrue);
      expect(events.last.percent, 100);
      expect(await File(path).length(), 0);
    });

    test('non-2xx throws with status code and leaves no file', () async {
      final path = '${tmp.path}/missing.bin';
      await expectLater(
        FinchHttp.download(base.resolve('/nope'), path).toList(),
        throwsA(isA<FinchHttpException>()
            .having((e) => e.statusCode, 'statusCode', 404)),
      );
      expect(await File(path).exists(), isFalse);
    });

    test('connection failure throws FinchHttpException', () async {
      final port = server.port;
      await server.close(force: true);
      await expectLater(
        FinchHttp.download(
                Uri.parse('http://127.0.0.1:$port/file'), '${tmp.path}/x.bin')
            .toList(),
        throwsA(isA<FinchHttpException>()),
      );
      // restart so tearDown's close works
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    });

    test('interrupted download deletes the partial file', () async {
      final path = '${tmp.path}/broken.bin';
      await expectLater(
        FinchHttp.download(base.resolve('/broken'), path).toList(),
        throwsA(isA<FinchHttpException>()),
      );
      expect(await File(path).exists(), isFalse);
    });

    test('DownloadProgress calculations', () {
      const p = DownloadProgress(received: 25, total: 100);
      expect(p.remaining, 75);
      expect(p.percent, 25);
      expect(p.isDone, isFalse);
    });
  });

  // Uses a real public file server (OVH speed-test host), needs internet.
  group('FinchHttp.download (internet)', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('finch_download_net_');
    });

    tearDown(() async {
      await tmp.delete(recursive: true);
    });

    test('downloads a 1 MiB file from a real server', () async {
      final uri = Uri.parse('https://proof.ovh.net/files/1Mb.dat');
      final path = '${tmp.path}/1Mb.dat';

      final events = await FinchHttp.download(uri, path).toList();

      expect(events.first.received, 0);
      expect(events.first.total, 1048576);
      expect(events.last.isDone, isTrue);
      expect(events.last.received, 1048576);
      expect(events.last.remaining, 0);
      expect(events.last.percent, 100);
      expect(events.length, greaterThan(2));
      expect(await File(path).length(), 1048576);
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('downloads from a real server that does not send the size', () async {
      // httpbin streams the body with chunked encoding: no content-length.
      final uri =
          Uri.parse('https://httpbin.org/stream-bytes/102400?chunk_size=4096');
      final path = '${tmp.path}/stream.bin';

      final events = await FinchHttp.download(uri, path).toList();

      expect(events.every((e) => e.total == null), isTrue);
      expect(events.every((e) => e.remaining == null), isTrue);
      expect(events.every((e) => e.percent == null), isTrue);
      expect(events.first.received, 0);
      expect(events.last.isDone, isTrue);
      expect(events.last.received, 102400);
      expect(events.length, greaterThan(2));
      expect(await File(path).length(), 102400);
    }, timeout: const Timeout(Duration(seconds: 60)));

    test('404 from a real server throws with status code', () async {
      final uri = Uri.parse('https://proof.ovh.net/files/not-found.dat');
      await expectLater(
        FinchHttp.download(uri, '${tmp.path}/nf.dat').toList(),
        throwsA(isA<FinchHttpException>()
            .having((e) => e.statusCode, 'statusCode', 404)),
      );
      expect(await File('${tmp.path}/nf.dat').exists(), isFalse);
    }, timeout: const Timeout(Duration(seconds: 60)));
  });
}
