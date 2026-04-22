import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';

/// All HTTP communication with the Flask backend.
/// Each method maps 1-to-1 with a backend route.
class ApiService {
  // ── Auth ─────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/register'),
      headers: _json,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> verifyEmail(
    String email,
    String code,
  ) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/verify-email'),
      headers: _json,
      body: jsonEncode({'email': email, 'code': code}),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> resendCode(String email) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/resend-code'),
      headers: _json,
      body: jsonEncode({'email': email}),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/login'),
      headers: _json,
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/forgot-password'),
      headers: _json,
      body: jsonEncode({'email': email}),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/auth/reset-password'),
      headers: _json,
      body: jsonEncode({'email': email, 'code': code, 'password': password}),
    );
    return _decode(res);
  }

  // ── Profile ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> getProfile(String token) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/profile/me'),
      headers: _auth(token),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> setupProfile({
    required String token,
    required String fullName,
    required String dob,
    required String role,
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/profile/setup'),
      headers: _auth(token),
      body: jsonEncode({
        'full_name': fullName,
        'date_of_birth': dob,
        'role': role,
      }),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> updateProfilePicture({
    required String token,
    required String pictureUrl,
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/profile/picture'),
      headers: _auth(token),
      body: jsonEncode({'picture_url': pictureUrl}),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> updateJobSeekerProfile({
    required String token,
    required Map<String, dynamic> fields,
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/profile/job-seeker'),
      headers: _auth(token),
      body: jsonEncode(fields),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> updateMentorProfile({
    required String token,
    required Map<String, dynamic> fields,
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/profile/mentor'),
      headers: _auth(token),
      body: jsonEncode(fields),
    );
    return _decode(res);
  }

  // ── Education ─────────────────────────────────────────────
  static Future<Map<String, dynamic>> getEducation(String token) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/profile/education'),
      headers: _auth(token),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> addEducation({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/profile/education'),
      headers: _auth(token),
      body: jsonEncode(data),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> updateEducation({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/profile/education/$id'),
      headers: _auth(token),
      body: jsonEncode(data),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> deleteEducation({
    required String token,
    required int id,
  }) async {
    final res = await http.delete(
      Uri.parse('$kBaseUrl/profile/education/$id'),
      headers: _auth(token),
    );
    return _decode(res);
  }

  // ── Work Experience ───────────────────────────────────────
  static Future<Map<String, dynamic>> getWorkExperience(String token) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/profile/work-experience'),
      headers: _auth(token),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> addWorkExperience({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/profile/work-experience'),
      headers: _auth(token),
      body: jsonEncode(data),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> updateWorkExperience({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/profile/work-experience/$id'),
      headers: _auth(token),
      body: jsonEncode(data),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> deleteWorkExperience({
    required String token,
    required int id,
  }) async {
    final res = await http.delete(
      Uri.parse('$kBaseUrl/profile/work-experience/$id'),
      headers: _auth(token),
    );
    return _decode(res);
  }

  // ── Mentors ───────────────────────────────────────────────
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
    final res = await http.get(uri, headers: _auth(token));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> getMentorDetail({
    required String token,
    required int mentorId,
  }) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/mentors/$mentorId'),
      headers: _auth(token),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> getUserBackground({
    required String token,
    required int userId,
  }) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/mentors/user/$userId/background'),
      headers: _auth(token),
    );
    return _decode(res);
  }

  // ── Mentor Requests ───────────────────────────────────────
  static Future<Map<String, dynamic>> sendMentorRequest({
    required String token,
    required int mentorId,
    String message = '',
  }) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/requests'),
      headers: _auth(token),
      body: jsonEncode({'mentor_id': mentorId, 'message': message}),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> getMyRequests(String token) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/requests'),
      headers: _auth(token),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> respondToRequest({
    required String token,
    required int requestId,
    required String action, // 'accept' or 'reject'
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/requests/$requestId/respond'),
      headers: _auth(token),
      body: jsonEncode({'action': action}),
    );
    return _decode(res);
  }

  // ── Notifications ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getNotifications(
    String token, {
    int page = 1,
  }) async {
    final uri = Uri.parse(
      '$kBaseUrl/notifications',
    ).replace(queryParameters: {'page': '$page'});
    final res = await http.get(uri, headers: _auth(token));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> markNotificationsRead({
    required String token,
    List<int> ids = const [],
  }) async {
    final res = await http.put(
      Uri.parse('$kBaseUrl/notifications/read'),
      headers: _auth(token),
      body: jsonEncode({'ids': ids}),
    );
    return _decode(res);
  }

  // ── Chat ──────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getConversations(String token) async {
    final res = await http.get(
      Uri.parse('$kBaseUrl/chat/conversations'),
      headers: _auth(token),
    );
    return _decode(res);
  }

  static Future<Map<String, dynamic>> getMessages({
    required String token,
    required int conversationId,
    int page = 1,
  }) async {
    final uri = Uri.parse(
      '$kBaseUrl/chat/messages/$conversationId',
    ).replace(queryParameters: {'page': '$page'});
    final res = await http.get(uri, headers: _auth(token));
    return _decode(res);
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String token,
    required int recipientId,
    required String content,
  }) async {
    final res = await http.post(
      Uri.parse('$kBaseUrl/chat/messages'),
      headers: _auth(token),
      body: jsonEncode({'recipient_id': recipientId, 'content': content}),
    );
    return _decode(res);
  }

  // ── Search ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> search({
    required String token,
    required String query,
    String kind = 'all',
    int page = 1,
  }) async {
    final uri = Uri.parse(
      '$kBaseUrl/search',
    ).replace(queryParameters: {'q': query, 'kind': kind, 'page': '$page'});
    final res = await http.get(uri, headers: _auth(token));
    return _decode(res);
  }

  // ── Helpers ───────────────────────────────────────────────
  static const Map<String, String> _json = {'Content-Type': 'application/json'};

  static Map<String, String> _auth(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  static Map<String, dynamic> _decode(http.Response res) =>
      jsonDecode(res.body) as Map<String, dynamic>;
}
