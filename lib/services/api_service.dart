import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';

class ApiService {
  // ── Auth ────────────────────────────────────────────────
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

  // ── Profile ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/profile/me'),
      headers: _authHeaders(token),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> setupProfile({
    required String token,
    required String fullName,
    required String dob,
    required String role, // 'job_seeker' or 'mentor'
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/profile/setup'),
      headers: _authHeaders(token),
      body: jsonEncode({
        'full_name': fullName,
        'date_of_birth': dob,
        'role': role,
      }),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateJobSeekerProfile({
    required String token,
    required Map<String, dynamic> fields,
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/profile/job-seeker'),
      headers: _authHeaders(token),
      body: jsonEncode(fields),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateMentorProfile({
    required String token,
    required Map<String, dynamic> fields,
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/profile/mentor'),
      headers: _authHeaders(token),
      body: jsonEncode(fields),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ── Education ────────────────────────────────────────────
  static Future<Map<String, dynamic>> getEducation(String token) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/profile/education'),
      headers: _authHeaders(token),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> addEducation({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/profile/education'),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateEducation({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/profile/education/$id'),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> deleteEducation({
    required String token,
    required int id,
  }) async {
    final res = await http.delete(
      Uri.parse('$kBaseUrl/profile/education/$id'),
      headers: _authHeaders(token),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ── Work Experience ──────────────────────────────────────
  static Future<Map<String, dynamic>> getWorkExperience(String token) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/profile/work-experience'),
      headers: _authHeaders(token),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> addWorkExperience({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/profile/work-experience'),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateWorkExperience({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/profile/work-experience/$id'),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> deleteWorkExperience({
    required String token,
    required int id,
  }) async {
    final res = await http.delete(
      Uri.parse('$kBaseUrl/profile/work-experience/$id'),
      headers: _authHeaders(token),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ── Mentors ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> listMentors({
    required String token,
    String expertise = '',
    int page = 1,
  }) async {
    final uri = Uri.parse('$kBaseUrl/mentors').replace(
      queryParameters: {
        if (expertise.isNotEmpty) 'expertise': expertise,
        'page': '$page',
      },
    );
    final res = await http.get(uri, headers: _authHeaders(token));
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getMentorDetail({
    required String token,
    required int mentorId,
  }) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/mentors/$mentorId'),
      headers: _authHeaders(token),
    );
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ── Helpers ──────────────────────────────────────────────
  static Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };
}
