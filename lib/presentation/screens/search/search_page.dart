// presentation/screens/search/search_page.dart
// v9 — Redesigned: mentor cards with expertise tags, connect button,
//       tabbed All/Mentors/Seekers, profile avatars, TalentBridge-inspired
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/loading_widgets.dart';
import '../chat/chat_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  final _ctrl  = TextEditingController();
  late TabController _tab;

  List<Map<String, dynamic>> _all = [], _mentors = [], _seekers = [];
  bool _loading = false, _searched = false;
  int? _connecting, _currentUid;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentUid = context.read<AuthProvider>().currentUser?.id;
      _loadAll();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); _tab.dispose(); super.dispose(); }

  Map<String, String> _headers(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  };

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final token = await context.read<AuthProvider>().getAccessToken() ?? '';
      final res = await http.get(
        Uri.parse('${AppConstants.baseUrl}/users'),
        headers: _headers(token),
      ).timeout(AppConstants.connectionTimeout);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (mounted && body['success'] == true) {
        final data  = body['data'] as Map<String, dynamic>;
        final users = List<Map<String, dynamic>>.from(data['users'] ?? []);
        setState(() {
          _all      = users;
          _mentors  = users.where((u) => u['role'] == 'mentor').toList();
          _seekers  = users.where((u) => u['role'] == 'job_seeker').toList();
          _searched = true;
          _loading  = false;
        });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _search() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty) { _loadAll(); return; }
    setState(() => _loading = true);
    try {
      final token = await context.read<AuthProvider>().getAccessToken() ?? '';
      final res = await http.get(
        Uri.parse('${AppConstants.baseUrl}/users/search?q=${Uri.encodeComponent(q)}'),
        headers: _headers(token),
      ).timeout(AppConstants.connectionTimeout);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (mounted && body['success'] == true) {
        final users = List<Map<String, dynamic>>.from(body['data'] ?? []);
        setState(() {
          _all      = users;
          _mentors  = users.where((u) => u['role'] == 'mentor').toList();
          _seekers  = users.where((u) => u['role'] == 'job_seeker').toList();
          _searched = true;
          _loading  = false;
        });
      } else {
        if (mounted) setState(() => _loading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _connect(Map<String, dynamic> user) async {
    final uid = user['id'] as int;
    if (uid == _currentUid) return;
    setState(() => _connecting = uid);
    try {
      final token = await context.read<AuthProvider>().getAccessToken() ?? '';
      final res = await http.post(
        Uri.parse('${AppConstants.baseUrl}/connections/request'),
        headers: _headers(token),
        body: jsonEncode({'addressee_id': uid}),
      ).timeout(AppConstants.connectionTimeout);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (mounted) {
        if (body['success'] == true) {
          Helpers.showSnackBar(context, '✅ Connection request sent!');
        } else {
          Helpers.showSnackBar(context,
            body['message'] ?? 'Already connected', isError: true);
        }
      }
    } catch (_) {
      if (mounted) Helpers.showSnackBar(context, 'Connection failed', isError: true);
    } finally {
      if (mounted) setState(() => _connecting = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final lang   = context.watch<LanguageProvider>();

    final tabs = [_all, _mentors, _seekers];
    final labels = ['All (${_all.length})', 'Mentors', 'Job Seekers'];

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(child: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Discover People', style: TextStyle(
              color: AppColors.text(isDark), fontSize: 24,
              fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Connect with mentors & professionals', style: TextStyle(
              color: AppColors.textMuted(isDark), fontSize: 13)),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              style: TextStyle(color: AppColors.text(isDark)),
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search by name, skills, role...',
                hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryCyan),
                suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (_ctrl.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, color: AppColors.textMuted(isDark), size: 18),
                      onPressed: () { _ctrl.clear(); _loadAll(); }),
                  IconButton(
                    icon: const Icon(Icons.search, color: AppColors.primaryCyan, size: 20),
                    onPressed: _search),
                ]),
                filled: true, fillColor: AppColors.card(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border(isDark))),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryCyan))),
            ),
          ]),
        ),
        TabBar(
          controller: _tab,
          labelColor: AppColors.primaryCyan,
          unselectedLabelColor: AppColors.textMuted(isDark),
          indicatorColor: AppColors.primaryCyan, indicatorWeight: 2,
          dividerColor: AppColors.border(isDark),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: labels.map((l) => Tab(text: l)).toList(),
        ),
        Expanded(child: _loading
          ? const LoadingIndicator()
          : TabBarView(controller: _tab,
              children: tabs.map((list) => list.isEmpty
                ? _EmptyState(isDark: isDark)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _UserCard(
                      user: list[i], isDark: isDark,
                      isMe: list[i]['id'] == _currentUid,
                      isConnecting: _connecting == list[i]['id'],
                      onConnect: () => _connect(list[i]),
                      onMessage: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ChatPage(
                          conversationId: 0,
                          recipientId: list[i]['id'] as int,
                          recipientName: list[i]['full_name'] ?? 'User'))),
                    ),
                  )
              ).toList()),
        ),
      ])),
    );
  }
}

