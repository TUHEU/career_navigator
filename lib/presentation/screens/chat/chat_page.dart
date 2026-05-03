import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/loading_widgets.dart';

class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) return;

    final response = await _apiService.getConversations(token);
    if (mounted && response['success'] == true) {
      setState(() {
        _conversations = List<Map<String, dynamic>>.from(
          response['data'] ?? [],
        );
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Messages')),
      body: _isLoading
          ? const LoadingIndicator()
          : _conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No conversations yet',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey.shade500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Send an invite to a mentor to start chatting.',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadConversations,
              color: AppColors.primaryCyan,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _conversations.length,
                itemBuilder: (_, i) =>
                    _buildConversationCard(_conversations[i], isDark),
              ),
            ),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conv, bool isDark) {
    final name = conv['other_name'] ?? 'Unknown';
    final picture = conv['other_picture'] as String?;
    final lastMsg = conv['last_message'] ?? '';
    final lastTime = conv['last_message_at'] ?? '';
    final convId = conv['id'] as int;
    final otherId = conv['other_user_id'] as int;
    final unread = conv['unread_count'] as int? ?? 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(
            conversationId: convId,
            recipientId: otherId,
            recipientName: name,
          ),
        ),
      ).then((_) => _loadConversations()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
              backgroundImage: picture != null ? NetworkImage(picture) : null,
              child: picture == null
                  ? Text(
                      Helpers.getInitials(name),
                      style: const TextStyle(
                        color: AppColors.primaryCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.lightText,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (unread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCyan,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$unread',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.45)
                          : AppColors.lightTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              Helpers.getRelativeTime(lastTime),
              style: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final int conversationId;
  final int recipientId;
  final String recipientName;
  const ChatPage({
    super.key,
    required this.conversationId,
    required this.recipientId,
    required this.recipientName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _loadMessages();
  }

  Future<void> _loadCurrentUser() async {
    _currentUserId = context.read<AuthProvider>().currentUser?.id;
  }

  Future<void> _loadMessages() async {
    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) return;

    final response = await _apiService.getMessages(
      token: token,
      conversationId: widget.conversationId,
    );
    if (mounted && response['success'] == true) {
      setState(() {
        _messages = List<Map<String, dynamic>>.from(response['data'] ?? []);
        _isLoading = false;
      });
      _scrollToBottom();
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() => _isSending = true);

    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) return;

    final response = await _apiService.sendMessage(
      token: token,
      recipientId: widget.recipientId,
      content: text,
    );

    if (mounted) {
      setState(() => _isSending = false);
      if (response['success'] == true) {
        await _loadMessages();
      } else {
        Helpers.showSnackBar(context, 'Failed to send message', isError: true);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(title: Text(widget.recipientName)),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const LoadingIndicator()
                : _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 60,
                          color: isDark ? Colors.white24 : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.5)
                                : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Send a message to start the conversation',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white.withOpacity(0.3)
                                : Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (_, index) => _buildMessageBubble(
                      _messages[_messages.length - 1 - index],
                      isDark,
                    ),
                  ),
          ),
          _buildMessageInput(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isDark) {
    final isMine = message['sender_id'] == _currentUserId;
    final content = message['content'] ?? '';
    final createdAt = message['created_at'] ?? '';

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMine
              ? AppColors.primaryCyan.withOpacity(0.85)
              : (isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.grey.shade200),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          border: isMine
              ? null
              : Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.grey.shade300,
                ),
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              content,
              style: TextStyle(
                color: isMine
                    ? Colors.black
                    : (isDark ? Colors.white : AppColors.lightText),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              Helpers.getRelativeTime(createdAt),
              style: TextStyle(
                color: isMine
                    ? Colors.black.withOpacity(0.5)
                    : (isDark
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey.shade500),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.lightText,
              ),
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.3)
                      : Colors.grey.shade500,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _isSending ? null : _sendMessage,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.primaryCyan,
                shape: BoxShape.circle,
              ),
              child: _isSending
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.black, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
