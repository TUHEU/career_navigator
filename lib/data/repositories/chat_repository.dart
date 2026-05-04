import '../datasources/remote/api_service.dart';
import '../datasources/local/token_store.dart';
import '../models/chat_model.dart';

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

  Future<List<ChatMessage>> getMessages(int conversationId) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');
    final response = await _apiService.getMessages(
      token: token,
      conversationId: conversationId,
    );
    if (response['success'] == true) {
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    }
    throw Exception(response['message'] ?? 'Failed to load messages');
  }

  Future<void> sendMessage(int recipientId, String content) async {
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
  }
}