// ── User Card ─────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isDark, isMe, isConnecting;
  final VoidCallback onConnect, onMessage;
  const _UserCard({
    required this.user, required this.isDark,
    required this.isMe, required this.isConnecting,
    required this.onConnect, required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final role    = user['role'] as String? ?? 'job_seeker';
    final isMentor= role == 'mentor';
    final name    = user['full_name'] as String? ?? 'User';
    final headline= user['headline'] as String? ?? role.replaceAll('_', ' ');
    final avatar  = user['profile_picture_url'] as String?;
    final loc     = user['location'] as String?;
    final skills  = user['skills'] is List
        ? (user['skills'] as List).take(3).map((s) => s.toString()).toList()
        : <String>[];

    final roleColor = isMentor ? const Color(0xFF7C3AED) : AppColors.primaryCyan;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(isDark))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Avatar
        Stack(children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: roleColor.withOpacity(0.15),
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(color: roleColor, fontWeight: FontWeight.bold, fontSize: 18)) : null,
          ),
          if (isMentor)
            Positioned(bottom: 0, right: 0, child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(
                color: Color(0xFF7C3AED), shape: BoxShape.circle),
              child: const Icon(Icons.school, color: Colors.white, size: 10),
            )),
        ]),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(name, style: TextStyle(
              color: AppColors.text(isDark), fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: roleColor.withOpacity(0.3))),
              child: Text(isMentor ? 'Mentor' : 'Seeker', style: TextStyle(
                color: roleColor, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(height: 2),
          Text(headline, style: TextStyle(
            color: AppColors.textSecondary(isDark), fontSize: 12),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          if (loc != null) ...[
            const SizedBox(height: 3),
            Row(children: [
              Icon(Icons.location_on_outlined, size: 11,
                  color: AppColors.textMuted(isDark)),
              const SizedBox(width: 2),
              Text(loc, style: TextStyle(
                color: AppColors.textMuted(isDark), fontSize: 11)),
            ]),
          ],
          if (skills.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(spacing: 4, children: skills.map((s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryCyan.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryCyan.withOpacity(0.2))),
              child: Text(s, style: const TextStyle(
                color: AppColors.primaryCyan, fontSize: 10)),
            )).toList()),
          ],
          if (!isMe) ...[
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: isConnecting ? null : onConnect,
                icon: isConnecting
                    ? const SizedBox(width: 12, height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.person_add_outlined, size: 14),
                label: Text(isConnecting ? '...' : 'Connect',
                    style: const TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  foregroundColor: AppColors.primaryCyan,
                  side: BorderSide(color: AppColors.primaryCyan.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              )),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton.icon(
                onPressed: onMessage,
                icon: const Icon(Icons.chat_bubble_outline, size: 14),
                label: const Text('Message', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  backgroundColor: AppColors.primaryCyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
              )),
            ]),
          ],
        ])),
      ]),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted(isDark)),
      const SizedBox(height: 12),
      Text('No users found', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 16, fontWeight: FontWeight.bold)),
    ],
  ));
}
