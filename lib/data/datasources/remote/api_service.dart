import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';

class ApiService {
  Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  dynamic _handleResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      return {'success': false, 'message': 'Invalid response from server'};
    }
  }

  // ============================================================
  // AUTH ENDPOINTS
  // ============================================================

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.register}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.verifyEmail}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> resendCode(String email) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.resendCode}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.login}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.forgotPassword}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String code,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.resetPassword}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code, 'password': password}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> changePassword(
    String token,
    String currentPassword,
    String newPassword,
  ) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.changePassword}'),
      headers: _authHeaders(token),
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteAccount(String token) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.deleteAccount}'),
      headers: _authHeaders(token),
    );
    return _handleResponse(response);
  }

  // ============================================================
  // PROFILE ENDPOINTS
  // ============================================================

  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.getProfile}'),
      headers: _authHeaders(token),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> setupProfile({
    required String token,
    required String fullName,
    required String dob,
    required String role,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.setupProfile}'),
      headers: _authHeaders(token),
      body: jsonEncode({
        'full_name': fullName,
        'date_of_birth': dob,
        'role': role,
      }),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updatePicture({
    required String token,
    required String pictureUrl,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.updatePicture}'),
      headers: _authHeaders(token),
      body: jsonEncode({'picture_url': pictureUrl}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateJobSeekerProfile({
    required String token,
    required Map<String, dynamic> fields,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.updateJobSeeker}'),
      headers: _authHeaders(token),
      body: jsonEncode(fields),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateMentorProfile({
    required String token,
    required Map<String, dynamic> fields,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.updateMentor}'),
      headers: _authHeaders(token),
      body: jsonEncode(fields),
    );
    return _handleResponse(response);
  }

  // ============================================================
  // EDUCATION ENDPOINTS
  // ============================================================

  Future<Map<String, dynamic>> addEducation({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.education}'),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateEducation({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.education}/$id'),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteEducation({
    required String token,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.education}/$id'),
      headers: _authHeaders(token),
    );
    return _handleResponse(response);
  }

  // ============================================================
  // WORK EXPERIENCE ENDPOINTS
  // ============================================================

  Future<Map<String, dynamic>> addWorkExperience({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.workExperience}'),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateWorkExperience({
    required String token,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.workExperience}/$id'),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteWorkExperience({
    required String token,
    required int id,
  }) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.workExperience}/$id'),
      headers: _authHeaders(token),
    );
    return _handleResponse(response);
  }

  // ============================================================
  // MENTOR ENDPOINTS
  // ============================================================

  Future<Map<String, dynamic>> listMentors({
    required String token,
    String expertise = '',
    int page = 1,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.mentors}')
        .replace(
          queryParameters: {
            if (expertise.isNotEmpty) 'expertise': expertise,
            'page': '$page',
          },
        );
    final response = await http.get(uri, headers: _authHeaders(token));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getMentorDetail({
    required String token,
    required int mentorId,
  }) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.mentors}/$mentorId'),
      headers: _authHeaders(token),
    );
    return _handleResponse(response);
  }

  // ============================================================
  // MENTOR REQUEST ENDPOINTS
  // ============================================================

  Future<Map<String, dynamic>> sendMentorRequest({
    required String token,
    required int mentorId,
    String message = '',
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.requests}'),
      headers: _authHeaders(token),
      body: jsonEncode({'mentor_id': mentorId, 'message': message}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getMyRequests(String token) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.requests}'),
      headers: _authHeaders(token),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> respondToRequest({
    required String token,
    required int requestId,
    required String action,
  }) async {
    final response = await http.put(
      Uri.parse(
        '${AppConstants.baseUrl}${ApiEndpoints.requests}/$requestId/respond',
      ),
      headers: _authHeaders(token),
      body: jsonEncode({'action': action}),
    );
    return _handleResponse(response);
  }

  // ============================================================
  // JOB ENDPOINTS
  // ============================================================

  Future<Map<String, dynamic>> getJobs({
    String? location,
    String? employmentType,
    String? search,
    int page = 1,
  }) async {
    final Map<String, String> queryParams = {'page': '$page'};
    if (location != null && location.isNotEmpty && location != 'All') {
      queryParams['location'] = location;
    }
    if (employmentType != null &&
        employmentType.isNotEmpty &&
        employmentType != 'All') {
      queryParams['employment_type'] = employmentType;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.jobs}',
    ).replace(queryParameters: queryParams);
    final response = await http.get(uri);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getJobDetail(int jobId) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.jobs}/$jobId'),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> createJob({
    required String token,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.jobs}'),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> updateJob({
    required String token,
    required int jobId,
    required Map<String, dynamic> data,
  }) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.jobs}/$jobId'),
      headers: _authHeaders(token),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteJob({
    required String token,
    required int jobId,
  }) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.jobs}/$jobId'),
      headers: _authHeaders(token),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> applyForJob({
    required String token,
    required int jobId,
    String? coverLetter,
    String? resumeUrl,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.jobs}/$jobId/apply'),
      headers: _authHeaders(token),
      body: jsonEncode({'cover_letter': coverLetter, 'resume_url': resumeUrl}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getMyApplications(String token) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.myApplications}'),
      headers: _authHeaders(token),
    );
    return _handleResponse(response);
  }

  // ============================================================
  // NOTIFICATION ENDPOINTS
  // ============================================================

  Future<Map<String, dynamic>> getNotifications(
    String token, {
    int page = 1,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.notifications}',
    ).replace(queryParameters: {'page': '$page'});
    final response = await http.get(uri, headers: _authHeaders(token));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> markNotificationsRead({
    required String token,
    List<int> ids = const [],
  }) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.markNotificationsRead}'),
      headers: _authHeaders(token),
      body: jsonEncode({'ids': ids}),
    );
    return _handleResponse(response);
  }

  // ============================================================
  // CHAT ENDPOINTS
  // ============================================================

  Future<Map<String, dynamic>> getConversations(String token) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.conversations}'),
      headers: _authHeaders(token),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getMessages({
    required String token,
    required int conversationId,
    int page = 1,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.messages}/$conversationId',
    ).replace(queryParameters: {'page': '$page'});
    final response = await http.get(uri, headers: _authHeaders(token));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> sendMessage({
    required String token,
    required int recipientId,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.messages}'),
      headers: _authHeaders(token),
      body: jsonEncode({'recipient_id': recipientId, 'content': content}),
    );
    return _handleResponse(response);
  }

  // ============================================================
  // SEARCH ENDPOINT
  // ============================================================

  Future<Map<String, dynamic>> search({
    required String token,
    required String query,
    String kind = 'all',
    int page = 1,
  }) async {
    final uri = Uri.parse(
      '${AppConstants.baseUrl}${ApiEndpoints.search}',
    ).replace(queryParameters: {'q': query, 'kind': kind, 'page': '$page'});
    final response = await http.get(uri, headers: _authHeaders(token));
    return _handleResponse(response);
  }

  // ============================================================
  // FEEDBACK ENDPOINT
  // ============================================================

  Future<Map<String, dynamic>> submitFeedback({
    required String token,
    required String subject,
    required String message,
    String category = 'General',
    int? rating,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.feedback}'),
      headers: _authHeaders(token),
      body: jsonEncode({
        'subject': subject,
        'message': message,
        'category': category,
        'rating': rating,
      }),
    );
    return _handleResponse(response);
  }

  // ============================================================
  // VIDEO CALL ENDPOINTS
  // ============================================================

  Future<Map<String, dynamic>> startVideoSession({
    required String token,
    required int mentorId,
    required int seekerId,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.videoStartSession}'),
      headers: _authHeaders(token),
      body: jsonEncode({'mentor_id': mentorId, 'seeker_id': seekerId}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> joinVideoSession({
    required String token,
    required String channelName,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.videoJoinSession}'),
      headers: _authHeaders(token),
      body: jsonEncode({'channel_name': channelName}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> endVideoSession({
    required String token,
    required String channelName,
    required int duration,
  }) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.videoEndSession}'),
      headers: _authHeaders(token),
      body: jsonEncode({'channel_name': channelName, 'duration': duration}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getVideoSessions(String token) async {
    final response = await http.get(
      Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.videoSessions}'),
      headers: _authHeaders(token),
    );
    return _handleResponse(response);
  }
}
