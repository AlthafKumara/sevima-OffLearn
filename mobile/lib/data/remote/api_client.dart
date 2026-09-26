import 'dart:convert';
import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Central HTTP client for all backend API calls.
/// Reads [API_URL] from `.env` and wraps standard response envelope handling.
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String get _baseUrl {
    final url = dotenv.env['API_URL'] ?? 'http://localhost:3000';
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Makes a GET request to [path] with optional [queryParams].
  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse(
      '$_baseUrl$path',
    ).replace(queryParameters: queryParams);
    log('[GET] $uri');

    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  /// Makes a POST request to [path] with [body].
  Future<dynamic> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$path');
    log('[POST] $uri | body: $body');

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Makes a PUT request to [path] with [body].
  Future<dynamic> put(String path, Map<String, dynamic> body) async {
    final uri = Uri.parse('$_baseUrl$path');
    log('[PUT] $uri | body: $body');

    final response = await http.put(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// Makes a DELETE request to [path] with optional [body].
  Future<dynamic> delete(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$_baseUrl$path');
    log('[DELETE] $uri');

    final request = http.Request('DELETE', uri);
    request.headers.addAll(_headers);
    if (body != null) request.body = jsonEncode(body);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  /// Parses and validates the standard `{ success, message, data }` envelope.
  dynamic _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    final success = decoded['success'] as bool? ?? false;
    final message = decoded['message'] as String? ?? 'Unknown error';

    if (!success || response.statusCode >= 400) {
      throw Exception(message);
    }

    return decoded['data'];
  }
}
