import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_store.dart';
import '../theme/app_theme.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> _notifs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final token = await TokenStore.getAccess();
      if (token == null) return;
      final res = await ApiService.getNotifications(token);
      if (res['success'] == true && mounted) {
        final data = res['data'] as Map<String, dynamic>;
        setState(() {
          _notifs = (data['notifications'] as List<dynamic>?) ?? [];
          _loading = false;
        });
        await ApiService.markNotificationsRead(token: token);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  IconData _icon(String type) {
    switch (type) {
      case 'mentor_request':
        return Icons.person_add_outlined;
      case 'request_accepted':
        return Icons.check_circle_outline;
      case 'request_rejected':
        return Icons.cancel_outlined;
      case 'new_message':
        return Icons.chat_bubble_outline;
      case 'job_alert':
        return Icons.work_off_outlined;
      case 'system':
        return Icons.settings_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'request_accepted':
        return Colors.greenAccent;
      case 'request_rejected':
        return Colors.redAccent;
      case 'new_message':
        return AppColors.primaryCyan;
      case 'job_alert':
        return Colors.amber;
      case 'mentor_request':
        return Colors.orangeAccent;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryCyan),
            )
          : _notifs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.notifications_none,
                    color: Colors.white12,
                    size: 60,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When you receive notifications, they will appear here.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primaryCyan,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _notifs.length,
                itemBuilder: (_, i) {
                  final n = _notifs[i] as Map<String, dynamic>;
                  final type = (n['type'] as String?) ?? '';
                  final read = n['is_read'] == 1 || n['is_read'] == true;
                  final createdAt = n['created_at'] ?? '';
                  final title = n['title'] ?? '';
                  final body = n['body'] ?? '';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: read
                          ? Colors.white.withOpacity(0.03)
                          : AppColors.primaryCyan.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: read
                            ? Colors.white.withOpacity(0.06)
                            : AppColors.primaryCyan.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _iconColor(type).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _icon(type),
                            color: _iconColor(type),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: read
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (body.isNotEmpty) ...[
                                const SizedBox(height: 3),
                                Text(
                                  body,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.55),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 5),
                              Text(
                                _formatDate(createdAt),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.3),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!read)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryCyan,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final parts = dateStr.split(' ');
      if (parts.length >= 2) {
        return '${parts[0]} ${parts[1].substring(0, 5)}';
      }
      return dateStr;
    } catch (e) {
      return dateStr;
    }
  }
}
