import 'package:flutter/material.dart';
import '../data/models/notification_model.dart';
import '../data/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repo = NotificationRepository();

  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications() async {
    _setLoading(true);
    try {
      _notifications = await _repo.getNotifications();
      _unreadCount = await _repo.getUnreadCount();
    } catch (_) {
      // silently fail — badge just won't update
    } finally {
      _setLoading(false);
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repo.markAllAsRead();
      _unreadCount = 0;
      for (final n in _notifications) {
        n.isRead = true;
      }
      notifyListeners();
    } catch (_) {}
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
