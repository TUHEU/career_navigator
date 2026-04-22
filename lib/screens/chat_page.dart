import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_store.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────
// Conversations list page
// ─────────────────────────────────────────────────────────
class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  List<dynamic> _convs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final token = await TokenStore.getAccess();
      if (token == null) return;
      final res = await ApiService.getConversations(token);
      if (res['success'] == true && mounted) {
        setState(() {
          _convs = (res['data'] as List<dynamic>?) ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Messages', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryCyan),
            )
          : _convs.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white12,
                    size: 60,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No conversations yet',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Accept a mentorship request to start chatting.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.2),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primaryCyan,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _convs.length,
                itemBuilder: (_, i) {
                  final c = _convs[i] as Map<String, dynamic>;
                  final name = c['other_name'] ?? 'Unknown';
                  final picture = c['other_picture'] as String?;
                  final lastMsg = c['last_message'] ?? '';
                  final lastTime = c['last_message_at'] ?? '';
                  final convId = c['id'] as int;
                  final otherId = c['other_user_id'] as int;

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
                    ).then((_) => _load()),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.07),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.primaryCyan.withOpacity(
                              0.2,
                            ),
                            backgroundImage: picture != null
                                ? NetworkImage(picture)
                                : null,
                            child: picture == null
                                ? Text(
                                    name.isNotEmpty ? name[0] : '?',
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
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  lastMsg,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.45),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            lastTime.length > 10
                                ? lastTime.substring(0, 10)
                                : lastTime,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Chat page (one conversation)
// ─────────────────────────────────────────────────────────
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
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  List<dynamic> _msgs = [];
  bool _loading = false;
  bool _sending = false;
  String? _myId;

  @override
  void initState() {
    super.initState();
    _loadMyId();
    _loadMessages();
  }

  Future<void> _loadMyId() async {
    final token = await TokenStore.getAccess();
    if (token == null) return;
    final res = await ApiService.getProfile(token);
    if (res['success'] == true && mounted) {
      setState(() => _myId = res['data']['id'].toString());
    }
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    try {
      final token = await TokenStore.getAccess();
      if (token == null) return;
      final res = await ApiService.getMessages(
        token: token,
        conversationId: widget.conversationId,
      );
      if (res['success'] == true && mounted) {
        setState(() {
          _msgs = (res['data'] as List<dynamic>?) ?? [];
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() => _sending = true);
    try {
      final token = await TokenStore.getAccess();
      if (token == null) return;
      final res = await ApiService.sendMessage(
        token: token,
        recipientId: widget.recipientId,
        content: text,
      );
      if (res['success'] == true) _loadMessages();
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to send')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients)
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.recipientName,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryCyan,
                    ),
                  )
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.all(16),
                    itemCount: _msgs.length,
                    itemBuilder: (_, i) {
                      final m = _msgs[i] as Map<String, dynamic>;
                      final mine = m['sender_id'].toString() == _myId;
                      return _Bubble(msg: m, isMine: mine);
                    },
                  ),
          ),

          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    style: const TextStyle(color: Colors.white),
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.06),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sending ? null : _send,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryCyan,
                      shape: BoxShape.circle,
                    ),
                    child: _sending
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
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final Map<String, dynamic> msg;
  final bool isMine;
  const _Bubble({required this.msg, required this.isMine});

  @override
  Widget build(BuildContext context) {
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
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          border: isMine
              ? null
              : Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              msg['content'] ?? '',
              style: TextStyle(
                color: isMine ? Colors.black : Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              (msg['created_at'] ?? '').toString().length > 16
                  ? msg['created_at'].toString().substring(11, 16)
                  : '',
              style: TextStyle(
                color: isMine
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white.withOpacity(0.3),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
