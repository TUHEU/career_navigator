import '../datasources/remote/api_service.dart';
import '../datasources/local/token_store.dart';

class Conversation {
  final int id;
  final int otherUserId;
  final String otherName;
  final String? otherPicture;
  final String? lastMessage;
  final String? lastMessageAt;
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
      lastMessageAt: json['last_message_at'] as String?,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }
}

class Message {
  final int id;
  final int senderId;
  final String senderName;
  final String? senderPicture;
  final String content;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderPicture,
    required this.content,
    required this.isRead,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      senderId: json['sender_id'] as int,
      senderName: json['sender_name'] as String? ?? 'User',
      senderPicture: json['sender_picture'] as String?,
      content: json['content'] as String? ?? '',
      isRead: json['is_read'] == 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isMine => false; // Will be set based on current user
}

class ChatRepository {
  final ApiService _apiService = ApiService();
  final TokenStore _tokenStore = TokenStore();

  Future<List<Conversation>> getConversations() async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.getConversations(token);

    if (response['success'] == true) {
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Conversation.fromJson(json)).toList();
    }
    throw Exception(response['message'] ?? 'Failed to load conversations');
  }

  Future<List<Message>> getMessages(int conversationId) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.getMessages(
      token: token,
      conversationId: conversationId,
    );

    if (response['success'] == true) {
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Message.fromJson(json)).toList();
    }
    throw Exception(response['message'] ?? 'Failed to load messages');
  }

  Future<Map<String, dynamic>> sendMessage(
    int recipientId,
    String content,
  ) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.sendMessage(
      token: token,
      recipientId: recipientId,
      content: content,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to send message');
    }
    return response;
  }
}
