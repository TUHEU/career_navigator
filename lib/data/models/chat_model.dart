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

  String get formattedTime {
    if (lastMessageAt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(lastMessageAt!);
    if (diff.inDays > 7) return '${diff.inDays ~/ 7}w';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
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

  bool isMine(int currentUserId) => senderId == currentUserId;

  String get formattedTime {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inDays > 0)
      return '${createdAt.hour}:${createdAt.minute.toString().padLeft(2, '0')}';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }
}
