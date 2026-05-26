// presentation/screens/dashboard/job_seeker_dashboard.dart
// FIXED: local profile picture + full language support on all strings
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/local/profile_picture_store.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/bottom_nav.dart';
import '../../widgets/shared/buttons.dart';
import '../profile/edit_profile_page.dart';
import '../jobs/job_listings_page.dart';
import '../chat/chat_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';
import '../ai/ai_hub_page.dart';

class JobSeekerDashboard extends StatefulWidget {
  const JobSeekerDashboard({super.key});
  @override
  State<JobSeekerDashboard> createState() => _JobSeekerDashboardState();
}

class _JobSeekerDashboardState extends State<JobSeekerDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    _HomePage(),
    JobListingsPage(),
    ConversationsPage(),
    SearchPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark        = themeProvider.isDarkMode;
    final lang          = context.watch<LanguageProvider>();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              image: DecorationImage(
                image: AssetImage(themeProvider.backgroundPath),
                fit: BoxFit.cover, opacity: 0.3),
            ),
          ),
          SafeArea(child: _pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          NavItem(Icons.home_outlined,        Icons.home,         lang.t(S.home)),
          NavItem(Icons.work_outline,          Icons.work,         lang.t(S.jobs)),
          NavItem(Icons.chat_bubble_outline,   Icons.chat_bubble,  lang.t(S.chat)),
          NavItem(Icons.search_outlined,       Icons.search,       lang.t(S.search)),
          NavItem(Icons.settings_outlined,     Icons.settings,     lang.t(S.settings)),
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
    final authProvider  = context.watch<AuthProvider>();
    final lang          = context.watch<LanguageProvider>();
    final isDark        = themeProvider.isDarkMode;
    final user          = authProvider.currentUser;

    return RefreshIndicator(
      onRefresh: () => authProvider.loadUserProfile(),
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [

          // ── Top header ─────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CAREER NAVIGATOR', style: TextStyle(
                  color: AppColors.primaryCyan, fontSize: 11,
                  letterSpacing: 2, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(lang.t(S.jobSeeker), style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : AppColors.lightTextSecondary,
                  fontSize: 12)),
              ]),
              IconButton(
                icon: Icon(Icons.search,
                    color: isDark ? Colors.white70 : Colors.grey.shade600),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SearchPage())),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── Profile card ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: AppColors.primaryCyan.withValues(alpha: 0.25)),
            ),
            child: Row(children: [

              // ── PROFILE PICTURE FIX ───────────────────────
              // Shows local saved picture first, falls back to
              // Cloudinary URL, then initials. Never blank.
              ProfilePictureStore.avatar(
                remoteUrl: user?.profilePictureUrl,
                name:      user?.displayName ?? 'User',
                radius:    36,
                bgColor:   AppColors.primaryCyan,
              ),

              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.displayName ?? 'User', style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primaryCyan.withValues(alpha: 0.3)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.search_rounded,
                          color: AppColors.primaryCyan, size: 12),
                      const SizedBox(width: 5),
                      Text(lang.t(S.jobSeeker), style: const TextStyle(
                        color: AppColors.primaryCyan,
                        fontSize: 11, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                ],
              )),
            ]),
          ),
          const SizedBox(height: 20),

          // ── Edit profile ──────────────────────────────────
          PrimaryButton(
            text: lang.t(S.editProfile),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()))
                .then((_) => authProvider.loadUserProfile()),
            icon: Icons.edit_outlined,
          ),
          const SizedBox(height: 12),

          // ── AI Tools card ─────────────────────────────────
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AIHubPage())),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.primaryCyan.withValues(alpha: 0.15),
                  AppColors.primaryCyan.withValues(alpha: 0.05),
                ]),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primaryCyan.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withValues(alpha: 0.15),
                    shape: BoxShape.circle),
                  child: const Icon(Icons.auto_awesome,
                      color: AppColors.primaryCyan, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(lang.t(S.aiCareerTools), style: TextStyle(
                      color: isDark ? Colors.white : AppColors.lightText,
                      fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(lang.t(S.aiCareerSub), style: TextStyle(
                      color: AppColors.primaryCyan.withValues(alpha: 0.8),
                      fontSize: 11)),
                  ],
                )),
                const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.primaryCyan),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // ── Coming soon card ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: AppColors.primaryCyan.withValues(alpha: 0.15)),
            ),
            child: Row(children: [
              const Icon(Icons.rocket_launch_outlined,
                  color: AppColors.primaryCyan, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.t(S.moreComing), style: TextStyle(
                    color: AppColors.text(isDark),
                    fontWeight: FontWeight.w600, fontSize: 13)),
                  Text(lang.t(S.moreComingSub), style: TextStyle(
                    color: AppColors.textMuted(isDark), fontSize: 11)),
                ],
              )),
            ]),
          ),
        ],
      ),
    );
  }
}
