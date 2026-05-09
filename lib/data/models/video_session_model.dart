import 'package:flutter/material.dart';

class VideoSession {
  final int id;
  final String channelName;
  final int mentorId;
  final int seekerId;
  final String status;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final String? recordingUrl;
  final DateTime createdAt;
  final String? mentorName;
  final String? seekerName;

  VideoSession({
    required this.id,
    required this.channelName,
    required this.mentorId,
    required this.seekerId,
    required this.status,
    this.startedAt,
    this.endedAt,
    this.durationSeconds = 0,
    this.recordingUrl,
    required this.createdAt,
    this.mentorName,
    this.seekerName,
  });

  factory VideoSession.fromJson(Map<String, dynamic> json) {
    return VideoSession(
      id: json['id'] as int,
      channelName: json['channel_name'] as String,
      mentorId: json['mentor_id'] as int,
      seekerId: json['seeker_id'] as int,
      status: json['status'] as String,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'].toString())
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.tryParse(json['ended_at'].toString())
          : null,
      durationSeconds: json['duration_seconds'] as int? ?? 0,
      recordingUrl: json['recording_url'] as String?,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      mentorName: json['mentor_name'] as String?,
      seekerName: json['seeker_name'] as String?,
    );
  }

  String get durationFormatted {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  bool get isActive => status == 'active';
  bool get isEnded => status == 'ended';
  bool get isMissed => status == 'missed';

  String get statusDisplay {
    switch (status) {
      case 'scheduled':
        return 'Scheduled';
      case 'active':
        return 'In Progress';
      case 'ended':
        return 'Completed';
      case 'missed':
        return 'Missed';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'scheduled':
        return Colors.orange;
      case 'active':
        return Colors.green;
      case 'ended':
        return Colors.blue;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
