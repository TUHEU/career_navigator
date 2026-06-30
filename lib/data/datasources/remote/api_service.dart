// data/datasources/remote/api_service.dart
// Named HTTP methods — same public API as before, now uses ApiClient internally.
// All repositories work without any changes.
import 'package:http/http.dart' as http;
import '../../../core/constants/app_constants.dart';
import 'api_client.dart';

class ApiService {
  final _c = ApiClient.instance;

  // ── AUTH ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> register(String email, String password,
      {String? fullName, String? phone, String? dateOfBirth, String? gender}) =>
      _c.post(ApiEndpoints.register, {
        'email': email, 'password': password,
        if (fullName != null)    'full_name': fullName,
        if (phone != null)       'phone': phone,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (gender != null)      'gender': gender,
      });
  Future<Map<String, dynamic>> verifyEmail(String email, String code) =>
      _c.post(ApiEndpoints.verifyEmail, {'email': email, 'code': code});
  Future<Map<String, dynamic>> resendCode(String email) =>
      _c.post(ApiEndpoints.resendCode, {'email': email});
  Future<Map<String, dynamic>> login(String email, String password) =>
      _c.post(ApiEndpoints.login, {'email': email, 'password': password});
  Future<Map<String, dynamic>> forgotPassword(String email) =>
      _c.post(ApiEndpoints.forgotPassword, {'email': email});
  Future<Map<String, dynamic>> resetPassword(String email, String code, String password) =>
      _c.post(ApiEndpoints.resetPassword,
          {'email': email, 'code': code, 'password': password});
  Future<Map<String, dynamic>> changePassword(
          String token, String current, String newPass) =>
      _c.post(ApiEndpoints.changePassword,
          {'current_password': current, 'new_password': newPass}, token: token);
  Future<Map<String, dynamic>> deleteAccount(String token) =>
      _c.delete(ApiEndpoints.deleteAccount, token: token);

  // ── PROFILE ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> getProfile(String token) =>
      _c.get(ApiEndpoints.getProfile, token: token);
  Future<Map<String, dynamic>> setupProfile({
    required String token, required String fullName,
    required String dob,   required String role,
  }) =>
      _c.put(ApiEndpoints.setupProfile, {
        'full_name':     fullName,
        'date_of_birth': dob.isEmpty ? null : dob,
        'role':          role,
      }, token: token);
  Future<Map<String, dynamic>> updateJobSeekerProfile({
    required String token, required Map<String, dynamic> fields,
  }) => _c.put(ApiEndpoints.updateJobSeeker, fields, token: token);
  Future<Map<String, dynamic>> updateMentorProfile({
    required String token, required Map<String, dynamic> fields,
  }) => _c.put(ApiEndpoints.updateMentor, fields, token: token);
  Future<Map<String, dynamic>> uploadPicture(
          String token, http.MultipartFile file) =>
      _c.postMultipart(ApiEndpoints.updatePicture, file, token: token);

  // ── EDUCATION ────────────────────────────────────────────────
  Future<Map<String, dynamic>> addEducation({
    required String token, required Map<String, dynamic> data,
  }) => _c.post(ApiEndpoints.education, data, token: token);
  Future<Map<String, dynamic>> updateEducation({
    required String token, required int id,
    required Map<String, dynamic> data,
  }) => _c.put('${ApiEndpoints.education}/$id', data, token: token);
  Future<Map<String, dynamic>> deleteEducation({
    required String token, required int id,
  }) => _c.delete('${ApiEndpoints.education}/$id', token: token);

  // ── WORK EXPERIENCE ──────────────────────────────────────────
  Future<Map<String, dynamic>> addWorkExperience({
    required String token, required Map<String, dynamic> data,
  }) => _c.post(ApiEndpoints.workExperience, data, token: token);
  Future<Map<String, dynamic>> updateWorkExperience({
    required String token, required int id,
    required Map<String, dynamic> data,
  }) => _c.put('${ApiEndpoints.workExperience}/$id', data, token: token);
  Future<Map<String, dynamic>> deleteWorkExperience({
    required String token, required int id,
  }) => _c.delete('${ApiEndpoints.workExperience}/$id', token: token);

  // ── MENTORS ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> getMentors({String token = '', int page = 1}) =>
      _c.getWithParams(ApiEndpoints.mentors, {'page': '$page'},
          token: token.isNotEmpty ? token : null);
  Future<Map<String, dynamic>> sendMentorRequest({
    required String token, required int mentorId, String message = '',
  }) => _c.post(ApiEndpoints.requests,
          {'mentor_id': mentorId, 'message': message}, token: token);
  Future<Map<String, dynamic>> getMyRequests(String token) =>
      _c.get(ApiEndpoints.requests, token: token);

  // ── JOBS ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getJobs({
    String? location, String? employmentType,
    String? search,   int page = 1,
  }) {
    final p = <String, String>{'page': '$page'};
    if (location != null && location.isNotEmpty &&
        location.toLowerCase() != 'all') {
      p['location'] = location;
    }
    if (employmentType != null && employmentType.isNotEmpty &&
        employmentType.toLowerCase() != 'all') {
      p['employment_type'] = employmentType;
    }
    if (search != null && search.isNotEmpty) p['search'] = search;
    return _c.getWithParams(ApiEndpoints.jobs, p);
  }
  Future<Map<String, dynamic>> getJobDetail(int jobId) =>
      _c.get('${ApiEndpoints.jobs}/$jobId');
  Future<Map<String, dynamic>> applyForJob({
    required String token, required int jobId, String? coverLetter,
  }) => _c.post('${ApiEndpoints.jobs}/$jobId/apply',
          {'cover_letter': coverLetter ?? ''}, token: token);
  Future<Map<String, dynamic>> getMyApplications(String token) =>
      _c.get(ApiEndpoints.myApplications, token: token);

  // ── NOTIFICATIONS ────────────────────────────────────────────
  Future<Map<String, dynamic>> getNotifications(String token) =>
      _c.get(ApiEndpoints.notifications, token: token);
  Future<Map<String, dynamic>> markNotificationsRead({required String token}) =>
      _c.put(ApiEndpoints.markNotificationsRead, {}, token: token);

  // ── CHAT ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getConversations(String token) =>
      _c.get(ApiEndpoints.conversations, token: token);
  Future<Map<String, dynamic>> getMessages({
    required String token, required int conversationId,
  }) => _c.get('${ApiEndpoints.messages}/$conversationId', token: token);
  Future<Map<String, dynamic>> sendMessage({
    required String token, required int recipientId, required String content,
  }) => _c.post(ApiEndpoints.messages,
          {'recipient_id': recipientId, 'content': content}, token: token);

  // ── SEARCH ───────────────────────────────────────────────────
  Future<Map<String, dynamic>> search({
    required String token, required String query,
  }) => _c.getWithParams(ApiEndpoints.search, {'q': query}, token: token);

  // ── FEEDBACK & REVIEWS ───────────────────────────────────────
  Future<Map<String, dynamic>> submitFeedback({
    required String token,
    required String subject,
    required String message,
    String category = 'General',
    int? rating,
  }) {
    final body = <String, dynamic>{
      'subject':  subject,
      'message':  message,
      'category': category,
    };
    if (rating != null) body['rating'] = rating;
    return _c.post(ApiEndpoints.feedback, body, token: token);
  }

  Future<Map<String, dynamic>> getMentorReviews(String token, int mentorId) =>
      _c.get(ApiEndpoints.mentorReviews(mentorId), token: token);
  Future<Map<String, dynamic>> submitMentorReview({
    required String token, required int mentorId,
    required int rating,      String review = '',
  }) => _c.post(ApiEndpoints.mentorReviews(mentorId),
          {'rating': rating, 'review': review}, token: token);

  // ── USERS BROWSE ─────────────────────────────────────────────
  Future<Map<String, dynamic>> getUsers({
    required String token,
    String role  = '',
    String query = '',
    int    page  = 1,
  }) {
    final p = <String, String>{'page': '$page'};
    if (role.isNotEmpty)  p['role'] = role;
    if (query.isNotEmpty) p['q']    = query;
    return _c.getWithParams(ApiEndpoints.users, p, token: token);
  }

  // ── POSTS (v10) ────────────────────────────────────────────────
  Future<Map<String, dynamic>> getPosts({
    required String token, String category = '', int page = 1,
  }) {
    final p = <String, String>{'page': '$page'};
    if (category.isNotEmpty) p['category'] = category;
    return _c.getWithParams('/posts', p, token: token);
  }

  Future<Map<String, dynamic>> createPost({
    required String token, required String content,
    required String category, List<String> tags = const [],
  }) => _c.post('/posts',
          {'content': content, 'category': category, 'tags': tags},
          token: token);

  Future<Map<String, dynamic>> likePost({
    required String token, required int postId,
  }) => _c.post('/posts/$postId/like', {}, token: token);

  Future<Map<String, dynamic>> unlikePost({
    required String token, required int postId,
  }) => _c.delete('/posts/$postId/like', token: token);

  Future<Map<String, dynamic>> deletePost({
    required String token, required int postId,
  }) => _c.delete('/posts/$postId', token: token);

  // ── SAVED JOBS (v10) ──────────────────────────────────────────
  Future<Map<String, dynamic>> getSavedJobs({required String token}) =>
      _c.get('/jobs/saved', token: token);

  Future<Map<String, dynamic>> saveJob({
    required String token, required int jobId,
  }) => _c.post('/jobs/$jobId/save', {}, token: token);

  Future<Map<String, dynamic>> unsaveJob({
    required String token, required int jobId,
  }) => _c.delete('/jobs/$jobId/save', token: token);

  // ── STATS & ACHIEVEMENTS (v10) ─────────────────────────────────
  Future<Map<String, dynamic>> getUserStats({required String token}) =>
      _c.get('/profile/stats', token: token);

  Future<Map<String, dynamic>> getAchievements({required String token}) =>
      _c.get('/profile/achievements', token: token);

  // ── CONNECTIONS BROWSE/SEARCH (v10) ─────────────────────────────
  Future<Map<String, dynamic>> browseUsers({
    required String token, String role = '', int page = 1,
  }) {
    final p = <String, String>{'page': '$page'};
    if (role.isNotEmpty) p['role'] = role;
    return _c.getWithParams('/users', p, token: token);
  }

  Future<Map<String, dynamic>> searchUsers({
    required String token, required String q,
  }) => _c.getWithParams('/users/search', {'q': q}, token: token);

  Future<Map<String, dynamic>> sendConnection({
    required String token, required int addresseeId, String? message,
  }) => _c.post('/connections/request',
          {'addressee_id': addresseeId, 'message': message ?? ''},
          token: token);

  // ── ADMIN (v11) — aligned to actual backend admin_routes.py ─────
  Future<Map<String, dynamic>> getAdminStats(String token) =>
      _c.get(ApiEndpoints.adminStats, token: token);

  Future<Map<String, dynamic>> adminGetUsers(String token, {String role = ''}) async {
    final body = await _c.get(ApiEndpoints.adminUsers, token: token);
    if (role.isNotEmpty && body['success'] == true) {
      final list = (body['data'] as List)
          .where((u) => (u as Map)['role'] == role)
          .toList();
      body['data'] = list;
    }
    return body;
  }

  Future<Map<String, dynamic>> adminToggleUserActive(
    String token, int userId, bool active,
  ) => _c.put('${ApiEndpoints.adminUsers}/$userId/status',
          {'is_active': active}, token: token);

  Future<Map<String, dynamic>> adminGetJobs(String token) =>
      _c.get(ApiEndpoints.adminJobs, token: token);

  Future<Map<String, dynamic>> adminDeactivateJob(String token, int jobId) =>
      _c.delete('${ApiEndpoints.adminJobs}/$jobId', token: token);

  Future<Map<String, dynamic>> adminGetFeedback(String token) =>
      _c.get(ApiEndpoints.adminFeedback, token: token);
}
