import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/bottom_nav.dart';
import '../settings/settings_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    final List<Widget> pages = [
      const _StatsPage(),
      const _UsersPage(),
      const _JobsPage(),
      const _FeedbackPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
              image: DecorationImage(
                image: AssetImage(themeProvider.backgroundPath),
                fit: BoxFit.cover,
                opacity: 0.18,
              ),
            ),
          ),
          Container(
            color: isDark
                ? AppColors.darkBackground.withOpacity(0.82)
                : Colors.white.withOpacity(0.97),
          ),
          SafeArea(child: pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          NavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
          NavItem(Icons.people_outline, Icons.people, 'Users'),
          NavItem(Icons.work_outline, Icons.work, 'Jobs'),
          NavItem(Icons.feedback_outlined, Icons.feedback, 'Feedback'),
          NavItem(Icons.settings_outlined, Icons.settings, 'Settings'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HTTP HELPERS
// FIX: all use await getAccessToken() — AuthProvider has no .accessToken getter
// ─────────────────────────────────────────────────────────────
Future<Map<String, dynamic>> _adminGet(String endpoint, String token) async {
  final res = await http.get(
    Uri.parse('${AppConstants.baseUrl}$endpoint'),
    headers: {'Authorization': 'Bearer $token'},
  );
  return jsonDecode(res.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _adminPost(
  String endpoint,
  String token,
  Map<String, dynamic> body,
) async {
  final res = await http.post(
    Uri.parse('${AppConstants.baseUrl}$endpoint'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );
  return jsonDecode(res.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _adminPut(
  String endpoint,
  String token,
  Map<String, dynamic> body,
) async {
  final res = await http.put(
    Uri.parse('${AppConstants.baseUrl}$endpoint'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: jsonEncode(body),
  );
  return jsonDecode(res.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> _adminDelete(String endpoint, String token) async {
  final res = await http.delete(
    Uri.parse('${AppConstants.baseUrl}$endpoint'),
    headers: {'Authorization': 'Bearer $token'},
  );
  return jsonDecode(res.body) as Map<String, dynamic>;
}

Widget _appBar(
  BuildContext context,
  String title,
  bool isDark, {
  List<Widget>? actions,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CAREER NAVIGATOR',
                style: TextStyle(
                  color: AppColors.cyan(isDark),
                  fontSize: 11,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: TextStyle(
                  color: AppColors.text(isDark),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (actions != null) ...actions,
      ],
    ),
  );
}

Widget _statCard(
  String label,
  String value,
  IconData icon,
  Color color,
  bool isDark,
) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.card(isDark),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border(isDark)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            color: AppColors.text(isDark),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 12),
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// PAGE 1 — STATS
// ─────────────────────────────────────────────────────────────
class _StatsPage extends StatefulWidget {
  const _StatsPage();
  @override
  State<_StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<_StatsPage> {
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // FIX: getAccessToken() is async — must await
      final token = (await context.read<AuthProvider>().getAccessToken()) ?? '';
      final res = await _adminGet('/admin/stats', token);
      if (mounted) {
        setState(() {
          _stats = res['data'] as Map<String, dynamic>?;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = e.toString();
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final user = context.watch<AuthProvider>().currentUser;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppColors.cyan(isDark),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _appBar(context, 'Admin Dashboard', isDark),
          const SizedBox(height: 20),

          // Profile card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppColors.cyan(isDark).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: AppColors.cyan(isDark).withOpacity(0.2),
                    backgroundImage: user?.profilePictureUrl != null
                        ? NetworkImage(user!.profilePictureUrl!)
                        : null,
                    child: user?.profilePictureUrl == null
                        ? Text(
                            Helpers.getInitials(user?.displayName ?? 'Admin'),
                            style: TextStyle(
                              color: AppColors.cyan(isDark),
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Administrator',
                          style: TextStyle(
                            color: AppColors.text(isDark),
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            color: AppColors.textSecondary(isDark),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cyan(isDark).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.cyan(isDark).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                color: AppColors.cyan(isDark),
                                size: 12,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Administrator',
                                style: TextStyle(
                                  color: AppColors.cyan(isDark),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Platform Overview',
              style: TextStyle(
                color: AppColors.text(isDark),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (_loading)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: [
                  _statCard(
                    'Total Users',
                    '${_stats?['total_users'] ?? 0}',
                    Icons.people,
                    Colors.blue,
                    isDark,
                  ),
                  _statCard(
                    'Mentors',
                    '${_stats?['total_mentors'] ?? 0}',
                    Icons.school,
                    Colors.purple,
                    isDark,
                  ),
                  _statCard(
                    'Job Seekers',
                    '${_stats?['total_seekers'] ?? 0}',
                    Icons.person_search,
                    Colors.teal,
                    isDark,
                  ),
                  _statCard(
                    'Active Jobs',
                    '${_stats?['total_jobs'] ?? 0}',
                    Icons.work,
                    Colors.orange,
                    isDark,
                  ),
                  _statCard(
                    'Applications',
                    '${_stats?['total_applications'] ?? 0}',
                    Icons.send,
                    Colors.green,
                    isDark,
                  ),
                  _statCard(
                    'Pending Feedback',
                    '${_stats?['pending_feedback'] ?? 0}',
                    Icons.feedback,
                    Colors.red,
                    isDark,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PAGE 2 — USER MANAGEMENT
// ─────────────────────────────────────────────────────────────
class _UsersPage extends StatefulWidget {
  const _UsersPage();
  @override
  State<_UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<_UsersPage> {
  List<dynamic> _users = [];
  List<dynamic> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // FIX: await getAccessToken()
      final token = (await context.read<AuthProvider>().getAccessToken()) ?? '';
      final res = await _adminGet('/admin/users', token);
      final data = res['data'];
      if (mounted) {
        setState(() {
          _users = data is List ? data : [];
          _filtered = _users;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filter(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? _users
          : _users.where((u) {
              final name = (u['full_name'] ?? '').toLowerCase();
              final email = (u['email'] ?? '').toLowerCase();
              final role = (u['role'] ?? '').toLowerCase();
              return name.contains(q.toLowerCase()) ||
                  email.contains(q.toLowerCase()) ||
                  role.contains(q.toLowerCase());
            }).toList();
    });
  }

  Future<void> _toggleStatus(Map user, bool active) async {
    try {
      // FIX: await getAccessToken()
      final token = (await context.read<AuthProvider>().getAccessToken()) ?? '';
      await _adminPut('/admin/users/${user['id']}/status', token, {
        'is_active': !active,
      });
      _load();
    } catch (_) {}
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.red;
      case 'mentor':
        return Colors.purple;
      default:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Column(
      children: [
        _appBar(context, 'User Management', isDark),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: _filter,
            style: TextStyle(color: AppColors.text(isDark)),
            decoration: InputDecoration(
              hintText: 'Search by name, email or role…',
              prefixIcon: const Icon(Icons.search),
              suffixText: '${_filtered.length} users',
              suffixStyle: TextStyle(
                color: AppColors.textMuted(isDark),
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final u = _filtered[i] as Map;
                      final active = (u['is_active'] ?? 0) == 1;
                      final role = u['role'] ?? 'job_seeker';
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
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: _roleColor(
                                role,
                              ).withOpacity(0.15),
                              backgroundImage: u['profile_picture_url'] != null
                                  ? NetworkImage(u['profile_picture_url'])
                                  : null,
                              child: u['profile_picture_url'] == null
                                  ? Text(
                                      Helpers.getInitials(
                                        u['full_name'] ?? 'U',
                                      ),
                                      style: TextStyle(
                                        color: _roleColor(role),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
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
                                          u['full_name'] ?? 'Unknown',
                                          style: TextStyle(
                                            color: AppColors.text(isDark),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _roleColor(
                                            role,
                                          ).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          role,
                                          style: TextStyle(
                                            color: _roleColor(role),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    u['email'] ?? '',
                                    style: TextStyle(
                                      color: AppColors.textSecondary(isDark),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        active
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        size: 12,
                                        color: active
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        active ? 'Active' : 'Deactivated',
                                        style: TextStyle(
                                          color: active
                                              ? Colors.green
                                              : Colors.red,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        (u['is_verified'] ?? 0) == 1
                                            ? Icons.verified
                                            : Icons.gpp_bad_outlined,
                                        size: 12,
                                        color: (u['is_verified'] ?? 0) == 1
                                            ? Colors.blue
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        (u['is_verified'] ?? 0) == 1
                                            ? 'Verified'
                                            : 'Unverified',
                                        style: TextStyle(
                                          color: (u['is_verified'] ?? 0) == 1
                                              ? Colors.blue
                                              : AppColors.textMuted(isDark),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (role != 'admin')
                              Switch(
                                value: active,
                                onChanged: (_) => _toggleStatus(u, active),
                                activeColor: AppColors.cyan(isDark),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PAGE 3 — JOB MANAGEMENT
// ─────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────
// PAGE 3 — JOB MANAGEMENT
// Admin can: view full details, create, delete
// ─────────────────────────────────────────────────────────────
class _JobsPage extends StatefulWidget {
  const _JobsPage();
  @override
  State<_JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<_JobsPage> {
  List<dynamic> _jobs    = [];
  bool          _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final token = (await context.read<AuthProvider>().getAccessToken()) ?? '';
      final res   = await _adminGet('/admin/jobs', token);
      final data  = res['data'];
      if (mounted) setState(() {
        _jobs    = data is List ? data : [];
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteJob(int id, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        final isDark = context.read<ThemeProvider>().isDarkMode;
        return AlertDialog(
          backgroundColor: AppColors.surface(isDark),
          title: Text('Delete Job',
              style: TextStyle(color: AppColors.text(isDark))),
          content: Text('Delete "$title"?\nThis will hide it from all users.',
              style: TextStyle(color: AppColors.textSecondary(isDark))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.textMuted(isDark)))),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red,
                      fontWeight: FontWeight.bold))),
          ],
        );
      },
    );
    if (confirm != true) return;
    try {
      final token = (await context.read<AuthProvider>().getAccessToken()) ?? '';
      await _adminDelete('/admin/jobs/$id', token);
      _load();
      if (mounted) Helpers.showSnackBar(context, 'Job deleted');
    } catch (_) {}
  }

  void _viewJob(Map<dynamic, dynamic> job) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(isDark),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, ctrl) => ListView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(isDark),
                borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.work_outline_rounded,
                    color: AppColors.primaryCyan, size: 26)),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(job['title']?.toString() ?? '', style: TextStyle(
                    color: AppColors.text(isDark),
                    fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(job['company']?.toString() ?? '',
                    style: const TextStyle(color: AppColors.primaryCyan,
                        fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              )),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  final id = job['id'];
                  if (id != null) {
                    _deleteJob(id is int ? id : int.parse(id.toString()),
                        job['title']?.toString() ?? '');
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.red.withValues(alpha: 0.3))),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.red, size: 18))),
            ]),
            const SizedBox(height: 20),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _statusChip(
                (job['is_active'] == 1 || job['is_active'] == true)
                    ? 'Active' : 'Inactive',
                (job['is_active'] == 1 || job['is_active'] == true)
                    ? Colors.green : Colors.red),
              _statusChip(
                (job['location_type'] ?? 'onsite').toString()
                    .replaceAll('_', ' '), Colors.teal),
              _statusChip(
                (job['employment_type'] ?? 'full_time').toString()
                    .replaceAll('_', ' '), Colors.blue),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              _statBox('👁️ Views',
                  '${job['views_count'] ?? 0}', isDark),
              const SizedBox(width: 12),
              _statBox('📋 Applied',
                  '${job['applications_count'] ?? 0}', isDark),
            ]),
            const SizedBox(height: 20),
            _detailRow(Icons.location_on_outlined,
                job['location']?.toString() ?? 'N/A', isDark),
            if (job['contact_email'] != null) ...[
              const SizedBox(height: 8),
              _detailRow(Icons.email_outlined,
                  job['contact_email'].toString(), isDark),
            ],
            if (job['contact_phone'] != null) ...[
              const SizedBox(height: 8),
              _detailRow(Icons.phone_outlined,
                  job['contact_phone'].toString(), isDark),
            ],
            if (job['latitude'] != null) ...[
              const SizedBox(height: 8),
              _detailRow(Icons.map_outlined,
                  '${job['latitude']}, ${job['longitude']}', isDark),
            ],
            const SizedBox(height: 20),
            if (job['description'] != null) ...[
              _sectionLabel('Description', isDark),
              const SizedBox(height: 8),
              Text(job['description'].toString(), style: TextStyle(
                color: AppColors.text(isDark),
                fontSize: 14, height: 1.6)),
              const SizedBox(height: 16),
            ],
            if (job['requirements'] != null) ...[
              _sectionLabel('Requirements', isDark),
              const SizedBox(height: 8),
              Text(job['requirements'].toString(), style: TextStyle(
                color: AppColors.textSecondary(isDark),
                fontSize: 14, height: 1.6)),
              const SizedBox(height: 16),
            ],
            if (job['responsibilities'] != null) ...[
              _sectionLabel('Responsibilities', isDark),
              const SizedBox(height: 8),
              Text(job['responsibilities'].toString(), style: TextStyle(
                color: AppColors.textSecondary(isDark),
                fontSize: 14, height: 1.6)),
              const SizedBox(height: 16),
            ],
            Text('Posted: ${job['created_at'] ?? ''}',
              style: TextStyle(
                color: AppColors.textMuted(isDark), fontSize: 12)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _statusChip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.35))),
    child: Text(label, style: TextStyle(
      color: color, fontSize: 12, fontWeight: FontWeight.w600)),
  );

  Widget _statBox(String label, String value, bool isDark) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(isDark))),
      child: Column(children: [
        Text(value, style: TextStyle(
          color: AppColors.text(isDark),
          fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(
          color: AppColors.textMuted(isDark), fontSize: 11)),
      ]),
    ),
  );

  Widget _detailRow(IconData icon, String text, bool isDark) =>
    Row(children: [
      Icon(icon, color: AppColors.primaryCyan, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(
        color: AppColors.textSecondary(isDark), fontSize: 13))),
    ]);

  Widget _sectionLabel(String text, bool isDark) => Text(text,
    style: TextStyle(color: AppColors.text(isDark),
        fontSize: 15, fontWeight: FontWeight.bold));

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8)),
    child: Text(label.replaceAll('_', ' '),
      style: TextStyle(color: color,
          fontSize: 10, fontWeight: FontWeight.w600)),
  );

  Future<void> _showCreateJobDialog() async {
    final titleCtrl   = TextEditingController();
    final companyCtrl = TextEditingController();
    final locCtrl     = TextEditingController();
    final descCtrl    = TextEditingController();
    final reqCtrl     = TextEditingController();
    final respCtrl    = TextEditingController();
    String locType    = 'onsite';
    String empType    = 'full_time';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final isDark = context.read<ThemeProvider>().isDarkMode;
        return StatefulBuilder(builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Job Listing', style: TextStyle(
                color: AppColors.text(isDark),
                fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _tf(titleCtrl,   'Job Title *',       isDark),
              const SizedBox(height: 10),
              _tf(companyCtrl, 'Company *',          isDark),
              const SizedBox(height: 10),
              _tf(locCtrl,     'Location *',         isDark),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: locType,
                dropdownColor: AppColors.surface(isDark),
                style: TextStyle(color: AppColors.text(isDark)),
                decoration: InputDecoration(
                  labelText: 'Location Type',
                  labelStyle: TextStyle(
                      color: AppColors.textSecondary(isDark))),
                items: ['onsite','remote','hybrid'].map((e) =>
                    DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setS(() => locType = v!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: empType,
                dropdownColor: AppColors.surface(isDark),
                style: TextStyle(color: AppColors.text(isDark)),
                decoration: InputDecoration(
                  labelText: 'Employment Type',
                  labelStyle: TextStyle(
                      color: AppColors.textSecondary(isDark))),
                items: ['full_time','part_time','contract',
                    'internship','freelance'].map((e) =>
                    DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v) => setS(() => empType = v!),
              ),
              const SizedBox(height: 10),
              _tf(descCtrl, 'Description *',      isDark, lines: 3),
              const SizedBox(height: 10),
              _tf(reqCtrl,  'Requirements *',     isDark, lines: 3),
              const SizedBox(height: 10),
              _tf(respCtrl, 'Responsibilities *', isDark, lines: 3),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  if ([titleCtrl, companyCtrl, locCtrl,
                       descCtrl, reqCtrl, respCtrl]
                      .any((c) => c.text.trim().isEmpty)) return;
                  final token = (await context
                      .read<AuthProvider>().getAccessToken()) ?? '';
                  final res = await _adminPost('/admin/jobs', token, {
                    'title':            titleCtrl.text.trim(),
                    'company':          companyCtrl.text.trim(),
                    'location':         locCtrl.text.trim(),
                    'location_type':    locType,
                    'employment_type':  empType,
                    'description':      descCtrl.text.trim(),
                    'requirements':     reqCtrl.text.trim(),
                    'responsibilities': respCtrl.text.trim(),
                  });
                  if (context.mounted) Navigator.pop(ctx);
                  _load();
                  if (mounted) Helpers.showSnackBar(context,
                    res['success'] == true ? 'Job created!' : 'Failed');
                },
                child: Container(
                  width: double.infinity, height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryCyan, Color(0xFF0097A7)]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                      color: AppColors.primaryCyan.withValues(alpha: 0.4),
                      blurRadius: 16, offset: const Offset(0, 4))]),
                  child: const Center(child: Text('CREATE JOB',
                    style: TextStyle(color: Colors.black,
                        fontWeight: FontWeight.w800, letterSpacing: 1))),
                ),
              ),
            ],
          )),
        ));
      },
    );
  }

  Widget _tf(TextEditingController c, String label, bool isDark,
      {int lines = 1}) =>
    TextField(
      controller: c, maxLines: lines,
      style: TextStyle(color: AppColors.text(isDark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary(isDark)),
        filled: true, fillColor: AppColors.inputFill(isDark),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border(isDark))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: AppColors.primaryCyan, width: 2))),
    );

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Column(children: [
      _appBar(context, 'Job Management', isDark, actions: [
        IconButton(
          icon: Icon(Icons.add_circle_outline,
              color: AppColors.cyan(isDark)),
          tooltip: 'Create Job',
          onPressed: _showCreateJobDialog),
      ]),
      const SizedBox(height: 14),
      Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(
              color: AppColors.primaryCyan))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppColors.primaryCyan,
              child: _jobs.isEmpty
                  ? Center(child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.work_off_outlined, size: 48,
                            color: AppColors.textMuted(isDark)),
                        const SizedBox(height: 12),
                        Text('No jobs found',
                            style: TextStyle(
                                color: AppColors.textMuted(isDark))),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _showCreateJobDialog,
                          icon: const Icon(Icons.add,
                              color: AppColors.primaryCyan),
                          label: const Text('Create first job',
                              style: TextStyle(
                                  color: AppColors.primaryCyan))),
                      ]))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _jobs.length,
                      itemBuilder: (_, i) {
                        final j      = _jobs[i] as Map;
                        final active = j['is_active'] == 1 ||
                                       j['is_active'] == true;
                        return GestureDetector(
                          onTap: () => _viewJob(j),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.card(isDark),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: active
                                  ? AppColors.border(isDark)
                                  : Colors.red.withValues(alpha: 0.3))),
                            child: Row(children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryCyan
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12)),
                                child: Icon(Icons.work_outline_rounded,
                                    color: AppColors.primaryCyan,
                                    size: 22)),
                              const SizedBox(width: 12),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(j['title']?.toString() ?? '',
                                    style: TextStyle(
                                      color: AppColors.text(isDark),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${j['company']} · ${j['location']}',
                                    style: TextStyle(
                                      color: AppColors.textSecondary(isDark),
                                      fontSize: 12)),
                                  const SizedBox(height: 4),
                                  Wrap(spacing: 6, children: [
                                    _chip(j['employment_type']?.toString()
                                        ?? '', Colors.blue),
                                    _chip(j['location_type']?.toString()
                                        ?? '', Colors.teal),
                                    if (!active)
                                      _chip('Inactive', Colors.red),
                                  ]),
                                ],
                              )),
                              Icon(Icons.chevron_right_rounded,
                                  color: AppColors.textMuted(isDark),
                                  size: 20),
                            ]),
                          ),
                        );
                      }),
            )),
    ]);
  }
}

