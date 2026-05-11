import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';

class ApiService {
  Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'success': false, 'message': 'Unexpected response format'};
    } catch (_) {
      return {'success': false, 'message': 'Invalid response from server'};
    }
  }

  // ──────────────────────────────────────────────
  // AUTH
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.register}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.verifyEmail}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'code': code}),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> resendCode(String email) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.resendCode}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.login}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.forgotPassword}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String code,
    String password,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.resetPassword}'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'code': code,
              'password': password,
            }),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.changePassword}'),
            headers: _authHeaders(token),
            body: jsonEncode({
              'current_password': currentPassword,
              'new_password': newPassword,
            }),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteAccount(String token) async {
    try {
      final res = await http
          .delete(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.deleteAccount}'),
            headers: _authHeaders(token),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // PROFILE
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> getProfile(String token) async {
    try {
      final res = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.getProfile}'),
            headers: _authHeaders(token),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> setupProfile({
    required String token,
    required String fullName,
    required String dob,
    required String role,
  }) async {
    try {
      final res = await http
          .put(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.setupProfile}'),
            headers: _authHeaders(token),
            body: jsonEncode({
              'full_name': fullName,
              'date_of_birth': dob.isEmpty ? null : dob,
              'role': role,
            }),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateJobSeekerProfile({
    required String token,
    required Map<String, dynamic> fields,
  }) async {
    try {
      final res = await http
          .put(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.updateJobSeeker}'),
            headers: _authHeaders(token),
            body: jsonEncode(fields),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateMentorProfile({
    required String token,
    required Map<String, dynamic> fields,
  }) async {
    try {
      final res = await http
          .put(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.updateMentor}'),
            headers: _authHeaders(token),
            body: jsonEncode(fields),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // EDUCATION
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> addEducation({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.education}'),
            headers: _authHeaders(token),
            body: jsonEncode(data),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateEducation({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final res = await http
          .put(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.education}/$id'),
            headers: _authHeaders(token),
            body: jsonEncode(data),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteEducation({
    required String token,
    required int id,
  }) async {
    try {
      final res = await http
          .delete(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.education}/$id'),
            headers: _authHeaders(token),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // WORK EXPERIENCE
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> addWorkExperience({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.workExperience}'),
            headers: _authHeaders(token),
            body: jsonEncode(data),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> updateWorkExperience({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      final res = await http
          .put(
            Uri.parse(
              '${AppConstants.baseUrl}${ApiEndpoints.workExperience}/$id',
            ),
            headers: _authHeaders(token),
            body: jsonEncode(data),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteWorkExperience({
    required String token,
    required int id,
  }) async {
    try {
      final res = await http
          .delete(
            Uri.parse(
              '${AppConstants.baseUrl}${ApiEndpoints.workExperience}/$id',
            ),
            headers: _authHeaders(token),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // MENTORS
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> getMentors({
    String token = '',
    int page = 1,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.baseUrl}${ApiEndpoints.mentors}',
      ).replace(queryParameters: {'page': '$page'});
      final res = await http
          .get(uri, headers: token.isNotEmpty ? _authHeaders(token) : {})
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> sendMentorRequest({
    required String token,
    required int mentorId,
    String message = '',
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.requests}'),
            headers: _authHeaders(token),
            body: jsonEncode({'mentor_id': mentorId, 'message': message}),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getMyRequests(String token) async {
    try {
      final res = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.requests}'),
            headers: _authHeaders(token),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // JOBS
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> getJobs({
    String? location,
    String? employmentType,
    String? search,
    int page = 1,
  }) async {
    try {
      final params = <String, String>{'page': '$page'};
      if (location != null &&
          location.isNotEmpty &&
          location.toLowerCase() != 'all') {
        params['location'] = location;
      }
      if (employmentType != null &&
          employmentType.isNotEmpty &&
          employmentType.toLowerCase() != 'all') {
        params['employment_type'] = employmentType;
      }
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }
      final uri = Uri.parse(
        '${AppConstants.baseUrl}${ApiEndpoints.jobs}',
      ).replace(queryParameters: params);
      final res = await http.get(uri).timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getJobDetail(int jobId) async {
    try {
      final res = await http
          .get(Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.jobs}/$jobId'))
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> applyForJob({
    required String token,
    required int jobId,
    String? coverLetter,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse(
              '${AppConstants.baseUrl}${ApiEndpoints.jobs}/$jobId/apply',
            ),
            headers: _authHeaders(token),
            body: jsonEncode({'cover_letter': coverLetter ?? ''}),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getMyApplications(String token) async {
    try {
      final res = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.myApplications}'),
            headers: _authHeaders(token),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // NOTIFICATIONS
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> getNotifications(String token) async {
    try {
      final res = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.notifications}'),
            headers: _authHeaders(token),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> markNotificationsRead({
    required String token,
  }) async {
    try {
      final res = await http
          .put(
            Uri.parse(
              '${AppConstants.baseUrl}${ApiEndpoints.markNotificationsRead}',
            ),
            headers: _authHeaders(token),
            body: jsonEncode({}),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // CHAT
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> getConversations(String token) async {
    try {
      final res = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.conversations}'),
            headers: _authHeaders(token),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getMessages({
    required String token,
    required int conversationId,
  }) async {
    try {
      final res = await http
          .get(
            Uri.parse(
              '${AppConstants.baseUrl}${ApiEndpoints.messages}/$conversationId',
            ),
            headers: _authHeaders(token),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String token,
    required int recipientId,
    required String content,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.messages}'),
            headers: _authHeaders(token),
            body: jsonEncode({'recipient_id': recipientId, 'content': content}),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // SEARCH
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> search({
    required String token,
    required String query,
  }) async {
    try {
      final uri = Uri.parse(
        '${AppConstants.baseUrl}${ApiEndpoints.search}',
      ).replace(queryParameters: {'q': query});
      final res = await http
          .get(uri, headers: _authHeaders(token))
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ──────────────────────────────────────────────
  // FEEDBACK
  // ──────────────────────────────────────────────

  Future<Map<String, dynamic>> submitFeedback({
    required String token,
    required String subject,
    required String message,
    String category = 'General',
    int? rating,
  }) async {
    try {
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.feedback}'),
            headers: _authHeaders(token),
            body: jsonEncode({
              'subject': subject,
              'message': message,
              'category': category,
              'rating': rating,
            }),
          )
          .timeout(AppConstants.connectionTimeout);
      return _handleResponse(res);
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
