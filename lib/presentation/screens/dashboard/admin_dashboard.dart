// presentation/screens/dashboard/admin_dashboard.dart — v11
// Full admin panel: overview stats, user management, job moderation,
// feedback inbox, analytics charts
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/datasources/local/token_store.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/loading_widgets.dart';
import '../auth/sign_in_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final pages = [
      const _AdminOverviewTab(),
      const _AdminUsersTab(),
      const _AdminJobsTab(),
      const _AdminFeedbackTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: AppColors.surface(isDark),
        indicatorColor: AppColors.primaryCyan.withOpacity(0.15),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard, color: AppColors.primaryCyan),
              label: 'Overview'),
          NavigationDestination(icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people, color: AppColors.primaryCyan),
              label: 'Users'),
          NavigationDestination(icon: Icon(Icons.work_outline),
              selectedIcon: Icon(Icons.work, color: AppColors.primaryCyan),
              label: 'Jobs'),
          NavigationDestination(icon: Icon(Icons.feedback_outlined),
              selectedIcon: Icon(Icons.feedback, color: AppColors.primaryCyan),
              label: 'Feedback'),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  TAB 1: OVERVIEW
// ═══════════════════════════════════════════════════════════════
class _AdminOverviewTab extends StatefulWidget {
  const _AdminOverviewTab();
  @override
  State<_AdminOverviewTab> createState() => _AdminOverviewTabState();
}

class _AdminOverviewTabState extends State<_AdminOverviewTab> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final token = await TokenStore().getAccess();
    final res = await ApiService().getAdminStats(token ?? '');
    if (mounted) {
      setState(() {
        if (res['success'] == true) _stats = res['data'] as Map<String, dynamic>?;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final auth   = context.watch<AuthProvider>();

    return SafeArea(child: RefreshIndicator(
      color: AppColors.primaryCyan,
      onRefresh: _load,
      child: CustomScrollView(slivers: [
        SliverAppBar(
          floating: true, backgroundColor: AppColors.background(isDark),
          elevation: 0,
          title: Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryCyan.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: AppColors.primaryCyan, size: 20)),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Admin Panel', style: TextStyle(
                color: AppColors.primaryCyan, fontSize: 10,
                letterSpacing: 1.5, fontWeight: FontWeight.w800)),
              Text(auth.currentUser?.fullName ?? 'Administrator',
                style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 11)),
            ]),
          ]),
          actions: [
            IconButton(
              icon: Icon(Icons.logout_rounded, color: AppColors.text(isDark)),
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const SignInPage()),
                    (_) => false);
                }
              }),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          sliver: SliverList(delegate: SliverChildListDelegate([
            if (_loading)
              const SkeletonList(count: 4, cardHeight: 90)
            else if (_stats == null)
              _ErrorBox(isDark: isDark, onRetry: _load)
            else ...[

              Text('Platform Overview', style: TextStyle(
                color: AppColors.text(isDark), fontSize: 20,
                fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Real-time platform statistics', style: TextStyle(
                color: AppColors.textMuted(isDark), fontSize: 13)),
              const SizedBox(height: 20),

              // KPI grid
              GridView.count(
                crossAxisCount: 2, shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12, mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _KpiCard('Total Users', '${_stats!['total_users'] ?? 0}',
                    Icons.people_rounded, AppColors.primaryCyan, isDark),
                  _KpiCard('Mentors', '${_stats!['total_mentors'] ?? 0}',
                    Icons.school_rounded, const Color(0xFF7C3AED), isDark),
                  _KpiCard('Job Seekers', '${_stats!['total_seekers'] ?? 0}',
                    Icons.search_rounded, const Color(0xFF059669), isDark),
                  _KpiCard('New Today', '${_stats!['new_users_today'] ?? 0}',
                    Icons.person_add_rounded, const Color(0xFFF59E0B), isDark),
                  _KpiCard('Active Jobs', '${_stats!['active_jobs'] ?? 0}',
                    Icons.work_rounded, const Color(0xFF3B82F6), isDark),
                  _KpiCard('Applications', '${_stats!['total_applications'] ?? 0}',
                    Icons.send_rounded, const Color(0xFFEC4899), isDark),
                  _KpiCard('Hired', '${_stats!['total_hired'] ?? 0}',
                    Icons.celebration_rounded, const Color(0xFF10B981), isDark),
                  _KpiCard('Connections', '${_stats!['total_connections'] ?? 0}',
                    Icons.hub_rounded, const Color(0xFF6366F1), isDark),
                ],
              ),
              const SizedBox(height: 24),

              // Secondary stats row
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card(isDark), borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border(isDark))),
                child: Column(children: [
                  _MetricRow('Pending Mentor Requests',
                    '${_stats!['pending_requests'] ?? 0}',
                    Icons.pending_actions_rounded, isDark),
                  const Divider(height: 24),
                  _MetricRow('AI Messages Sent Total',
                    '${_stats!['ai_messages_total'] ?? 0}',
                    Icons.auto_awesome_rounded, isDark),
                  const Divider(height: 24),
                  _MetricRow('Community Posts',
                    '${_stats!['total_posts'] ?? 0}',
                    Icons.forum_rounded, isDark),
                  const Divider(height: 24),
                  _MetricRow('Pending Feedback',
                    '${_stats!['pending_feedback'] ?? 0}',
                    Icons.feedback_rounded, isDark, highlight: true),
                ]),
              ),
            ],
          ])),
        ),
      ]),
    ));
  }
}

