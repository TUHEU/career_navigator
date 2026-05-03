import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/bottom_nav.dart';
import '../../widgets/shared/buttons.dart';
import '../../widgets/shared/loading_widgets.dart';
import '../profile/edit_profile_page.dart';
import '../profile/mentor_profile_page.dart';
import '../jobs/job_listings_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomePage(),
    const _JobsPage(),
    const _SearchPage(),
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
                image: AssetImage(themeProvider.backgroundPath),
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
          NavItem(Icons.home_outlined, Icons.home, 'Home'),
          NavItem(Icons.work_outline, Icons.work, 'Jobs'),
          NavItem(Icons.search_outlined, Icons.search, 'Search'),
          NavItem(Icons.settings_outlined, Icons.settings, 'Settings'),
        ],
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = themeProvider.isDarkMode;
    final user = authProvider.currentUser;

    return RefreshIndicator(
      onRefresh: () => authProvider.loadUserProfile(),
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
                    'Mentor Dashboard',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.5)
                          : AppColors.lightTextSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: isDark ? Colors.white70 : Colors.grey.shade600,
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const _SearchPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: AppColors.primaryCyan.withOpacity(0.25),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
                  backgroundImage: user?.profilePictureUrl != null
                      ? NetworkImage(user!.profilePictureUrl!)
                      : null,
                  child: user?.profilePictureUrl == null
                      ? Text(
                          Helpers.getInitials(user?.displayName ?? 'User'),
                          style: const TextStyle(
                            color: AppColors.primaryCyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
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
                        user?.displayName ?? 'User',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.lightText,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryCyan.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryCyan.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.school_outlined,
                              color: AppColors.primaryCyan,
                              size: 12,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Mentor',
                              style: TextStyle(
                                color: AppColors.primaryCyan,
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
          const SizedBox(height: 20),
          SecondaryButton(
            text: 'Edit Mentor Profile',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MentorProfilePage(profile: {}),
              ),
            ).then((_) => authProvider.loadUserProfile()),
            icon: Icons.edit_outlined,
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            text: 'Edit Personal Info',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ).then((_) => authProvider.loadUserProfile()),
            icon: Icons.person_outline,
          ),
        ],
      ),
    );
  }
}

class _JobsPage extends StatelessWidget {
  const _JobsPage();

  @override
  Widget build(BuildContext context) => const JobListingsPage();
}

class _SearchPage extends StatelessWidget {
  const _SearchPage();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Search Page - Coming Soon')));
}
