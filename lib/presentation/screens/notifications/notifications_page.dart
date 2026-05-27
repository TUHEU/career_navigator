// presentation/screens/notifications/notifications_page.dart
// FIXED: language support
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../data/models/notification_model.dart';
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
      final provider = context.read<NotificationProvider>();
      provider.loadNotifications().then((_) => provider.markAllAsRead());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark     = context.watch<ThemeProvider>().isDarkMode;
    final notifProv  = context.watch<NotificationProvider>();
    final lang       = context.watch<LanguageProvider>();
    final notifs     = notifProv.notifications;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(lang.t(S.notifications),
            style: TextStyle(color: AppColors.text(isDark))),
        backgroundColor: AppColors.surface(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(isDark)),
      ),
      body: notifProv.isLoading
          ? const LoadingIndicator()
          : notifs.isEmpty
              ? Center(child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.notifications_none,
                        size: 64,
                        color: AppColors.textMuted(isDark)),
                    const SizedBox(height: 12),
                    Text(lang.t(S.noData), style: TextStyle(
                        color: AppColors.textMuted(isDark))),
                  ],
                ))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifs.length,
                  itemBuilder: (_, i) => _NotifTile(
                      notif: notifs[i], isDark: isDark)),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel notif;
  final bool isDark;
  const _NotifTile({required this.notif, required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: notif.isRead
          ? AppColors.card(isDark)
          : AppColors.primaryCyan.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: notif.isRead
          ? AppColors.border(isDark)
          : AppColors.primaryCyan.withValues(alpha: 0.3)),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryCyan.withValues(alpha: 0.12),
          shape: BoxShape.circle),
        child: const Icon(Icons.notifications_outlined,
            color: AppColors.primaryCyan, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notif.title, style: TextStyle(
            color: AppColors.text(isDark),
            fontWeight: FontWeight.w600, fontSize: 14)),
          if (notif.body != null && notif.body!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(notif.body!, style: TextStyle(
              color: AppColors.textSecondary(isDark), fontSize: 13)),
          ],
          const SizedBox(height: 4),
          Text(notif.createdAt.toString().substring(0, 16),
            style: TextStyle(
              color: AppColors.textMuted(isDark), fontSize: 11)),
        ],
      )),
      if (!notif.isRead)
        Container(width: 8, height: 8,
          decoration: const BoxDecoration(
            color: AppColors.primaryCyan, shape: BoxShape.circle)),
    ]),
  );
}
