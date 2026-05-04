import 'package:flutter/material.dart';
import '../../core/themes/app_theme.dart';

class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String? body;
  bool isRead;
  final int? referenceId;
  final String? senderName;
  final String? senderPicture;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    required this.isRead,
    this.referenceId,
    this.senderName,
    this.senderPicture,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      type: json['type'] as String? ?? 'system',
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      isRead: json['is_read'] == 1,
      referenceId: json['reference_id'] as int?,
      senderName: json['sender_name'] as String?,
      senderPicture: json['sender_picture'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  IconData get icon {
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
        return Icons.work_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get iconColor {
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

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays > 7) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }
}
