import 'dart:convert';
import 'dart:io';

import 'exceptions.dart';

/// Sends a JSON POST request to the given [url] and returns the decoded response.
///
/// Sets `Content-Type: application/json` automatically. Additional [headers]
/// can be provided and will be merged into the request.
///
/// [url] is the full endpoint URL.
/// [body] is the request payload, encoded as JSON.
/// [headers] is an optional map of additional HTTP headers.
///
/// Returns the decoded JSON response as a `Map<String, dynamic>`.
///
/// Throws [NetworkException] in the following cases:
/// - Non-2xx HTTP status code (code format: `HTTP_{statusCode}`)
/// - Socket/connection error
/// - Invalid or unparseable JSON response
///
/// Example:
/// ```dart
/// final response = await postJson(
///   'https://api.example.com/endpoint',
///   {'key': 'value'},
///   headers: {'Authorization': 'token123'},
/// );
/// ```
Future<Map<String, dynamic>> postJson(
  String url,
  Map<String, dynamic> body, {
  Map<String, String>? headers,
}) async {
  final uri = Uri.parse(url);
  final client = HttpClient();
  try {
    final request = await client.postUrl(uri);
    request.headers.contentType = ContentType.json;
    headers?.forEach((k, v) => request.headers.set(k, v));
    request.write(jsonEncode(body));

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw NetworkException(
        'HTTP ${response.statusCode}: $responseBody',
        code: 'HTTP_${response.statusCode}',
      );
    }

    return jsonDecode(responseBody) as Map<String, dynamic>;
  } on SocketException catch (e) {
    throw NetworkException('Connection failed: ${e.message}');
  } on FormatException catch (e) {
    throw NetworkException('Invalid response: ${e.message}');
  } on TelebirrException {
    rethrow;
  } finally {
    client.close();
  }
}
