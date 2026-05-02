import 'package:flutter/material.dart';
import '../data/datasources/remote/api_service.dart';
import '../data/datasources/local/token_store.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final TokenStore _tokenStore = TokenStore();

  List<Map<String, dynamic>> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<Map<String, dynamic>> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    final token = await _tokenStore.getAccess();
    if (token == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getNotifications(token);
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        _notifications = List<Map<String, dynamic>>.from(
          data['notifications'] ?? [],
        );
        _unreadCount = data['unread_count'] ?? 0;
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final token = await _tokenStore.getAccess();
    if (token == null) return;

    try {
      await _apiService.markNotificationsRead(token: token);
      for (var notification in _notifications) {
        notification['is_read'] = 1;
      }
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking notifications as read: $e');
    }
  }

  void addNotification(Map<String, dynamic> notification) {
    _notifications.insert(0, notification);
    _unreadCount++;
    notifyListeners();
  }
}
