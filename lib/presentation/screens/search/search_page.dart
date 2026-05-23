import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/loading_widgets.dart';

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
  List<Map<String, dynamic>> _mentors = [];
  List<Map<String, dynamic>> _seekers = [];

  bool _isLoading = false;
  bool _hasSearched = false;
  int? _sendingTo;
  String _currentRole = '';

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    // Load role and users after first frame so context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _currentRole = context.read<AuthProvider>().currentUser?.role ?? '';
        });
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

  // ── Load all users (no search query) ─────────────────────
  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final token = await context.read<AuthProvider>().getAccessToken() ?? '';
      final res = await http
          .get(
            Uri.parse('${AppConstants.baseUrl}/users'),
            headers: _headers(token),
          )
          .timeout(AppConstants.connectionTimeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (mounted && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        final users = List<Map<String, dynamic>>.from(data['users'] ?? []);
        setState(() {
          _allUsers = users;
          _mentors = users.where((u) => u['role'] == 'mentor').toList();
          _seekers = users.where((u) => u['role'] == 'job_seeker').toList();
          _hasSearched = true;
          _isLoading = false;
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
    if (q.isEmpty) {
      _loadAll();
      return;
    }

    setState(() => _isLoading = true);
    try {
      final token = await context.read<AuthProvider>().getAccessToken() ?? '';
      final uri = Uri.parse(
        '${AppConstants.baseUrl}/users?q=${Uri.encodeComponent(q)}',
      );
      final res = await http
          .get(uri, headers: _headers(token))
          .timeout(AppConstants.connectionTimeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (mounted && body['success'] == true) {
        final data = body['data'] as Map<String, dynamic>;
        final users = List<Map<String, dynamic>>.from(data['users'] ?? []);
        setState(() {
          _allUsers = users;
          _mentors = users.where((u) => u['role'] == 'mentor').toList();
          _seekers = users.where((u) => u['role'] == 'job_seeker').toList();
          _hasSearched = true;
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Invite user ───────────────────────────────────────────
  Future<void> _invite(int recipientId) async {
    if (_sendingTo != null) return;
    setState(() => _sendingTo = recipientId);

    try {
      final token = await context.read<AuthProvider>().getAccessToken() ?? '';
      final res = await http
          .post(
            Uri.parse('${AppConstants.baseUrl}/requests'),
            headers: _headers(token),
            body: jsonEncode({'recipient_id': recipientId}),
          )
          .timeout(AppConstants.connectionTimeout);

      final body = jsonDecode(res.body) as Map<String, dynamic>;
      if (mounted) {
        if (body['success'] == true) {
          Helpers.showSnackBar(context, 'Invite sent!');
          // Mark as connected in UI
          setState(() {
            for (final list in [_allUsers, _mentors, _seekers]) {
              for (final u in list) {
                if (u['id'] == recipientId) u['already_connected'] = 1;
              }
            }
          });
        } else {
          Helpers.showSnackBar(
            context,
            body['message'] as String? ?? 'Failed to send invite',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) Helpers.showSnackBar(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _sendingTo = null);
    }
  }

  // ── User card ─────────────────────────────────────────────
  Widget _userCard(Map<String, dynamic> user, bool isDark) {
    final id = user['id'] as int? ?? 0;
    final name = user['full_name'] as String? ?? 'User';
    final picture = user['profile_picture_url'] as String?;
    final role = user['role'] as String? ?? '';
    final headline = user['headline'] as String?;
    final jobTitle = user['current_job_title'] as String?;
    final rating = user['rating'];
    final connected = (user['already_connected'] as int?) == 1;
    final isSending = _sendingTo == id;

    // Only job seekers can invite; can't invite yourself
    final currentUid = context.read<AuthProvider>().currentUser?.id;
    final canInvite = _currentRole == 'job_seeker' && id != currentUid;

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
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (role == 'mentor'
                                    ? AppColors.primaryCyan
                                    : Colors.purple)
                                .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              (role == 'mentor'
                                      ? AppColors.primaryCyan
                                      : Colors.purple)
                                  .withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        role == 'mentor' ? 'Mentor' : 'Job Seeker',
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
                      const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFC107),
                        size: 13,
                      ),
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

          // Invite button — only for job seekers
          if (canInvite) ...[
            const SizedBox(width: 8),
            connected
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.4)),
                    ),
                    child: const Text(
                      'Connected',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      onPressed: isSending ? null : () => _invite(id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryCyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                          : const Text(
                              'Invite',
                              style: TextStyle(
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
          Icon(
            Icons.people_outline,
            size: 56,
            color: AppColors.textMuted(isDark).withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 14),
          ),
        ],
      ),
    ),
  );

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: const Text('Discover People'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabCtrl!,
          labelColor: AppColors.primaryCyan,
          unselectedLabelColor: AppColors.textMuted(isDark),
          indicatorColor: AppColors.primaryCyan,
          tabs: [
            Tab(text: 'All (${_allUsers.length})'),
            Tab(text: 'Mentors (${_mentors.length})'),
            Tab(text: 'Seekers (${_seekers.length})'),
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
                      hintText: 'Search by name or title...',
                      hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.primaryCyan,
                      ),
                      filled: true,
                      fillColor: AppColors.inputFill(isDark),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                    backgroundColor: AppColors.primaryCyan.withOpacity(0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Note for job seekers
          if (_currentRole == 'job_seeker')
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.primaryCyan.withOpacity(0.8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Tap Invite to connect with anyone',
                    style: TextStyle(
                      color: AppColors.textMuted(isDark),
                      fontSize: 12,
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
                      // All
                      _allUsers.isEmpty
                          ? _empty(
                              _hasSearched ? 'No users found' : 'Loading...',
                              isDark,
                            )
                          : RefreshIndicator(
                              onRefresh: _loadAll,
                              color: AppColors.primaryCyan,
                              child: ListView.builder(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  4,
                                  16,
                                  16,
                                ),
                                itemCount: _allUsers.length,
                                itemBuilder: (_, i) =>
                                    _userCard(_allUsers[i], isDark),
                              ),
                            ),
                      // Mentors
                      _mentors.isEmpty
                          ? _empty('No mentors found', isDark)
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              itemCount: _mentors.length,
                              itemBuilder: (_, i) =>
                                  _userCard(_mentors[i], isDark),
                            ),
                      // Job seekers
                      _seekers.isEmpty
                          ? _empty('No job seekers found', isDark)
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              itemCount: _seekers.length,
                              itemBuilder: (_, i) =>
                                  _userCard(_seekers[i], isDark),
                            ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