class _FeedbackPage extends StatefulWidget {
  const _FeedbackPage();
  @override
  State<_FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<_FeedbackPage> {
  List<dynamic> _all = [];
  List<dynamic> _filtered = [];
  bool _loading = true;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      // FIX: await getAccessToken()
      final token = (await context.read<AuthProvider>().getAccessToken()) ?? '';
      final res = await _adminGet('/admin/feedback', token);
      final data = res['data'];
      if (mounted) {
        setState(() {
          _all = data is List ? data : [];
          _loading = false;
          _applyFilter(_filter);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter(String f) {
    setState(() {
      _filter = f;
      _filtered = f == 'all'
          ? _all
          : _all.where((fb) => (fb['status'] ?? '') == f).toList();
    });
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      // FIX: await getAccessToken()
      final token = (await context.read<AuthProvider>().getAccessToken()) ?? '';
      await _adminPut('/admin/feedback/$id/status', token, {'status': status});
      _load();
      if (mounted) Helpers.showSnackBar(context, 'Marked as $status');
    } catch (_) {}
  }

  void _showDetail(Map fb, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              fb['subject'] ?? 'Feedback',
              style: TextStyle(
                color: AppColors.text(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'From: ${fb['full_name'] ?? 'Unknown'} (${fb['email'] ?? ''})',
              style: TextStyle(
                color: AppColors.textSecondary(isDark),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Category: ${fb['category'] ?? 'General'}  |  Rating: ${fb['rating'] ?? '-'}',
              style: TextStyle(
                color: AppColors.textMuted(isDark),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: Text(
                fb['message'] ?? '',
                style: TextStyle(
                  color: AppColors.text(isDark),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.rate_review_outlined, size: 16),
                    label: const Text('Mark Reviewed'),
                    onPressed: () {
                      Navigator.pop(context);
                      _updateStatus(fb['id'], 'reviewed');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Resolve'),
                    onPressed: () {
                      Navigator.pop(context);
                      _updateStatus(fb['id'], 'resolved');
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'resolved':
        return Colors.green;
      case 'reviewed':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Column(
      children: [
        _appBar(context, 'Feedback', isDark),
        const SizedBox(height: 12),

        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['all', 'pending', 'reviewed', 'resolved'].map((f) {
                final sel = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f[0].toUpperCase() + f.substring(1)),
                    selected: sel,
                    onSelected: (_) => _applyFilter(f),
                    selectedColor: AppColors.cyan(isDark).withOpacity(0.2),
                    checkmarkColor: AppColors.cyan(isDark),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${_filtered.length} item${_filtered.length == 1 ? '' : 's'}',
              style: TextStyle(
                color: AppColors.textMuted(isDark),
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No feedback found',
                            style: TextStyle(
                              color: AppColors.textMuted(isDark),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final fb = _filtered[i] as Map;
                            final status = fb['status'] ?? 'pending';
                            return GestureDetector(
                              onTap: () => _showDetail(fb, isDark),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppColors.card(isDark),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: AppColors.border(isDark),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(9),
                                      decoration: BoxDecoration(
                                        color: _statusColor(
                                          status,
                                        ).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.feedback_outlined,
                                        color: _statusColor(status),
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fb['subject'] ?? '',
                                            style: TextStyle(
                                              color: AppColors.text(isDark),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            fb['full_name'] ?? 'Unknown',
                                            style: TextStyle(
                                              color: AppColors.textSecondary(
                                                isDark,
                                              ),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            (fb['message'] ?? '')
                                                        .toString()
                                                        .length >
                                                    60
                                                ? '${fb['message'].toString().substring(0, 60)}…'
                                                : fb['message'] ?? '',
                                            style: TextStyle(
                                              color: AppColors.textMuted(
                                                isDark,
                                              ),
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _statusColor(
                                              status,
                                            ).withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              color: _statusColor(status),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Icon(
                                          Icons.chevron_right,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}
