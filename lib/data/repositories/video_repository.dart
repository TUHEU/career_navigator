import '../datasources/remote/api_service.dart';
import '../datasources/local/token_store.dart';
import '../models/video_session_model.dart';

class VideoRepository {
  final ApiService _apiService = ApiService();
  final TokenStore _tokenStore = TokenStore();

  Future<Map<String, dynamic>> startSession({
    required int mentorId,
    required int seekerId,
  }) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');
    final response = await _apiService.startVideoSession(
      token: token,
      mentorId: mentorId,
      seekerId: seekerId,
    );
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to start video session');
    }
    return response['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> joinSession(String channelName) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');
    final response = await _apiService.joinVideoSession(
      token: token,
      channelName: channelName,
    );
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to join video session');
    }
    return response['data'] as Map<String, dynamic>;
  }

  Future<void> endSession(String channelName, int duration) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');
    final response = await _apiService.endVideoSession(
      token: token,
      channelName: channelName,
      duration: duration,
    );
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to end video session');
    }
  }

  Future<List<VideoSession>> getSessions() async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');
    final response = await _apiService.getVideoSessions(token);
    if (response['success'] == true) {
      final List<dynamic> data = response['data'] ?? [];
      return data
          .map((j) => VideoSession.fromJson(j as Map<String, dynamic>))
          .toList();
    }
    throw Exception(response['message'] ?? 'Failed to load video sessions');
  }
}