class _KpiCard extends StatelessWidget {
  final String label, value; final IconData icon;
  final Color color; final bool isDark;
  const _KpiCard(this.label, this.value, this.icon, this.color, this.isDark);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: color.withOpacity(isDark ? 0.08 : 0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 20),
      const Spacer(),
      Text(value, style: TextStyle(
        color: AppColors.text(isDark), fontSize: 22, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 10),
        maxLines: 1, overflow: TextOverflow.ellipsis),
    ]),
  );
}

class _MetricRow extends StatelessWidget {
  final String label, value; final IconData icon;
  final bool isDark, highlight;
  const _MetricRow(this.label, this.value, this.icon, this.isDark,
      {this.highlight = false});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: highlight ? AppColors.warning : AppColors.primaryCyan, size: 18),
    const SizedBox(width: 10),
    Expanded(child: Text(label, style: TextStyle(
      color: AppColors.textSecondary(isDark), fontSize: 13))),
    Text(value, style: TextStyle(
      color: highlight ? AppColors.warning : AppColors.text(isDark),
      fontWeight: FontWeight.bold, fontSize: 14)),
  ]);
}

// ═══════════════════════════════════════════════════════════════
//  TAB 2: USERS
// ═══════════════════════════════════════════════════════════════
class _AdminUsersTab extends StatefulWidget {
  const _AdminUsersTab();
  @override
  State<_AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<_AdminUsersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  List<Map<String, dynamic>> _users = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  static const _roles = ['All', 'Job Seekers', 'Mentors', 'Admins'];
  static const _roleKeys = ['', 'job_seeker', 'mentor', 'admin'];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
    _tab.addListener(() { if (_tab.indexIsChanging) _load(); });
    _load();
  }

  @override
  void dispose() { _tab.dispose(); _searchCtrl.dispose(); super.dispose(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final token = await TokenStore().getAccess();
    final role  = _roleKeys[_tab.index];
    final res = await ApiService().adminGetUsers(token ?? '', role: role);
    if (mounted) {
      setState(() {
        if (res['success'] == true) {
          _users = List<Map<String, dynamic>>.from(res['data'] ?? []);
        }
        _loading = false;
      });
    }
  }

  Future<void> _toggleActive(int userId, bool currentActive) async {
    final token = await TokenStore().getAccess();
    await ApiService().adminToggleUserActive(token ?? '', userId, !currentActive);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return SafeArea(child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Text('User Management', style: TextStyle(
          color: AppColors.text(isDark), fontSize: 22, fontWeight: FontWeight.bold))),
      TabBar(
        controller: _tab, isScrollable: true, tabAlignment: TabAlignment.start,
        labelColor: AppColors.primaryCyan,
        unselectedLabelColor: AppColors.textMuted(isDark),
        indicatorColor: AppColors.primaryCyan, indicatorWeight: 2,
        dividerColor: AppColors.border(isDark),
        tabs: _roles.map((r) => Tab(text: r)).toList()),
      Expanded(child: _loading
          ? const LoadingIndicator()
          : _users.isEmpty
            ? Center(child: Text('No users found', style: TextStyle(
                color: AppColors.textMuted(isDark))))
            : RefreshIndicator(
                color: AppColors.primaryCyan, onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  itemCount: _users.length,
                  itemBuilder: (_, i) {
                    final u = _users[i];
                    final isActive = (u['is_active'] as num?)?.toInt() == 1;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card(isDark),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border(isDark))),
                      child: Row(children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppColors.primaryCyan.withOpacity(0.15),
                          backgroundImage: u['profile_picture_url'] != null
                              ? NetworkImage(u['profile_picture_url']) : null,
                          child: u['profile_picture_url'] == null
                              ? Text((u['full_name'] ?? '?')
                                  .toString().substring(0,1).toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.primaryCyan, fontWeight: FontWeight.bold))
                              : null),
                        const SizedBox(width: 12),
                        Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(u['full_name'] ?? 'User', style: TextStyle(
                            color: AppColors.text(isDark),
                            fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(u['email'] ?? '', style: TextStyle(
                            color: AppColors.textMuted(isDark), fontSize: 11)),
                          const SizedBox(height: 4),
                          Row(children: [
                            _RoleBadge(u['role'] ?? 'job_seeker'),
                            const SizedBox(width: 6),
                            if ((u['is_verified'] as num?)?.toInt() == 1)
                              const Icon(Icons.verified_rounded,
                                  color: Color(0xFF059669), size: 14),
                          ]),
                        ])),
                        Switch(
                          value: isActive,
                          activeColor: AppColors.primaryCyan,
                          onChanged: (_) => _toggleActive(
                              (u['id'] as num).toInt(), isActive)),
                      ]),
                    );
                  },
                ),
              )),
    ]));
  }
}

