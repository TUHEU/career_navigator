import '../datasources/remote/api_service.dart';
import '../datasources/local/token_store.dart';
import '../models/feedback_model.dart';

class FeedbackRepository {
  final ApiService _apiService = ApiService();
  final TokenStore _tokenStore = TokenStore();

  Future<void> submitFeedback({
    required String subject,
    required String message,
    String category = 'General',
    int? rating,
  }) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.submitFeedback(
      token: token,
      subject: subject,
      message: message,
      category: category,
      rating: rating,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to submit feedback');
    }
  }

  // Admin only
  Future<List<FeedbackModel>> getAllFeedback() async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    // This would need an admin endpoint
    // For now, return empty list
    return [];
  }

  // Admin only
  Future<void> updateFeedbackStatus(int feedbackId, String status) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    // This would need an admin endpoint
    // For now, just return
    return;
  }
}
