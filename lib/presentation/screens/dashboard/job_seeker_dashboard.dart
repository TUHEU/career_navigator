import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/bottom_nav.dart';
import '../../widgets/shared/buttons.dart';
import '../../widgets/shared/cards.dart';
import '../../widgets/shared/loading_widgets.dart';
import '../profile/edit_profile_page.dart';
import '../profile/education_form_page.dart';
import '../profile/work_experience_form_page.dart';
import '../jobs/job_listings_page.dart';
import '../chat/chat_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';

class JobSeekerDashboard extends StatefulWidget {
  const JobSeekerDashboard({super.key});

  @override
  State<JobSeekerDashboard> createState() => _JobSeekerDashboardState();
}

class _JobSeekerDashboardState extends State<JobSeekerDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _HomePage(),
    const _EducationPage(),
    const _ExperiencePage(),
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
          NavItem(Icons.school_outlined, Icons.school, 'Education'),
          NavItem(Icons.work_outline, Icons.work, 'Experience'),
          NavItem(Icons.search_outlined, Icons.search, 'Jobs'),
          NavItem(Icons.settings_outlined, Icons.settings, 'Settings'),
        ],
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  JobSeeker? _user;
  bool _isLoading = true;

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
        _user = authProvider.currentUser as JobSeeker?;
        _isLoading = false;
      });
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
            _buildPersonalInfo(isDark),
            const SizedBox(height: 20),
            _buildCareerInfo(isDark),
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
              'Job Seeker Dashboard',
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
                  _user?.fullName ?? _user?.email ?? 'User',
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
          Icon(Icons.search_rounded, color: AppColors.primaryCyan, size: 12),
          SizedBox(width: 5),
          Text(
            'Job Seeker',
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.signal_cellular_alt,
                  color: AppColors.primaryCyan,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  '${_user?.yearsOfExperience ?? 0} yrs',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Experience',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.4)
                        : AppColors.lightTextSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.hourglass_top_outlined,
                  color: AppColors.primaryCyan,
                  size: 20,
                ),
                const SizedBox(height: 8),
                Text(
                  _user?.availability?.replaceAll('_', ' ') ?? '—',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Availability',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.4)
                        : AppColors.lightTextSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personal Info',
          style: TextStyle(
            color: AppColors.primaryCyan,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        InfoCard(
          title: 'Email',
          value: _user?.email ?? '—',
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 8),
        InfoCard(
          title: 'Location',
          value: _user?.location ?? '—',
          icon: Icons.location_on_outlined,
        ),
        const SizedBox(height: 8),
        InfoCard(
          title: 'Phone',
          value: _user?.phone ?? '—',
          icon: Icons.phone_outlined,
        ),
      ],
    );
  }

  Widget _buildCareerInfo(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Career Info',
          style: TextStyle(
            color: AppColors.primaryCyan,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 10),
        InfoCard(
          title: 'Current Role',
          value: _user?.currentJobTitle ?? '—',
          icon: Icons.work_outline,
        ),
        const SizedBox(height: 8),
        InfoCard(
          title: 'Desired Role',
          value: _user?.desiredJobTitle ?? '—',
          icon: Icons.flag_outlined,
        ),
        if ((_user?.skills ?? []).isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.grey.shade300,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Skills',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : AppColors.lightTextSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _user!.skills!
                      .map(
                        (skill) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(
                              color: AppColors.primaryCyan,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SecondaryButton(
          text: 'Edit Profile',
          icon: Icons.edit_outlined,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfilePage()),
          ).then((_) => _loadUser()),
        ),
        const SizedBox(height: 10),
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
                  'AI recommendations, skill assessments & more.',
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

class _EducationPage extends StatefulWidget {
  const _EducationPage();

  @override
  State<_EducationPage> createState() => _EducationPageState();
}

class _EducationPageState extends State<_EducationPage> {
  List<Education> _education = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEducation();
  }

  Future<void> _loadEducation() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    await authProvider.loadUserProfile();
    if (mounted) {
      final user = authProvider.currentUser as JobSeeker?;
      setState(() {
        _education = user?.education ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _addEducation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EducationFormPage()),
    );
    if (result == true) {
      _loadEducation();
    }
  }

  Future<void> _editEducation(Education education) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EducationFormPage(existing: education.toJson()),
      ),
    );
    if (result == true) {
      _loadEducation();
    }
  }

  Future<void> _deleteEducation(int id) async {
    final confirmed = await Helpers.showConfirmationDialog(
      context,
      title: 'Delete Education',
      message: 'Are you sure you want to delete this education entry?',
    );
    if (confirmed) {
      final userRepo = context.read<AuthProvider>()._userRepository;
      await userRepo.deleteEducation(id);
      _loadEducation();
      Helpers.showSnackBar(context, 'Education deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    if (_isLoading) {
      return const LoadingIndicator();
    }

    return RefreshIndicator(
      onRefresh: _loadEducation,
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const Text(
            'Education',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Your academic history',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.45)
                  : AppColors.lightTextSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Add Education',
            icon: Icons.add,
            onPressed: _addEducation,
            isFullWidth: true,
          ),
          const SizedBox(height: 16),
          if (_education.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Icon(
                    Icons.school_outlined,
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                    size: 60,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No education entries yet',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey.shade500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your education history',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._education.map(
              (edu) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.07)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.school_outlined,
                            color: AppColors.primaryCyan,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                edu.institution,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.lightText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${edu.degree} · ${edu.fieldOfStudy}',
                                style: const TextStyle(
                                  color: AppColors.primaryCyan,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                edu.yearsRange,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.4)
                                      : AppColors.lightTextSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.primaryCyan,
                                size: 17,
                              ),
                              onPressed: () => _editEducation(edu),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(height: 6),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent.withOpacity(0.65),
                                size: 17,
                              ),
                              onPressed: () => _deleteEducation(edu.id!),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (edu.description != null &&
                        edu.description!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        edu.description!,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.55)
                              : AppColors.lightTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ExperiencePage extends StatefulWidget {
  const _ExperiencePage();

  @override
  State<_ExperiencePage> createState() => _ExperiencePageState();
}

class _ExperiencePageState extends State<_ExperiencePage> {
  List<WorkExperience> _workExperience = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExperience();
  }

  Future<void> _loadExperience() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    await authProvider.loadUserProfile();
    if (mounted) {
      final user = authProvider.currentUser as JobSeeker?;
      setState(() {
        _workExperience = user?.workExperience ?? [];
        _isLoading = false;
      });
    }
  }

  Future<void> _addExperience() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WorkExperienceFormPage()),
    );
    if (result == true) {
      _loadExperience();
    }
  }

  Future<void> _editExperience(WorkExperience work) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkExperienceFormPage(existing: work.toJson()),
      ),
    );
    if (result == true) {
      _loadExperience();
    }
  }

  Future<void> _deleteExperience(int id) async {
    final confirmed = await Helpers.showConfirmationDialog(
      context,
      title: 'Delete Experience',
      message: 'Are you sure you want to delete this work experience?',
    );
    if (confirmed) {
      final userRepo = context.read<AuthProvider>()._userRepository;
      await userRepo.deleteWorkExperience(id);
      _loadExperience();
      Helpers.showSnackBar(context, 'Work experience deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    if (_isLoading) {
      return const LoadingIndicator();
    }

    return RefreshIndicator(
      onRefresh: _loadExperience,
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const Text(
            'Work Experience',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Your professional history',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.45)
                  : AppColors.lightTextSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Add Work Experience',
            icon: Icons.add,
            onPressed: _addExperience,
            isFullWidth: true,
          ),
          const SizedBox(height: 16),
          if (_workExperience.isEmpty)
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Icon(
                    Icons.work_outline,
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                    size: 60,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No work experience yet',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey.shade500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add your work history',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._workExperience.map(
              (work) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.07)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCyan.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.business_center_outlined,
                            color: AppColors.primaryCyan,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                work.jobTitle,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.lightText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                work.company,
                                style: const TextStyle(
                                  color: AppColors.primaryCyan,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Text(
                                    work.dateRange,
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.4)
                                          : AppColors.lightTextSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withOpacity(0.07)
                                          : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      work.employmentTypeDisplay,
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.4)
                                            : AppColors.lightTextSecondary,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: AppColors.primaryCyan,
                                size: 17,
                              ),
                              onPressed: () => _editExperience(work),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(height: 6),
                            IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent.withOpacity(0.65),
                                size: 17,
                              ),
                              onPressed: () => _deleteExperience(work.id!),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (work.description != null &&
                        work.description!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        work.description!,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white.withOpacity(0.55)
                              : AppColors.lightTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Conversations Page
class ConversationsPage extends StatefulWidget {
  const ConversationsPage({super.key});

  @override
  State<ConversationsPage> createState() => _ConversationsPageState();
}

class _ConversationsPageState extends State<ConversationsPage> {
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) return;

    final apiService = ApiService();
    final response = await apiService.getConversations(token);

    if (mounted && response['success'] == true) {
      setState(() {
        _conversations = List<Map<String, dynamic>>.from(
          response['data'] ?? [],
        );
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Messages')),
      body: _isLoading
          ? const LoadingIndicator()
          : _conversations.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: isDark ? Colors.white24 : Colors.grey.shade400,
                    size: 60,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'No conversations yet',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.3)
                          : Colors.grey.shade500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Send an invite to a mentor to start chatting.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadConversations,
              color: AppColors.primaryCyan,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: _conversations.length,
                itemBuilder: (_, i) {
                  final conv = _conversations[i];
                  final name = conv['other_name'] ?? 'Unknown';
                  final picture = conv['other_picture'] as String?;
                  final lastMsg = conv['last_message'] ?? '';
                  final lastTime = conv['last_message_at'] ?? '';
                  final convId = conv['id'] as int;
                  final otherId = conv['other_user_id'] as int;
                  final unread = conv['unread_count'] as int? ?? 0;

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatPage(
                          conversationId: convId,
                          recipientId: otherId,
                          recipientName: name,
                        ),
                      ),
                    ).then((_) => _loadConversations()),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
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
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: AppColors.primaryCyan.withOpacity(
                              0.2,
                            ),
                            backgroundImage: picture != null
                                ? NetworkImage(picture)
                                : null,
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
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.lightText,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    if (unread > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryCyan,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '$unread',
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  lastMsg,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
                          const SizedBox(width: 8),
                          Text(
                            Helpers.getRelativeTime(lastTime),
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.grey.shade500,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
