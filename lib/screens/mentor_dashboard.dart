import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/token_store.dart';
import '../core/themes/app_theme.dart';
import '../widgets/shared_widgets.dart';
import 'sign_in_page.dart';
import 'mentor_profile_page.dart';
import 'education_form_page.dart';
import 'work_experience_form_page.dart';
import 'settings_page.dart';
import 'notifications_page.dart';
import 'chat_page.dart';
import 'search_page.dart';
import 'job_listings_page.dart';

class MentorDashboard extends StatefulWidget {
  const MentorDashboard({super.key});

  @override
  State<MentorDashboard> createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
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
      _MentorHomePage(
        profile: _profile,
        loading: _loading,
        onRefresh: _loadProfile,
      ),
      _MentorProfileTab(profile: _profile ?? {}, onRefresh: _loadProfile),
      _MentorHistoryTab(profile: _profile ?? {}, onRefresh: _loadProfile),
      const JobListingsPage(),
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
          NavItem(Icons.person_outline, Icons.person, 'My Profile'),
          NavItem(Icons.history_outlined, Icons.history, 'History'),
          NavItem(Icons.work_outline, Icons.work, 'Jobs'),
          NavItem(Icons.settings_outlined, Icons.settings, 'Settings'),
        ],
      ),
    );
  }
}

class _MentorHomePage extends StatelessWidget {
  final Map<String, dynamic>? profile;
  final bool loading;
  final VoidCallback onRefresh;

  const _MentorHomePage({
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
    final mp = (p['mentor_profile'] as Map<String, dynamic>?) ?? {};
    final name =
        (p['full_name'] as String?) ?? (p['email'] as String?) ?? 'Mentor';
    final email = (p['email'] as String?) ?? '';
    final headline =
        (mp['headline'] as String?) ?? (p['headline'] as String?) ?? 'Mentor';
    final pictureUrl = p['profile_picture_url'] as String?;
    final company = (mp['current_company'] as String?) ?? '—';
    final jobTitle = (mp['current_job_title'] as String?) ?? '—';
    final yoe = mp['years_of_experience'];
    final price = mp['session_price'];
    final currency = (mp['currency'] as String?) ?? 'USD';
    final accepting = mp['is_accepting_mentees'] != 0;
    final totalSess = mp['total_sessions'] ?? 0;
    final rating = mp['rating'];
    final unread = (p['unread_notifications'] as int?) ?? 0;

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
                    'Mentor Dashboard',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Colors.white70,
                      size: 22,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchPage()),
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white70,
                          size: 22,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotificationsPage(),
                          ),
                        ).then((_) => onRefresh()),
                      ),
                      if (unread > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white70,
                      size: 22,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ConversationsPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProfileCard(
            name: name,
            headline: headline,
            email: email,
            pictureUrl: pictureUrl,
            badge: 'Mentor',
            badgeIcon: Icons.school_outlined,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _MStatBox(
                icon: Icons.star_outline,
                label: 'Rating',
                value: rating != null ? rating.toString() : 'New',
              ),
              const SizedBox(width: 10),
              _MStatBox(
                icon: Icons.people_outline,
                label: 'Sessions',
                value: '$totalSess',
              ),
              const SizedBox(width: 10),
              _MStatBox(
                icon: Icons.attach_money,
                label: 'Per session',
                value: price != null && price != 0
                    ? '$currency $price'
                    : 'Free',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: accepting
                  ? Colors.greenAccent.withOpacity(0.08)
                  : Colors.redAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: accepting
                    ? Colors.greenAccent.withOpacity(0.3)
                    : Colors.redAccent.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  accepting
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  color: accepting ? Colors.greenAccent : Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  accepting
                      ? 'Currently accepting new mentees'
                      : 'Not accepting mentees right now',
                  style: TextStyle(
                    color: accepting ? Colors.greenAccent : Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          if ((mp['expertise_areas'] as List?)?.isNotEmpty == true) ...[
            const SectionTitle(title: 'Expertise Areas'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (mp['expertise_areas'] as List)
                  .map((e) => ExpertiseChip(label: e.toString()))
                  .toList(),
            ),
            const SizedBox(height: 20),
          ],
          const SectionTitle(title: 'Career Info'),
          const SizedBox(height: 10),
          InfoTile(
            icon: Icons.business_outlined,
            label: 'Current Company',
            value: company,
          ),
          InfoTile(
            icon: Icons.badge_outlined,
            label: 'Job Title',
            value: jobTitle,
          ),
          InfoTile(
            icon: Icons.signal_cellular_alt,
            label: 'Experience',
            value: yoe != null ? '$yoe years' : '—',
          ),
          const SizedBox(height: 20),
          const ComingSoonBanner(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _MentorProfileTab extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onRefresh;

  const _MentorProfileTab({required this.profile, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final mp = (profile['mentor_profile'] as Map<String, dynamic>?) ?? {};

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        const PageHeader(
          title: 'Mentor Profile',
          subtitle: 'Manage your mentor information',
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MentorProfilePage(profile: profile),
            ),
          ).then((_) => onRefresh()),
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Edit Mentor Profile'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryCyan.withOpacity(0.15),
            foregroundColor: AppColors.primaryCyan,
            side: const BorderSide(color: AppColors.primaryCyan),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle(title: 'Mentor Details'),
        const SizedBox(height: 12),
        ...[
          {'label': 'Headline', 'value': mp['headline'] ?? '—'},
          {'label': 'Current Company', 'value': mp['current_company'] ?? '—'},
          {'label': 'Job Title', 'value': mp['current_job_title'] ?? '—'},
          {'label': 'Location', 'value': mp['location'] ?? '—'},
          {'label': 'Mentoring Style', 'value': mp['mentoring_style'] ?? '—'},
          {
            'label': 'Session Price',
            'value': mp['session_price'] != null
                ? '${mp['currency'] ?? 'USD'} ${mp['session_price']}'
                : 'Free',
          },
        ].map(
          (e) => Container(
            margin: const EdgeInsets.only(bottom: 9),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e['label']!,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.38),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  e['value']!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MentorHistoryTab extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onRefresh;

  const _MentorHistoryTab({required this.profile, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final eduItems = (profile['education'] as List<dynamic>?) ?? [];
    final workItems = (profile['work_experience'] as List<dynamic>?) ?? [];

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        const PageHeader(
          title: 'Background',
          subtitle: 'Education & work history',
        ),
        const SizedBox(height: 20),
        const SectionTitle(title: 'Education'),
        const SizedBox(height: 10),
        AddButton(
          label: 'Add Education',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EducationFormPage()),
          ).then((_) => onRefresh()),
        ),
        const SizedBox(height: 10),
        if (eduItems.isEmpty)
          const EmptyState(
            icon: Icons.school_outlined,
            message: 'No education added yet.',
          )
        else
          ...eduItems.map((e) {
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
        const SizedBox(height: 24),
        const SectionTitle(title: 'Work Experience'),
        const SizedBox(height: 10),
        AddButton(
          label: 'Add Work Experience',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WorkExperienceFormPage()),
          ).then((_) => onRefresh()),
        ),
        const SizedBox(height: 10),
        if (workItems.isEmpty)
          const EmptyState(
            icon: Icons.work_outline,
            message: 'No work experience added yet.',
          )
        else
          ...workItems.map((w) {
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
        const SizedBox(height: 20),
      ],
    );
  }
}

class _MStatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MStatBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryCyan, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.38),
              fontSize: 10,
            ),
          ),
        ],
      ),
    ),
  );
}
