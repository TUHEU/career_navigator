import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/user_model.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/bottom_nav.dart';
import '../../widgets/shared/buttons.dart';
import '../../widgets/shared/cards.dart';
import '../../widgets/shared/loading_widgets.dart';
import '../profile/edit_profile_page.dart';
import '../profile/mentor_profile_page.dart';
import '../profile/education_form_page.dart';
import '../profile/work_experience_form_page.dart';
import '../jobs/job_listings_page.dart';
import '../chat/chat_page.dart';
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
    const _MentorHomePage(),
    const _MentorProfileTab(),
    const _MentorHistoryTab(),
    const JobListingsPage(),
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
          NavItem(Icons.home_outlined, Icons.home, 'Home'),
          NavItem(Icons.person_outline, Icons.person, 'Profile'),
          NavItem(Icons.history_outlined, Icons.history, 'History'),
          NavItem(Icons.work_outline, Icons.work, 'Jobs'),
          NavItem(Icons.settings_outlined, Icons.settings, 'Settings'),
        ],
      ),
    );
  }
}

class _MentorHomePage extends StatefulWidget {
  const _MentorHomePage();

  @override
  State<_MentorHomePage> createState() => _MentorHomePageState();
}

class _MentorHomePageState extends State<_MentorHomePage> {
  Mentor? _user;
  bool _isLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    await authProvider.loadUserProfile();
    if (mounted) {
      setState(() {
        _user = authProvider.currentUser as Mentor?;
        _isLoading = false;
      });
    }
  }

  Future<void> _sendInvite(int userId, String name) async {
    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) return;

    final response = await _apiService.sendMentorRequest(
      token: token,
      mentorId: userId,
      message: 'I would like to connect with you as your mentor.',
    );

    if (response['success'] == true) {
      Helpers.showSnackBar(context, 'Invite sent to $name!');
    } else {
      Helpers.showSnackBar(
        context,
        response['message'] ?? 'Failed to send invite',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    if (_isLoading) {
      return const LoadingIndicator();
    }

    if (_user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Failed to load profile',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              text: 'Retry',
              onPressed: _loadUser,
              isFullWidth: false,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUser,
      color: AppColors.primaryCyan,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 16),
            _buildProfileCard(isDark),
            const SizedBox(height: 20),
            _buildStatsRow(isDark),
            const SizedBox(height: 20),
            _buildAvailabilityBadge(isDark),
            const SizedBox(height: 20),
            if ((_user?.expertiseAreas ?? []).isNotEmpty)
              _buildExpertiseSection(isDark),
            const SizedBox(height: 20),
            _buildProfessionalInfo(isDark),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 20),
            _buildComingSoonBanner(isDark),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
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
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.search,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchPage()),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.chat_bubble_outline,
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ConversationsPage()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileCard(bool isDark) {
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
            radius: 36,
            backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
            backgroundImage: _user?.profilePictureUrl != null
                ? NetworkImage(_user!.profilePictureUrl!)
                : null,
            child: _user?.profilePictureUrl == null
                ? Text(
                    _user?.initials ?? '?',
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
                  _user?.fullName ?? _user?.email ?? 'Mentor',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if ((_user?.headline ?? '').isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    _user!.headline!,
                    style: const TextStyle(
                      color: AppColors.primaryCyan,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                _buildRoleBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge() {
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
          Icon(Icons.school_outlined, color: AppColors.primaryCyan, size: 12),
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
    );
  }

  Widget _buildStatsRow(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.grey.shade300,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.star_outline,
                  color: AppColors.primaryCyan,
                  size: 18,
                ),
                const SizedBox(height: 6),
                Text(
                  _user?.ratingText ?? 'New',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rating',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.38)
                        : AppColors.lightTextSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.grey.shade300,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.people_outline,
                  color: AppColors.primaryCyan,
                  size: 18,
                ),
                const SizedBox(height: 6),
                Text(
                  '${_user?.totalSessions ?? 0}',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sessions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.38)
                        : AppColors.lightTextSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.grey.shade300,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.attach_money,
                  color: AppColors.primaryCyan,
                  size: 18,
                ),
                const SizedBox(height: 6),
                Text(
                  _user?.sessionPriceText ?? 'Free',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Per session',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.38)
                        : AppColors.lightTextSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityBadge(bool isDark) {
    final isAccepting = _user?.isAcceptingMentees ?? true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isAccepting
            ? Colors.greenAccent.withOpacity(0.08)
            : Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAccepting
              ? Colors.greenAccent.withOpacity(0.3)
              : Colors.redAccent.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAccepting ? Icons.check_circle_outline : Icons.cancel_outlined,
            color: isAccepting ? Colors.greenAccent : Colors.redAccent,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            isAccepting
                ? 'Currently accepting new mentees'
                : 'Not accepting mentees right now',
            style: TextStyle(
              color: isAccepting ? Colors.greenAccent : Colors.redAccent,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpertiseSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Expertise Areas',
          style: TextStyle(
            color: AppColors.primaryCyan,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _user!.expertiseAreas!
              .map(
                (area) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryCyan.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    area,
                    style: const TextStyle(
                      color: AppColors.primaryCyan,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildProfessionalInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Professional Info',
          style: TextStyle(
            color: AppColors.primaryCyan,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        InfoCard(
          title: 'Current Company',
          value: _user?.currentCompany ?? '—',
          icon: Icons.business_outlined,
        ),
        const SizedBox(height: 8),
        InfoCard(
          title: 'Job Title',
          value: _user?.currentJobTitle ?? '—',
          icon: Icons.badge_outlined,
        ),
        const SizedBox(height: 8),
        InfoCard(
          title: 'Years of Experience',
          value: _user?.yearsOfExperience != null
              ? '${_user!.yearsOfExperience} years'
              : '—',
          icon: Icons.signal_cellular_alt,
        ),
        const SizedBox(height: 8),
        InfoCard(
          title: 'Location',
          value: _user?.location ?? '—',
          icon: Icons.location_on_outlined,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SecondaryButton(
          text: 'Edit Mentor Profile',
          icon: Icons.edit_outlined,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MentorProfilePage(profile: _user?.toJson() ?? {}),
            ),
          ).then((_) => _loadUser()),
        ),
        const SizedBox(height: 10),
        SecondaryButton(
          text: 'Edit Personal Info',
          icon: Icons.person_outline,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfilePage()),
          ).then((_) => _loadUser()),
        ),
      ],
    );
  }

  Widget _buildComingSoonBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.rocket_launch_outlined,
            color: AppColors.primaryCyan,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'More features coming soon',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Group sessions, webinars & analytics.',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.45)
                        : AppColors.lightTextSecondary,
                    fontSize: 12,
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

class _MentorProfileTab extends StatelessWidget {
  const _MentorProfileTab();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return const Center(child: Text('Mentor Profile Tab - Coming Soon'));
  }
}

class _MentorHistoryTab extends StatelessWidget {
  const _MentorHistoryTab();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return const Center(child: Text('Mentor History Tab - Coming Soon'));
  }
}
