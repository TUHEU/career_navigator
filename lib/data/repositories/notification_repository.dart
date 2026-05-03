import '../datasources/remote/api_service.dart';
import '../datasources/local/token_store.dart';
import '../models/chat_model.dart';

class NotificationRepository {
  final ApiService _apiService = ApiService();
  final TokenStore _tokenStore = TokenStore();

  Future<List<NotificationModel>> getNotifications() async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.getNotifications(token);

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      final List<dynamic> notifications = data['notifications'] ?? [];
      return notifications
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    }
    throw Exception(response['message'] ?? 'Failed to load notifications');
  }

  Future<int> getUnreadCount() async {
    final token = await _tokenStore.getAccess();
    if (token == null) return 0;

    final response = await _apiService.getNotifications(token);

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      return data['unread_count'] as int? ?? 0;
    }
    return 0;
  }

  Future<void> markAllAsRead() async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.markNotificationsRead(token: token);

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to mark as read');
    }
  }
}