class _RoleBadge extends StatelessWidget {
  final String role;
  const _RoleBadge(this.role);
  Color get _color {
    switch (role) {
      case 'admin':  return const Color(0xFFEF4444);
      case 'mentor': return const Color(0xFF7C3AED);
      default:       return AppColors.primaryCyan;
    }
  }
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _color.withOpacity(0.3))),
    child: Text(role.replaceAll('_', ' '), style: TextStyle(
      color: _color, fontSize: 9, fontWeight: FontWeight.bold)));
}

// ═══════════════════════════════════════════════════════════════
//  TAB 3: JOBS
// ═══════════════════════════════════════════════════════════════
class _AdminJobsTab extends StatefulWidget {
  const _AdminJobsTab();
  @override
  State<_AdminJobsTab> createState() => _AdminJobsTabState();
}

class _AdminJobsTabState extends State<_AdminJobsTab> {
  List<Map<String, dynamic>> _jobs = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final token = await TokenStore().getAccess();
    final res = await ApiService().adminGetJobs(token ?? '');
    if (mounted) {
      setState(() {
        if (res['success'] == true) {
          _jobs = List<Map<String, dynamic>>.from(res['data'] ?? []);
        }
        _loading = false;
      });
    }
  }

  Future<void> _deactivate(int jobId) async {
    final token = await TokenStore().getAccess();
    await ApiService().adminDeactivateJob(token ?? '', jobId);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return SafeArea(child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Row(children: [
          Expanded(child: Text('Job Moderation', style: TextStyle(
            color: AppColors.text(isDark), fontSize: 22, fontWeight: FontWeight.bold))),
          Text('${_jobs.length} jobs', style: TextStyle(
            color: AppColors.textMuted(isDark), fontSize: 13)),
        ])),
      Expanded(child: _loading
          ? const LoadingIndicator()
          : RefreshIndicator(
              color: AppColors.primaryCyan, onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: _jobs.length,
                itemBuilder: (_, i) {
                  final j = _jobs[i];
                  final isActive = (j['is_active'] as num?)?.toInt() == 1;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.card(isDark), borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isActive
                          ? AppColors.border(isDark)
                          : AppColors.danger.withOpacity(0.3))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(j['title'] ?? '', style: TextStyle(
                          color: AppColors.text(isDark),
                          fontWeight: FontWeight.bold, fontSize: 14))),
                        if (!isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                            child: const Text('Inactive', style: TextStyle(
                              color: AppColors.danger, fontSize: 9,
                              fontWeight: FontWeight.bold))),
                      ]),
                      Text(j['company'] ?? '', style: const TextStyle(
                        color: AppColors.primaryCyan, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Icon(Icons.people_outline, size: 14,
                            color: AppColors.textMuted(isDark)),
                        const SizedBox(width: 4),
                        Text('${j['applications_count'] ?? 0} applications',
                          style: TextStyle(
                            color: AppColors.textMuted(isDark), fontSize: 11)),
                        const Spacer(),
                        if (isActive)
                          TextButton(
                            onPressed: () => _deactivate((j['id'] as num).toInt()),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              padding: const EdgeInsets.symmetric(horizontal: 10)),
                            child: const Text('Deactivate',
                                style: TextStyle(fontSize: 12))),
                      ]),
                    ]),
                  );
                },
              ),
            )),
    ]));
  }
}

