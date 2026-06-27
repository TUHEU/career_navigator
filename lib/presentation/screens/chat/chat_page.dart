// presentation/screens/chat/chat_page.dart
// v9 — Full redesign: conversation list with avatars, unread badges,
//       online indicators, message bubbles, timestamp grouping
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/loading_widgets.dart';

// ── Conversations list ────────────────────────────────────────────
class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});
  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  final ApiService _api = ApiService();
  List<Map<String, dynamic>> _convs = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) return;
    final res = await _api.getConversations(token);
    if (mounted && res['success'] == true) {
      setState(() {
        _convs  = List<Map<String, dynamic>>.from(res['data'] ?? []);
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Messages', style: TextStyle(
              color: AppColors.text(isDark), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Your conversations', style: TextStyle(
              color: AppColors.textMuted(isDark), fontSize: 13)),
          ]),
        ),
        Expanded(child: _loading
          ? const LoadingIndicator(message: 'Loading conversations...')
          : _convs.isEmpty
            ? _EmptyConvs(isDark: isDark)
            : RefreshIndicator(
                onRefresh: _load, color: AppColors.primaryCyan,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _convs.length,
                  itemBuilder: (_, i) => _ConvTile(
                    conv: _convs[i], isDark: isDark,
                    onTap: () {
                      final other = _convs[i]['other_user']
                          as Map<String, dynamic>? ?? {};
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ChatPage(
                          conversationId: _convs[i]['id'] as int,
                          recipientId: other['id'] as int? ?? 0,
                          recipientName: other['full_name'] as String? ?? 'User'),
                      )).then((_) => _load());
                    },
                  ),
                )),
        ),
      ])),
    );
  }
}

class _ConvTile extends StatelessWidget {
  final Map<String, dynamic> conv; final bool isDark; final VoidCallback onTap;
  const _ConvTile({required this.conv, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final other   = conv['other_user'] as Map<String, dynamic>? ?? {};
    final name    = other['full_name'] as String? ?? 'User';
    final avatar  = other['profile_picture_url'] as String?;
    final last    = conv['last_message'] as String? ?? '';
    final unread  = (conv['unread_count'] as int? ?? 0);
    final hasNew  = unread > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: hasNew
              ? AppColors.primaryCyan.withOpacity(isDark ? 0.07 : 0.04)
              : AppColors.card(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hasNew
              ? AppColors.primaryCyan.withOpacity(0.25)
              : AppColors.border(isDark))),
        child: Row(children: [
          Stack(children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryCyan.withOpacity(0.15),
              backgroundImage: avatar != null ? NetworkImage(avatar) : null,
              child: avatar == null ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: AppColors.primaryCyan, fontWeight: FontWeight.bold)) : null,
            ),
            Positioned(bottom: 0, right: 0, child: Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E), shape: BoxShape.circle,
                border: Border.all(color: AppColors.background(isDark), width: 2)))),
          ]),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: TextStyle(
              color: AppColors.text(isDark),
              fontWeight: hasNew ? FontWeight.bold : FontWeight.w500,
              fontSize: 14)),
            const SizedBox(height: 2),
            Text(last, style: TextStyle(
              color: AppColors.textMuted(isDark), fontSize: 12),
              maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
          if (hasNew)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryCyan, borderRadius: BorderRadius.circular(12)),
              child: Text('$unread', style: const TextStyle(
                color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold))),
        ]),
      ),
    );
  }
}

class _EmptyConvs extends StatelessWidget {
  final bool isDark;
  const _EmptyConvs({required this.isDark});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.chat_bubble_outline_rounded, size: 72, color: AppColors.textMuted(isDark)),
      const SizedBox(height: 16),
      Text('No conversations yet', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text('Connect with a mentor to start chatting', style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 13)),
    ],
  ));
}

// ═══════════════════════════════════════════════════════════════
//  CHAT PAGE (individual conversation)
// ═══════════════════════════════════════════════════════════════
class ChatPage extends StatefulWidget {
  final int conversationId, recipientId;
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
  final ApiService _api = ApiService();
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  List<Map<String, dynamic>> _msgs = [];
  bool _loading = true;
  bool _sending = false;
  int? _myUid;

  @override
  void initState() {
    super.initState();
    _myUid = context.read<AuthProvider>().currentUser?.id;
    _load();
  }

