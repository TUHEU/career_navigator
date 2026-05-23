// data/repositories/notification_repository.dart
import '../datasources/remote/api_service.dart';
import '../datasources/local/token_store.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final ApiService _apiService = ApiService();
  final TokenStore _tokenStore = TokenStore();

  // FIX: PyMySQL returns unread_count as String in some MySQL versions
  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }

  Future<List<NotificationModel>> getNotifications() async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');
    final response = await _apiService.getNotifications(token);
    if (response['success'] == true) {
      final data  = response['data'] as Map<String, dynamic>;
      final items = data['notifications'] as List? ?? [];
      return items
          .map((j) => NotificationModel.fromJson(j as Map<String, dynamic>))
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
      return _toInt(data['unread_count']) ?? 0;
    }
    return 0;
  }

  Future<void> markAllAsRead() async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');
    final response = await _apiService.markNotificationsRead(token: token);
    if (response['success'] != true) {
      throw Exception(
          response['message'] ?? 'Failed to mark notifications as read');
    }
  }
}
