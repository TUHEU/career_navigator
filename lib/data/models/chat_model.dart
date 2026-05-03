class Conversation {
  final int id;
  final int otherUserId;
  final String otherName;
  final String? otherPicture;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;

  Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherName,
    this.otherPicture,
    this.lastMessage,
    this.lastMessageAt,
    this.unreadCount = 0,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      otherUserId: json['other_user_id'] as int,
      otherName: json['other_name'] as String? ?? 'Unknown',
      otherPicture: json['other_picture'] as String?,
      lastMessage: json['last_message'] as String?,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'])
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'other_user_id': otherUserId,
      'other_name': otherName,
      'other_picture': otherPicture,
      'last_message': lastMessage,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'unread_count': unreadCount,
    };
  }

  String get formattedLastMessageTime {
    if (lastMessageAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageAt!);

    if (diff.inDays > 7) {
      return '${diff.inDays ~/ 7}w';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'now';
    }
  }

  String get displayName => otherName;
  String get displayInitial =>
      otherName.isNotEmpty ? otherName[0].toUpperCase() : '?';
}

class ChatMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String? senderPicture;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderPicture,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int? ?? 0,
      senderId: json['sender_id'] as int,
      senderName: json['sender_name'] as String? ?? 'User',
      senderPicture: json['sender_picture'] as String?,
      content: json['content'] as String? ?? '',
      isRead: json['is_read'] == 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'sender_name': senderName,
      'sender_picture': senderPicture,
      'content': content,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool isMine(int currentUserId) => senderId == currentUserId;

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 0) {
      return '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  String get fullDateTime {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year} ${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}

class MentorRequest {
  final int id;
  final int seekerId;
  final int mentorId;
  final String? seekerName;
  final String? mentorName;
  final String? message;
  final String status;
  final int? conversationId;
  final DateTime createdAt;

  MentorRequest({
    required this.id,
    required this.seekerId,
    required this.mentorId,
    this.seekerName,
    this.mentorName,
    this.message,
    this.status = 'pending',
    this.conversationId,
    required this.createdAt,
  });

  factory MentorRequest.fromJson(Map<String, dynamic> json) {
    return MentorRequest(
      id: json['id'] as int,
      seekerId: json['seeker_id'] as int? ?? 0,
      mentorId: json['mentor_id'] as int? ?? 0,
      seekerName: json['seeker_name'] as String?,
      mentorName: json['mentor_name'] as String?,
      message: json['message'] as String?,
      status: json['status'] as String? ?? 'pending',
      conversationId: json['conversation_id'] as int?,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String? body;
  final bool isRead;
  final int? referenceId;
  final String? senderName;
  final String? senderPicture;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.isRead = false,
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

    if (diff.inDays > 7) {
      return '${diff.inDays ~/ 7}w ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