  @override
  void dispose() { _msgCtrl.dispose(); _scrollCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) return;
    final res = await _api.getMessages(
      token: token, conversationId: widget.conversationId);
    if (mounted && res['success'] == true) {
      setState(() {
        _msgs = List<Map<String, dynamic>>.from(res['data'] ?? []);
        _loading = false;
      });
      _scrollToBottom();
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _sending) return;
    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) return;

    setState(() { _sending = true; _msgCtrl.clear(); });

    // Optimistic UI
    setState(() => _msgs.add({
      'sender_id': _myUid,
      'content': text,
      'created_at': DateTime.now().toIso8601String(),
      '_optimistic': true,
    }));
    _scrollToBottom();

    final res = await _api.sendMessage(
      token: token,
      recipientId: widget.recipientId,
      content: text,
    );

    if (mounted) {
      setState(() => _sending = false);
      if (res['success'] == true) {
        _load();
      } else {
        // Remove optimistic
        setState(() => _msgs.removeLast());
        Helpers.showSnackBar(context, res['message'] ?? 'Failed to send', isError: true);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        backgroundColor: AppColors.background(isDark), elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(isDark)),
        title: Row(children: [
          CircleAvatar(radius: 18,
            backgroundColor: AppColors.primaryCyan.withOpacity(0.15),
            child: Text(widget.recipientName.isNotEmpty
                ? widget.recipientName[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primaryCyan, fontWeight: FontWeight.bold))),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.recipientName, style: TextStyle(
              color: AppColors.text(isDark), fontSize: 16, fontWeight: FontWeight.bold)),
            const Text('Online', style: TextStyle(
              color: Color(0xFF22C55E), fontSize: 11)),
          ]),
        ]),
      ),
      body: Column(children: [
        Expanded(child: _loading
          ? const LoadingIndicator()
          : _msgs.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.waving_hand_outlined, size: 48,
                    color: AppColors.textMuted(isDark)),
                const SizedBox(height: 12),
                Text('Say hello! 👋', style: TextStyle(
                  color: AppColors.textMuted(isDark), fontSize: 14)),
              ]))
            : ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                itemCount: _msgs.length,
                itemBuilder: (_, i) {
                  final msg   = _msgs[i];
                  final isMe  = msg['sender_id'] == _myUid;
                  final text  = msg['content'] as String? ?? '';
                  final time  = msg['created_at'] as String?;
                  return _Bubble(
                    text: text, isMe: isMe, time: time, isDark: isDark,
                    isOptimistic: msg['_optimistic'] == true);
                }),
        ),

        // Input row
        Container(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom + 10),
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            border: Border(top: BorderSide(color: AppColors.border(isDark)))),
          child: Row(children: [
            Expanded(child: TextField(
              controller: _msgCtrl,
              style: TextStyle(color: AppColors.text(isDark)),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
                filled: true, fillColor: AppColors.card(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.primaryCyan.withOpacity(0.5))),
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10)),
              onSubmitted: (_) => _send(),
            )),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _send,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: _sending
                      ? AppColors.primaryCyan.withOpacity(0.5)
                      : AppColors.primaryCyan,
                  shape: BoxShape.circle),
                child: _sending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.black))
                    : const Icon(Icons.send_rounded, color: Colors.black, size: 20)),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ── Chat bubble ───────────────────────────────────────────────────
class _Bubble extends StatelessWidget {
  final String text; final bool isMe, isDark, isOptimistic;
  final String? time;
  const _Bubble({
    required this.text, required this.isMe,
    required this.isDark, required this.isOptimistic,
    this.time,
  });

  String _formatTime(String? raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    } catch (_) { return ''; }
  }

  @override
  Widget build(BuildContext context) => Align(
    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.primaryCyan.withOpacity(isDark ? 0.85 : 1)
            : AppColors.card(isDark),
        borderRadius: BorderRadius.only(
          topLeft:     const Radius.circular(18),
          topRight:    const Radius.circular(18),
          bottomLeft:  Radius.circular(isMe ? 18 : 4),
          bottomRight: Radius.circular(isMe ? 4 : 18)),
        border: isMe ? null : Border.all(color: AppColors.border(isDark))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text(text, style: TextStyle(
          color: isMe ? Colors.black : AppColors.text(isDark),
          fontSize: 14, height: 1.4)),
        const SizedBox(height: 3),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(_formatTime(time), style: TextStyle(
            color: isMe ? Colors.black.withOpacity(0.5) : AppColors.textMuted(isDark),
            fontSize: 10)),
          if (isMe && isOptimistic) ...[
            const SizedBox(width: 4),
            Icon(Icons.schedule, size: 10,
                color: Colors.black.withOpacity(0.4)),
          ] else if (isMe) ...[
            const SizedBox(width: 4),
            Icon(Icons.done_all, size: 12,
                color: Colors.black.withOpacity(0.5)),
          ],
        ]),
      ]),
    ),
  );
}
