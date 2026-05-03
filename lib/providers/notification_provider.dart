import 'package:flutter/material.dart';
import '../data/models/chat_model.dart';
import '../data/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _notificationRepository =
      NotificationRepository();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _setLoading(true);
    try {
      _notifications = await _notificationRepository.getNotifications();
      _unreadCount = await _notificationRepository.getUnreadCount();
      _setLoading(false);
    } catch (e) {
      _setLoading(false);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _notificationRepository.markAllAsRead();
      _unreadCount = 0;
      for (var n in _notifications) {
        n.isRead = true;
      }
      notifyListeners();
    } catch (e) {}
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
