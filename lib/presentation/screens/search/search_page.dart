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
  final _searchCtrl = TextEditingController();
  TabController? _tabCtrl;

  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _mentors  = [];
  List<Map<String, dynamic>> _seekers  = [];

  bool   _isLoading   = false;
  bool   _hasSearched = false;
  int?   _sendingTo;
  int?   _currentUid;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _currentUid = context.read<AuthProvider>().currentUser?.id;
        _loadAll();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tabCtrl?.dispose();
    super.dispose();
  }

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // ── Load all users ────────────────────────────────────────
  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final token =
          await context.read<AuthProvider>().getAccessToken() ?? '';
      final res = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}/users'),
            headers: _headers(token),
          )
          .timeout(AppConstants.connectionTimeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (mounted && body['success'] == true) {
        final data  = body['data'] as Map<String, dynamic>;
        final users = List<Map<String, dynamic>>.from(data['users'] ?? []);
        setState(() {
          _allUsers    = users;
          _mentors     = users.where((u) => u['role'] == 'mentor').toList();
          _seekers     = users.where((u) => u['role'] == 'job_seeker').toList();
          _hasSearched = true;
          _isLoading   = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Search ────────────────────────────────────────────────
  Future<void> _search() async {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) { _loadAll(); return; }

    setState(() => _isLoading = true);
    try {
      final token =
          await context.read<AuthProvider>().getAccessToken() ?? '';
      final uri = Uri.parse(
        '${AppConstants.baseUrl}/users?q=${Uri.encodeComponent(q)}',
      );
      final res = await http
          .get(uri, headers: _headers(token))
          .timeout(AppConstants.connectionTimeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (mounted && body['success'] == true) {
        final data  = body['data'] as Map<String, dynamic>;
        final users = List<Map<String, dynamic>>.from(data['users'] ?? []);
        setState(() {
          _allUsers    = users;
          _mentors     = users.where((u) => u['role'] == 'mentor').toList();
          _seekers     = users.where((u) => u['role'] == 'job_seeker').toList();
          _hasSearched = true;
          _isLoading   = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Connect & open chat ───────────────────────────────────
  Future<void> _connect(Map<String, dynamic> user) async {
    final id            = user['id']        as int?    ?? 0;
    final recipientName = user['full_name'] as String? ?? 'User';

    if (_sendingTo != null) return;
    setState(() => _sendingTo = id);

    try {
      final token =
          await context.read<AuthProvider>().getAccessToken() ?? '';
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}/requests'),
            headers: _headers(token),
            body: jsonEncode({'recipient_id': id}),
          )
          .timeout(AppConstants.connectionTimeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;

      if (!mounted) return;

      if (body['success'] == true) {
        for (final list in [_allUsers, _mentors, _seekers]) {
          for (final u in list) {
            if (u['id'] == id) u['already_connected'] = 1;
          }
        }
        setState(() {});

        final conversationId =
            (body['data'] as Map<String, dynamic>?)?['conversation_id'] as int?;

        if (conversationId != null && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(
                conversationId: conversationId,
                recipientId:    id,
                recipientName:  recipientName,
              ),
            ),
          );
        } else {
          Helpers.showSnackBar(context, 'Connected with $recipientName!');
        }
      } else {
        Helpers.showSnackBar(
          context,
          body['message'] as String? ?? 'Failed to connect',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) Helpers.showSnackBar(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _sendingTo = null);
    }
  }

  // ── Open existing chat ────────────────────────────────────
  Future<void> _openExistingChat(Map<String, dynamic> user) async {
    final id            = user['id']        as int?    ?? 0;
    final recipientName = user['full_name'] as String? ?? 'User';

    try {
      final token =
          await context.read<AuthProvider>().getAccessToken() ?? '';
      final res = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}/chat/conversations'),
            headers: _headers(token),
          )
          .timeout(AppConstants.connectionTimeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (body['success'] == true) {
        final convs =
            List<Map<String, dynamic>>.from(body['data'] ?? []);
        final conv = convs.firstWhere(
          (c) => c['other_user_id'] == id,
          orElse: () => {},
        );
        if (conv.isNotEmpty && mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatPage(
                conversationId: conv['id'] as int,
                recipientId:    id,
                recipientName:  recipientName,
              ),
            ),
          );
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      Helpers.showSnackBar(context, 'Could not open conversation');
    }
  }

  // ── User card ─────────────────────────────────────────────
  Widget _userCard(Map<String, dynamic> user, bool isDark, LanguageProvider lang) {
    final id        = user['id']                 as int?    ?? 0;
    final name      = user['full_name']           as String? ?? 'User';
    final picture   = user['profile_picture_url'] as String?;
    final role      = user['role']                as String? ?? '';
    final headline  = user['headline']            as String?;
    final jobTitle  = user['current_job_title']   as String?;
    final rating    = user['rating'];
    final connected = (user['already_connected']  as int?) == 1;
    final isSending = _sendingTo == id;
    final canConnect = id != _currentUid;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Row(
        children: [
          // Avatar
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

          // Info
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
                          color: AppColors.text(isDark),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    // Role badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: (role == 'mentor'
                                ? AppColors.primaryCyan
                                : Colors.purple)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: (role == 'mentor'
                                  ? AppColors.primaryCyan
                                  : Colors.purple)
                              .withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        role == 'mentor'
                            ? lang.t(S.mentor)
                            : lang.t(S.jobSeeker),
                        style: TextStyle(
                          color: role == 'mentor'
                              ? AppColors.primaryCyan
                              : Colors.purple,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (headline != null || jobTitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    headline ?? jobTitle ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textSecondary(isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
                if (role == 'mentor' && rating != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC107), size: 13),
                      const SizedBox(width: 3),
                      Text(
                        (rating as num).toStringAsFixed(1),
                        style: TextStyle(
                          color: AppColors.textMuted(isDark),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── FIX: Connect button — use intrinsic width, never unbounded ──
          if (canConnect) ...[
            const SizedBox(width: 8),
            connected
                ? GestureDetector(
                    onTap: () => _openExistingChat(user),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.green.withOpacity(0.4)),
                      ),
                      child: Text(
                        lang.isFrench ? 'Message' : 'Message',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 34,
                    // ✅ Fixed: explicit width prevents BoxConstraints crash
                    width: 88,
                    child: ElevatedButton(
                      onPressed: isSending ? null : () => _connect(user),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCyan,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isSending
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : Text(
                              lang.isFrench ? 'Connecter' : 'Connect',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
          ],
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────
  Widget _empty(String msg, bool isDark) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline,
                  size: 56,
                  color: AppColors.textMuted(isDark).withOpacity(0.4)),
              const SizedBox(height: 12),
              Text(msg,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textMuted(isDark), fontSize: 14)),
            ],
          ),
        ),
      );

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final lang   = context.watch<LanguageProvider>();

    final labelAll      = lang.isFrench ? 'Tous (${_allUsers.length})' : 'All (${_allUsers.length})';
    final labelMentors  = lang.isFrench ? 'Mentors (${_mentors.length})' : 'Mentors (${_mentors.length})';
    final labelSeekers  = lang.isFrench ? 'Chercheurs (${_seekers.length})' : 'Seekers (${_seekers.length})';
    final hintSearch    = lang.isFrench ? 'Rechercher par nom...' : 'Search by name or title...';
    final hintInfo      = lang.isFrench
        ? 'Appuyez sur Connecter pour démarrer une conversation'
        : 'Tap Connect to start a conversation with anyone';
    final titleDiscover = lang.isFrench ? 'Découvrir' : 'Discover People';

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: Text(titleDiscover),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl!,
          labelColor: AppColors.primaryCyan,
          unselectedLabelColor: AppColors.textMuted(isDark),
          indicatorColor: AppColors.primaryCyan,
          tabs: [
            Tab(text: labelAll),
            Tab(text: labelMentors),
            Tab(text: labelSeekers),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    style: TextStyle(color: AppColors.text(isDark)),
                    decoration: InputDecoration(
                      hintText: hintSearch,
                      hintStyle:
                          TextStyle(color: AppColors.textMuted(isDark)),
                      prefixIcon: const Icon(Icons.search,
                          color: AppColors.primaryCyan),
                      filled: true,
                      fillColor: AppColors.inputFill(isDark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onSubmitted: (_) => _search(),
                    onChanged: (v) {
                      if (v.isEmpty) _loadAll();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _search,
                  icon: const Icon(Icons.search),
                  color: AppColors.primaryCyan,
                  style: IconButton.styleFrom(
                    backgroundColor:
                        AppColors.primaryCyan.withOpacity(0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hint
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Icon(Icons.info_outline,
                    size: 14,
                    color: AppColors.primaryCyan.withOpacity(0.8)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hintInfo,
                    style: TextStyle(
                        color: AppColors.textMuted(isDark), fontSize: 12),
                  ),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: _isLoading
                ? const LoadingIndicator()
                : TabBarView(
                    controller: _tabCtrl!,
                    children: [
                      _allUsers.isEmpty
                          ? _empty(
                              _hasSearched
                                  ? (lang.isFrench
                                      ? 'Aucun utilisateur trouvé'
                                      : 'No users found')
                                  : (lang.isFrench
                                      ? 'Chargement...'
                                      : 'Loading...'),
                              isDark)
                          : RefreshIndicator(
                              onRefresh: _loadAll,
                              color: AppColors.primaryCyan,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 4, 16, 16),
                                itemCount: _allUsers.length,
                                itemBuilder: (_, i) =>
                                    _userCard(_allUsers[i], isDark, lang),
                              ),
                            ),
                      _mentors.isEmpty
                          ? _empty(
                              lang.isFrench
                                  ? 'Aucun mentor trouvé'
                                  : 'No mentors found',
                              isDark)
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 4, 16, 16),
                              itemCount: _mentors.length,
                              itemBuilder: (_, i) =>
                                  _userCard(_mentors[i], isDark, lang),
                            ),
                      _seekers.isEmpty
                          ? _empty(
                              lang.isFrench
                                  ? 'Aucun chercheur trouvé'
                                  : 'No job seekers found',
                              isDark)
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 4, 16, 16),
                              itemCount: _seekers.length,
                              itemBuilder: (_, i) =>
                                  _userCard(_seekers[i], isDark, lang),
                            ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
