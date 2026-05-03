import '../datasources/remote/api_service.dart';
import '../datasources/local/token_store.dart';

class MentorRepository {
  final ApiService _apiService = ApiService();
  final TokenStore _tokenStore = TokenStore();

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
