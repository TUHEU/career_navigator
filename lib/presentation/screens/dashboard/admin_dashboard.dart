import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/bottom_nav.dart';
import '../../widgets/shared/buttons.dart';
import '../../widgets/shared/cards.dart';
import '../../widgets/shared/loading_widgets.dart';
import '../settings/settings_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _AdminHomePage(),
    const _AdminUsersPage(),
    const _AdminFeedbackPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
              image: DecorationImage(
                image: AssetImage(
                  isDark
                      ? 'assets/background/bg8.png'
                      : 'assets/background/bg6.png',
                ),
                fit: BoxFit.cover,
                opacity: 0.18,
              ),
            ),
          ),
          Container(
            color: isDark
                ? AppColors.darkBackground.withOpacity(0.80)
                : Colors.white.withOpacity(0.92),
          ),
          SafeArea(child: _pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          NavItem(Icons.dashboard_outlined, Icons.dashboard, 'Dashboard'),
          NavItem(Icons.people_outline, Icons.people, 'Users'),
          NavItem(Icons.feedback_outlined, Icons.feedback, 'Feedback'),
          NavItem(Icons.settings_outlined, Icons.settings, 'Settings'),
        ],
      ),
    );
  }
}

class _AdminHomePage extends StatefulWidget {
  const _AdminHomePage();

  @override
  State<_AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<_AdminHomePage> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _stats = {
        'totalUsers': 156,
        'mentors': 42,
        'jobSeekers': 114,
        'jobsPosted': 28,
        'applications': 67,
        'pendingFeedback': 12,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    if (_isLoading) {
      return const LoadingIndicator();
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      color: AppColors.primaryCyan,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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
                        color: isDark
                            ? Colors.white.withOpacity(0.5)
                            : AppColors.lightTextSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAdminCard(isDark),
            const SizedBox(height: 24),
            const Text(
              'Platform Overview',
              style: TextStyle(
                color: AppColors.primaryCyan,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard(
                  'Total Users',
                  '${_stats!['totalUsers']}',
                  Icons.people,
                  AppColors.primaryCyan,
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Mentors',
                  '${_stats!['mentors']}',
                  Icons.school,
                  Colors.greenAccent,
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Job Seekers',
                  '${_stats!['jobSeekers']}',
                  Icons.search,
                  Colors.amber,
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatCard(
                  'Jobs Posted',
                  '${_stats!['jobsPosted']}',
                  Icons.work,
                  Colors.blueAccent,
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Applications',
                  '${_stats!['applications']}',
                  Icons.description,
                  Colors.purpleAccent,
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Pending Feedback',
                  '${_stats!['pendingFeedback']}',
                  Icons.feedback,
                  Colors.orangeAccent,
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildActivitySection(isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard(bool isDark) {
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;
    final name = user?.fullName ?? 'Admin';
    final email = user?.email ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
            child: Text(
              Helpers.getInitials(name),
              style: const TextStyle(
                color: AppColors.primaryCyan,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'System Administrator',
                  style: const TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  email,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.4)
                        : AppColors.lightTextSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                _buildAdminBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.admin_panel_settings,
            color: AppColors.primaryCyan,
            size: 12,
          ),
          SizedBox(width: 5),
          Text(
            'Admin',
            style: TextStyle(
              color: AppColors.primaryCyan,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.grey.shade300,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.lightText,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.5)
                    : AppColors.lightTextSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitySection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade300,
        ),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildActivityItem(
            'New user registered',
            'john.doe@example.com joined as Job Seeker',
            '2 min ago',
            isDark,
          ),
          const Divider(color: Colors.white10, height: 20),
          _buildActivityItem(
            'Job posted',
            'Tech Corp posted a Senior Developer position',
            '15 min ago',
            isDark,
          ),
          const Divider(color: Colors.white10, height: 20),
          _buildActivityItem(
            'Mentor request accepted',
            'Sarah Johnson accepted a mentoring request',
            '1 hour ago',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    String time,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.lightText,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.45)
                : AppColors.lightTextSecondary,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.25)
                : Colors.grey.shade500,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _AdminUsersPage extends StatelessWidget {
  const _AdminUsersPage();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'User Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.5)
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminFeedbackPage extends StatelessWidget {
  const _AdminFeedbackPage();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.feedback_outlined,
            size: 64,
            color: isDark ? Colors.white24 : Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Feedback Management',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming Soon',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.5)
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
