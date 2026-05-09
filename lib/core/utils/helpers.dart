import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';

class Helpers {
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
  }

  static String formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';
    try {
      final parts = dateTimeStr.split(' ');
      if (parts.length >= 2) {
        return '${parts[0]} ${parts[1].substring(0, 5)}';
      }
      return dateTimeStr;
    } catch (_) {
      return dateTimeStr ?? '';
    }
  }

  static String getRelativeTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final now = DateTime.now();
      final diff = now.difference(dateTime);
      if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return '';
    }
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = Colors.redAccent,
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.lightText,
              ),
            ),
            content: Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmText, style: TextStyle(color: confirmColor)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
