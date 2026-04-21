import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/token_store.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'sign_in_page.dart';
import 'education_form_page.dart';
import 'work_experience_form_page.dart';
import 'settings_page.dart';

class JobSeekerDashboard extends StatefulWidget {
  const JobSeekerDashboard({super.key});

  @override
  State<JobSeekerDashboard> createState() => _JobSeekerDashboardState();
}

class _JobSeekerDashboardState extends State<JobSeekerDashboard> {
  int _currentIndex = 0;
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
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

  Future<void> _logout() async {
    await TokenStore.clear();
    if (mounted)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (_) => false,
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppThemeProvider>();
    final pages = [
      _JSHomePage(
        profile: _profile,
        loading: _loading,
        onRefresh: _loadProfile,
      ),
      _EducationPage(profile: _profile ?? {}, onRefresh: _loadProfile),
      _ExperiencePage(profile: _profile ?? {}, onRefresh: _loadProfile),
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
          NavItem(Icons.home_outlined, Icons.home, 'Home'),
          NavItem(Icons.school_outlined, Icons.school, 'Education'),
          NavItem(Icons.work_outline, Icons.work, 'Experience'),
          NavItem(Icons.settings_outlined, Icons.settings, 'Settings'),
        ],
      ),
    );
  }
}

// ── HOME TAB ──────────────────────────────────────────────
class _JSHomePage extends StatelessWidget {
  final Map<String, dynamic>? profile;
  final bool loading;
  final VoidCallback onRefresh;
  const _JSHomePage({
    required this.profile,
    required this.loading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    if (loading)
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primaryCyan),
      );

    final p = profile ?? {};
    final name =
        (p['full_name'] as String?) ?? (p['email'] as String?) ?? 'User';
    final email = (p['email'] as String?) ?? '';
    final headline = (p['headline'] as String?) ?? 'Job Seeker';
    final pictureUrl = p['profile_picture'] as String?;
    final dob = (p['date_of_birth'] as String?) ?? '—';
    final location = (p['location'] as String?) ?? '—';
    final currentJob = (p['current_job_title'] as String?) ?? '—';
    final desiredJob = (p['desired_job_title'] as String?) ?? '—';
    final yoe = p['years_of_experience'];
    final avail = (p['availability'] as String?) ?? '—';

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
                    'Job Seeker Dashboard',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
                backgroundImage: pictureUrl != null
                    ? NetworkImage(pictureUrl)
                    : null,
                child: pictureUrl == null
                    ? const Icon(
                        Icons.person,
                        color: AppColors.primaryCyan,
                        size: 20,
                      )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ProfileCard(
            name: name,
            headline: headline,
            email: email,
            pictureUrl: pictureUrl,
            badge: 'Job Seeker',
            badgeIcon: Icons.search_rounded,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              StatBox(
                label: 'Experience',
                value: yoe != null ? '$yoe yrs' : '—',
                icon: Icons.signal_cellular_alt,
              ),
              const SizedBox(width: 12),
              StatBox(
                label: 'Availability',
                value: avail.replaceAll('_', ' '),
                icon: Icons.hourglass_top_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SectionTitle(title: 'Personal Info'),
          const SizedBox(height: 10),
          InfoTile(
            icon: Icons.cake_outlined,
            label: 'Date of Birth',
            value: dob,
          ),
          InfoTile(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: location,
          ),
          InfoTile(icon: Icons.email_outlined, label: 'Email', value: email),
          const SizedBox(height: 20),
          const SectionTitle(title: 'Career Info'),
          const SizedBox(height: 10),
          InfoTile(
            icon: Icons.work_outline,
            label: 'Current Role',
            value: currentJob,
          ),
          InfoTile(
            icon: Icons.flag_outlined,
            label: 'Desired Role',
            value: desiredJob,
          ),
          const SizedBox(height: 20),
          const ComingSoonBanner(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ── EDUCATION TAB ─────────────────────────────────────────
class _EducationPage extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onRefresh;
  const _EducationPage({required this.profile, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final items = (profile['education'] as List<dynamic>?) ?? [];
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const PageHeader(
            title: 'Education',
            subtitle: 'Your academic history',
          ),
          const SizedBox(height: 16),
          AddButton(
            label: 'Add Education',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EducationFormPage()),
            ).then((_) => onRefresh()),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const EmptyState(
              icon: Icons.school_outlined,
              message: 'No education entries yet.\nTap + to add one.',
            )
          else
            ...items.map((e) {
              final item = e as Map<String, dynamic>;
              return EducationCard(
                item: item,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EducationFormPage(existing: item),
                  ),
                ).then((_) => onRefresh()),
                onDelete: () async {
                  final token = await TokenStore.getAccess();
                  if (token == null) return;
                  await ApiService.deleteEducation(
                    token: token,
                    id: item['id'] as int,
                  );
                  onRefresh();
                },
              );
            }),
        ],
      ),
    );
  }
}

// ── EXPERIENCE TAB ────────────────────────────────────────
class _ExperiencePage extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onRefresh;
  const _ExperiencePage({required this.profile, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final items = (profile['work_experience'] as List<dynamic>?) ?? [];
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const PageHeader(
            title: 'Work Experience',
            subtitle: 'Your career history',
          ),
          const SizedBox(height: 16),
          AddButton(
            label: 'Add Work Experience',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkExperienceFormPage()),
            ).then((_) => onRefresh()),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            const EmptyState(
              icon: Icons.work_outline,
              message: 'No work experience yet.\nTap + to add one.',
            )
          else
            ...items.map((w) {
              final item = w as Map<String, dynamic>;
              return WorkCard(
                item: item,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkExperienceFormPage(existing: item),
                  ),
                ).then((_) => onRefresh()),
                onDelete: () async {
                  final token = await TokenStore.getAccess();
                  if (token == null) return;
                  await ApiService.deleteWorkExperience(
                    token: token,
                    id: item['id'] as int,
                  );
                  onRefresh();
                },
              );
            }),
        ],
      ),
    );
  }
}
