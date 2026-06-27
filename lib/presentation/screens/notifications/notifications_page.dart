// presentation/screens/notifications/notifications_page.dart
// v9 — Redesigned with icons per type, mark read, swipe to dismiss
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/models/notification_model.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/loading_widgets.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});
  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<NotificationProvider>();
      p.loadNotifications().then((_) => p.markAllAsRead());
    });
  }

  IconData _icon(String type) {
    switch (type.toLowerCase()) {
      case 'connection_request': return Icons.person_add_outlined;
      case 'connection_accepted':return Icons.people_rounded;
      case 'message':            return Icons.chat_bubble_outline;
      case 'job_application':    return Icons.work_outline;
      case 'review':             return Icons.star_outline;
      default:                   return Icons.notifications_outlined;
    }
  }

  Color _color(String type) {
    switch (type.toLowerCase()) {
      case 'connection_request':  return const Color(0xFF7C3AED);
      case 'connection_accepted': return const Color(0xFF059669);
      case 'message':             return AppColors.primaryCyan;
      case 'job_application':     return const Color(0xFFF59E0B);
      case 'review':              return const Color(0xFFEC4899);
      default:                    return AppColors.primaryCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = context.watch<ThemeProvider>().isDarkMode;
    final notifProv= context.watch<NotificationProvider>();
    final lang     = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: Text(lang.t(S.notifications), style: TextStyle(
          color: AppColors.text(isDark), fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background(isDark), elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(isDark)),
        actions: [
          if (notifProv.notifications.isNotEmpty)
            TextButton(
              onPressed: notifProv.markAllAsRead,
              child: const Text('Mark all read',
                style: TextStyle(color: AppColors.primaryCyan, fontSize: 12))),
        ],
      ),
      body: notifProv.isLoading
          ? const LoadingIndicator(message: 'Loading notifications...')
          : notifProv.notifications.isEmpty
            ? _EmptyState(isDark: isDark)
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: notifProv.notifications.length,
                itemBuilder: (_, i) {
                  final n = notifProv.notifications[i];
                  final color = _color(n.type);
                  return Dismissible(
                    key: Key('notif_${n.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16)),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_outline,
                          color: AppColors.danger, size: 22)),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: n.isRead
                            ? AppColors.card(isDark)
                            : color.withOpacity(isDark ? 0.08 : 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: n.isRead
                            ? AppColors.border(isDark)
                            : color.withOpacity(0.3))),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12), shape: BoxShape.circle),
                          child: Icon(_icon(n.type), color: color, size: 18)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.title, style: TextStyle(
                              color: AppColors.text(isDark),
                              fontWeight: n.isRead ? FontWeight.w500 : FontWeight.bold,
                              fontSize: 14)),
                            if (n.body != null && n.body!.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(n.body!, style: TextStyle(
                                color: AppColors.textSecondary(isDark), fontSize: 12,
                                height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                            const SizedBox(height: 4),
                            Text(_formatTime(n.createdAt), style: TextStyle(
                              color: AppColors.textMuted(isDark), fontSize: 11)),
                          ])),
                        if (!n.isRead)
                          Container(
                            width: 8, height: 8, margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      ]),
                    ),
                  );
                }),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)   return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.notifications_none_rounded, size: 72,
          color: AppColors.textMuted(isDark)),
      const SizedBox(height: 16),
      Text('No notifications yet', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text('We\'ll let you know when something happens', style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 13)),
    ],
  ));
}
