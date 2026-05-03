import 'package:flutter/material.dart';
import '../data/models/chat_model.dart';
import '../data/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();

  List<Conversation> _conversations = [];
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount =>
      _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  Future<void> loadConversations() async {
    _setLoading(true);
    _clearError();

    try {
      _conversations = await _chatRepository.getConversations();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> loadMessages(int conversationId) async {
    _setLoading(true);
    _clearError();

    try {
      _messages = await _chatRepository.getMessages(conversationId);
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<bool> sendMessage(int recipientId, String content) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _chatRepository.sendMessage(recipientId, content);
      _setLoading(false);
      return response['success'] == true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> refresh() async {
    await loadConversations();
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
