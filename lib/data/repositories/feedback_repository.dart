import '../datasources/remote/api_service.dart';
import '../datasources/local/token_store.dart';

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
}
