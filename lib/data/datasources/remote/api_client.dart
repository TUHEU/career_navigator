// data/datasources/remote/api_client.dart
// Singleton HTTP Facade — single point of HTTP communication.
// ApiService uses this internally. Nothing else touches http.Client.
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  Map<String, String> _headers({String? token}) => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<Map<String, dynamic>> _call(Future<http.Response> Function() fn) async {
    try {
      final res = await fn().timeout(AppConstants.connectionTimeout);
      return _parse(res);
    } on AppException {
      rethrow;
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Map<String, dynamic> _parse(http.Response res) {
    try {
      final d = jsonDecode(res.body);
      if (d is Map<String, dynamic>) return d;
      return {'success': false, 'message': 'Unexpected response format'};
    } catch (_) {
      return {'success': false, 'message': 'Invalid response from server'};
    }
  }

  Future<Map<String, dynamic>> get(String path, {String? token}) =>
      _call(() => http.get(
            Uri.parse('${AppConstants.baseUrl}$path'),
            headers: _headers(token: token),
          ));

  Future<Map<String, dynamic>> getWithParams(
    String path,
    Map<String, String> params, {
    String? token,
  }) =>
      _call(() => http.get(
            Uri.parse('${AppConstants.baseUrl}$path')
                .replace(queryParameters: params),
            headers: _headers(token: token),
          ));

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) =>
      _call(() => http.post(
            Uri.parse('${AppConstants.baseUrl}$path'),
            headers: _headers(token: token),
            body: jsonEncode(body),
          ));

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    String? token,
  }) =>
      _call(() => http.put(
            Uri.parse('${AppConstants.baseUrl}$path'),
            headers: _headers(token: token),
            body: jsonEncode(body),
          ));

  Future<Map<String, dynamic>> delete(String path, {String? token}) =>
      _call(() => http.delete(
            Uri.parse('${AppConstants.baseUrl}$path'),
            headers: _headers(token: token),
          ));

  Future<Map<String, dynamic>> postMultipart(
    String path,
    http.MultipartFile file, {
    String? token,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${AppConstants.baseUrl}$path'),
    );
    if (token != null) request.headers['Authorization'] = 'Bearer $token';
    request.files.add(file);
    try {
      final streamed = await request.send().timeout(AppConstants.connectionTimeout);
      final res = await http.Response.fromStream(streamed);
      return _parse(res);
    } catch (e) {
      return {'success': false, 'message': 'Upload failed: $e'};
    }
  }
}
