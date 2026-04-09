import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';

class ApiService {
  static Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> verifyEmail(
    String email,
    String code,
  ) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/verify-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> resendCode(String email) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/resend-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/profile/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> setupProfile({
    required String token,
    required String fullName,
    required String dob,
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/profile/setup'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'full_name': fullName, 'date_of_birth': dob}),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
