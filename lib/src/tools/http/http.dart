import 'dart:convert';
import 'dart:io';

class FinchHttp {
  static Future<HttpFinchResponse> get(Uri uri,
      {Map<String, String>? headers}) async {
    var client = HttpClient();
    try {
      final response = await client.getUrl(uri).then((request) {
        headers?.forEach((key, value) {
          request.headers.set(key, value);
        });
        return request.close();
      });

      List<int> bytes = [];
      await for (var chunk in response) {
        bytes.addAll(chunk);
      }

      client.close();
      return HttpFinchResponse(
        response,
        bodyBytes: bytes,
      );
    } catch (e) {
      client.close();
      throw FinchHttpException('Failed to perform GET request: $e');
    }
  }

  static Future<HttpFinchResponse> post(Uri uri,
      {Map<String, String>? headers, Object? body}) async {
    var client = HttpClient();
    try {
      final response = await client.postUrl(uri).then((request) {
        headers?.forEach((key, value) {
          request.headers.set(key, value);
        });

        if (body != null) {
          if (body is String) {
            request.write(body);
          } else if (body is List<int>) {
            request.add(body);
          } else {
            request.headers.contentType = ContentType.json;
            request.write(jsonEncode(body));
          }
        }

        return request.close();
      });

      List<int> bytes = [];
      await for (var chunk in response) {
        bytes.addAll(chunk);
      }
      client.close();
      return HttpFinchResponse(
        response,
        bodyBytes: bytes,
      );
    } catch (e) {
      client.close();
      throw FinchHttpException('Failed to perform POST request: $e');
    }
  }

  /// Downloads [uri] to [savePath] and reports progress as a stream.
  ///
  /// Each event contains the received bytes, the total size (when the server
  /// sends `content-length`), the remaining bytes and the percent. The last
  /// event has `isDone == true`. Errors (including non-2xx responses) are
  /// emitted as [FinchHttpException]; a partial file is deleted on failure.
  static Stream<DownloadProgress> download(
    Uri uri,
    String savePath, {
    Map<String, String>? headers,
  }) async* {
    final client = HttpClient();
    final file = File(savePath);
    IOSink? sink;
    var received = 0;
    var finished = false;

    try {
      final request = await client.getUrl(uri);
      headers?.forEach(request.headers.set);
      final response = await request.close();

      if (response.statusCode < 200 || response.statusCode >= 300) {
        await response.drain<void>();
        throw FinchHttpException(
          'Failed to download: ${response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }

      final total = response.contentLength >= 0 ? response.contentLength : null;
      await file.parent.create(recursive: true);
      sink = file.openWrite();

      yield DownloadProgress(received: 0, total: total);

      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        yield DownloadProgress(received: received, total: total);
      }

      await sink.flush();
      await sink.close();
      sink = null;
      finished = true;
      yield DownloadProgress(
        received: received,
        total: total,
        isDone: true,
      );
    } on FinchHttpException {
      rethrow;
    } catch (e) {
      throw FinchHttpException('Failed to download: $e');
    } finally {
      client.close(force: true);
      try {
        await sink?.close();
      } catch (_) {}
      if (!finished && await file.exists()) {
        await file.delete();
      }
    }
  }
}

/// Progress snapshot of [FinchHttp.download].
class DownloadProgress {
  /// Bytes downloaded so far.
  final int received;

  /// Total bytes, or `null` if the server did not report the size.
  final int? total;

  /// True on the final event, when the file is completely saved.
  final bool isDone;

  const DownloadProgress({
    required this.received,
    this.total,
    this.isDone = false,
  });

  /// Bytes left to download, or `null` if the total size is unknown.
  int? get remaining => total == null ? null : total! - received;

  /// Progress from 0 to 100, or `null` if the total size is unknown.
  double? get percent {
    if (total == null) return null;
    if (total == 0) return 100;
    return received / total! * 100;
  }

  @override
  String toString() =>
      'DownloadProgress(received: $received, total: $total, isDone: $isDone)';
}

class HttpFinchResponse {
  final HttpClientResponse _httpClientResponse;
  int get status => _httpClientResponse.statusCode;
  String get reasonPhrase => _httpClientResponse.reasonPhrase;
  HttpHeaders get headers => _httpClientResponse.headers;
  String get body => utf8.decode(bodyBytes);
  final List<int> bodyBytes;
  bool get success => status >= 200 && status < 300;
  bool get error => !success;
  dynamic get jsonBody => jsonDecode(body);

  HttpFinchResponse(this._httpClientResponse, {required this.bodyBytes});
}

class FinchHttpException implements Exception {
  final String message;
  final int? statusCode;

  FinchHttpException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'FinchHttpException: $message (Status code: $statusCode)';
    }
    return 'FinchHttpException: $message';
  }
}
