import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/token_store.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'sign_in_page.dart';
import 'settings_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  Map<String, dynamic>? _profile;
  bool _loading = true;
  List<dynamic> _users = [];
  List<dynamic> _feedbacks = [];
  List<dynamic> _reports = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadUsers();
    _loadFeedback();
    _loadReports();
  }

  Future<void> _loadProfile() async {
    try {
      final token = await TokenStore.getAccess();
      if (token == null) {
        _logout();
        return;
      }
      final res = await ApiService.getProfile(token);
      if (mounted) {
        if (res['success'] == true) {
          setState(() {
            _profile = res['data'] as Map<String, dynamic>;
            _loading = false;
          });
        } else {
          _logout();
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadUsers() async {
    // This would need a backend endpoint - for now, showing placeholder
    setState(() {
      _users = [];
    });
  }

  Future<void> _loadFeedback() async {
    // This would need a backend endpoint - for now, showing placeholder
    setState(() {
      _feedbacks = [];
    });
  }

  Future<void> _loadReports() async {
    // This would need a backend endpoint - for now, showing placeholder
    setState(() {
      _reports = [];
    });
  }

  Future<void> _logout() async {
    await TokenStore.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppThemeProvider>();
    final pages = [
      _AdminHomePage(
        profile: _profile,
        loading: _loading,
        onRefresh: _loadProfile,
      ),
      _AdminUsersPage(users: _users, onRefresh: _loadUsers),
      _AdminFeedbackPage(feedback: _feedbacks, onRefresh: _loadFeedback),
      _AdminReportsPage(reports: _reports, onRefresh: _loadReports),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              image: DecorationImage(
                image: AssetImage(theme.backgroundPath),
                fit: BoxFit.cover,
                opacity: 0.18,
              ),
            ),
          ),
          Container(color: AppColors.darkBackground.withOpacity(0.80)),
          SafeArea(child: pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          NavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
          NavItem(Icons.people_outline, Icons.people, 'Users'),
          NavItem(Icons.feedback_outlined, Icons.feedback, 'Feedback'),
          NavItem(Icons.assessment_outlined, Icons.assessment, 'Reports'),
          NavItem(Icons.settings_outlined, Icons.settings, 'Settings'),
        ],
      ),
    );
  }
}

class _AdminHomePage extends StatelessWidget {
  final Map<String, dynamic>? profile;
  final bool loading;
  final VoidCallback onRefresh;

  const _AdminHomePage({
    required this.profile,
    required this.loading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryCyan),
      );
    }

    final p = profile ?? {};
    final name = p['full_name'] ?? 'Admin';
    final email = p['email'] ?? '';

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CAREER NAVIGATOR',
                    style: TextStyle(
                      color: AppColors.primaryCyan,
                      fontSize: 11,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProfileCard(
            name: name,
            headline: 'System Administrator',
            email: email,
            pictureUrl: null,
            badge: 'Admin',
            badgeIcon: Icons.admin_panel_settings,
          ),
          const SizedBox(height: 24),
          const SectionTitle(title: 'Platform Overview'),
          const SizedBox(height: 12),
          Row(
            children: [
              _AdminStatCard(
                title: 'Total Users',
                value: '156',
                icon: Icons.people,
                color: AppColors.primaryCyan,
              ),
              const SizedBox(width: 12),
              _AdminStatCard(
                title: 'Mentors',
                value: '42',
                icon: Icons.school,
                color: Colors.greenAccent,
              ),
              const SizedBox(width: 12),
              _AdminStatCard(
                title: 'Job Seekers',
                value: '114',
                icon: Icons.search,
                color: Colors.amber,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _AdminStatCard(
                title: 'Jobs Posted',
                value: '28',
                icon: Icons.work,
                color: Colors.blueAccent,
              ),
              const SizedBox(width: 12),
              _AdminStatCard(
                title: 'Applications',
                value: '67',
                icon: Icons.description,
                color: Colors.purpleAccent,
              ),
              const SizedBox(width: 12),
              _AdminStatCard(
                title: 'Pending Feedback',
                value: '12',
                icon: Icons.feedback,
                color: Colors.orangeAccent,
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildActivitySection(),
          const SizedBox(height: 20),
          const ComingSoonBanner(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline, color: AppColors.primaryCyan, size: 18),
              SizedBox(width: 8),
              Text(
                'Recent Activity',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _activityItem(
            'New user registered',
            'john.doe@example.com joined as Job Seeker',
            '2 min ago',
          ),
          const Divider(color: Colors.white10, height: 20),
          _activityItem(
            'Job posted',
            'Tech Corp posted a Senior Developer position',
            '15 min ago',
          ),
          const Divider(color: Colors.white10, height: 20),
          _activityItem(
            'Mentor request accepted',
            'Sarah Johnson accepted a mentoring request',
            '1 hour ago',
          ),
        ],
      ),
    );
  }

  Widget _activityItem(String title, String subtitle, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 10),
        ),
      ],
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminUsersPage extends StatelessWidget {
  final List<dynamic> users;
  final VoidCallback onRefresh;

  const _AdminUsersPage({required this.users, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const PageHeader(
            title: 'User Management',
            subtitle: 'Manage platform users',
          ),
          const SizedBox(height: 20),
          if (users.isEmpty)
            const EmptyState(
              icon: Icons.people_outline,
              message:
                  'No users found.\nThis feature requires additional backend endpoints.',
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _AdminFeedbackPage extends StatelessWidget {
  final List<dynamic> feedback;
  final VoidCallback onRefresh;

  const _AdminFeedbackPage({required this.feedback, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const PageHeader(
            title: 'User Feedback',
            subtitle: 'Review and respond to user feedback',
          ),
          const SizedBox(height: 20),
          if (feedback.isEmpty)
            const EmptyState(
              icon: Icons.feedback_outlined,
              message:
                  'No feedback yet.\nThis feature requires additional backend endpoints.',
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _AdminReportsPage extends StatelessWidget {
  final List<dynamic> reports;
  final VoidCallback onRefresh;

  const _AdminReportsPage({required this.reports, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const PageHeader(
            title: 'Reports',
            subtitle: 'Platform analytics and reports',
          ),
          const SizedBox(height: 20),
          _buildReportCard(
            'User Growth',
            'Monthly active users: 156\nNew signups this month: 23',
            Icons.trending_up,
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            'Job Statistics',
            'Total jobs: 28\nActive jobs: 15\nApplications received: 67',
            Icons.work,
          ),
          const SizedBox(height: 16),
          _buildReportCard(
            'Mentorship Activity',
            'Active mentorship pairs: 38\nPending requests: 12\nCompleted sessions: 156',
            Icons.school,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primaryCyan, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 12,
                    height: 1.5,
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