// ═══════════════════════════════════════════════════════════════
//  TAB 4: FEEDBACK
// ═══════════════════════════════════════════════════════════════
class _AdminFeedbackTab extends StatefulWidget {
  const _AdminFeedbackTab();
  @override
  State<_AdminFeedbackTab> createState() => _AdminFeedbackTabState();
}

class _AdminFeedbackTabState extends State<_AdminFeedbackTab> {
  List<Map<String, dynamic>> _feedback = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final token = await TokenStore().getAccess();
    final res = await ApiService().adminGetFeedback(token ?? '');
    if (mounted) {
      setState(() {
        if (res['success'] == true) {
          _feedback = List<Map<String, dynamic>>.from(res['data'] ?? []);
        }
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return SafeArea(child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Text('Feedback Inbox', style: TextStyle(
          color: AppColors.text(isDark), fontSize: 22, fontWeight: FontWeight.bold))),
      Expanded(child: _loading
          ? const LoadingIndicator()
          : _feedback.isEmpty
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.inbox_outlined, size: 64, color: AppColors.textMuted(isDark)),
                const SizedBox(height: 12),
                Text('No feedback yet', style: TextStyle(
                  color: AppColors.textMuted(isDark))),
              ]))
            : RefreshIndicator(
                color: AppColors.primaryCyan, onRefresh: _load,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: _feedback.length,
                  itemBuilder: (_, i) {
                    final f = _feedback[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.card(isDark), borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border(isDark))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(children: [
                          Expanded(child: Text(f['subject'] ?? 'Feedback', style: TextStyle(
                            color: AppColors.text(isDark),
                            fontWeight: FontWeight.bold, fontSize: 14))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                            child: Text(f['category'] ?? 'General', style: const TextStyle(
                              color: AppColors.warning, fontSize: 9,
                              fontWeight: FontWeight.bold))),
                        ]),
                        const SizedBox(height: 6),
                        Text(f['message'] ?? '', style: TextStyle(
                          color: AppColors.textSecondary(isDark), fontSize: 12, height: 1.5)),
                      ]),
                    );
                  },
                ),
              )),
    ]));
  }
}

class _ErrorBox extends StatelessWidget {
  final bool isDark; final VoidCallback onRetry;
  const _ErrorBox({required this.isDark, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(
    padding: const EdgeInsets.all(40),
    child: Column(children: [
      Icon(Icons.error_outline, size: 56, color: AppColors.textMuted(isDark)),
      const SizedBox(height: 12),
      Text('Could not load admin data', style: TextStyle(
        color: AppColors.text(isDark), fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ElevatedButton(onPressed: onRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCyan, foregroundColor: Colors.black),
        child: const Text('Retry')),
    ]),
  ));
}
