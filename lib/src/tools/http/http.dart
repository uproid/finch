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
