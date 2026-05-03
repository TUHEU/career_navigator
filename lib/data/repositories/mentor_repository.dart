import '../datasources/remote/api_service.dart';
import '../datasources/local/token_store.dart';
import '../models/user_model.dart';

class MentorRepository {
  final ApiService _apiService = ApiService();
  final TokenStore _tokenStore = TokenStore();

  Future<List<Mentor>> getMentors({String? expertise, int page = 1}) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.listMentors(
      token: token,
      expertise: expertise ?? '',
      page: page,
    );

    if (response['success'] == true) {
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Mentor.fromJson(json)).toList();
    }
    throw Exception(response['message'] ?? 'Failed to load mentors');
  }

  Future<Mentor> getMentorDetail(int mentorId) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.getMentorDetail(
      token: token,
      mentorId: mentorId,
    );

    if (response['success'] == true) {
      return Mentor.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception(response['message'] ?? 'Failed to load mentor details');
  }

  Future<Map<String, dynamic>> sendMentorRequest(
    int mentorId, {
    String message = '',
  }) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.sendMentorRequest(
      token: token,
      mentorId: mentorId,
      message: message,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to send request');
    }
    return response;
  }

  Future<List<Map<String, dynamic>>> getMyRequests() async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.getMyRequests(token);

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      final received = List<Map<String, dynamic>>.from(data['received'] ?? []);
      final sent = List<Map<String, dynamic>>.from(data['sent'] ?? []);
      return [...received, ...sent];
    }
    throw Exception(response['message'] ?? 'Failed to load requests');
  }
}
