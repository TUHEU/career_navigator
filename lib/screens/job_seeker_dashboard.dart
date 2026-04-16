import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../services/token_store.dart';
import '../theme/app_theme.dart';
import 'sign_in_page.dart';
import 'education_form_page.dart';
import 'work_experience_form_page.dart';
import 'settings_page.dart';

class JobSeekerDashboard extends StatefulWidget {
  const JobSeekerDashboard({super.key});

  @override
  State<JobSeekerDashboard> createState() =>
      _JobSeekerDashboardState();
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
      if (token == null) { _logout(); return; }
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
          (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppThemeProvider>();
    final pages = [
      _JSHomePage(
          profile: _profile,
          loading: _loading,
          onRefresh: _loadProfile),
      _EducationPage(
          profile: _profile ?? {},
          onRefresh: _loadProfile),
      _ExperiencePage(
          profile: _profile ?? {},
          onRefresh: _loadProfile),
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
          Container(
              color: AppColors.darkBackground.withOpacity(0.80)),
          SafeArea(child: pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          _NavItem(Icons.home_outlined,       Icons.home,             'Home'),
          _NavItem(Icons.school_outlined,     Icons.school,           'Education'),
          _NavItem(Icons.work_outline,        Icons.work,             'Experience'),
          _NavItem(Icons.settings_outlined,   Icons.settings,         'Settings'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// HOME TAB
// ─────────────────────────────────────────────────────────
class _JSHomePage extends StatelessWidget {
  final Map<String, dynamic>? profile;
  final bool loading;
  final VoidCallback onRefresh;

  const _JSHomePage(
      {required this.profile,
      required this.loading,
      required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
          child: CircularProgressIndicator(
              color: AppColors.primaryCyan));
    }

    final p          = profile ?? {};
    final name       = (p['full_name'] as String?) ??
        (p['email'] as String?) ?? 'User';
    final email      = (p['email']       as String?) ?? '';
    final headline   = (p['headline']    as String?) ?? 'Job Seeker';
    final pictureUrl = p['profile_picture'] as String?;
    final dob        = (p['date_of_birth']       as String?) ?? '—';
    final location   = (p['location']            as String?) ?? '—';
    final currentJob = (p['current_job_title']   as String?) ?? '—';
    final desiredJob = (p['desired_job_title']   as String?) ?? '—';
    final yoe        = p['years_of_experience'];
    final avail      = (p['availability']         as String?) ?? '—';

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 16),
        children: [
          // Top bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CAREER NAVIGATOR',
                      style: TextStyle(
                          color: AppColors.primaryCyan,
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Job Seeker Dashboard',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12)),
                ],
              ),
              _avatarWidget(pictureUrl, radius: 22),
            ],
          ),
          const SizedBox(height: 20),

          // Profile card
          _ProfileCard(
            name: name,
            headline: headline,
            email: email,
            pictureUrl: pictureUrl,
            badge: 'Job Seeker',
            badgeIcon: Icons.search_rounded,
          ),
          const SizedBox(height: 20),

          // Stats row
          Row(
            children: [
              _StatBox(
                label: 'Experience',
                value: yoe != null ? '$yoe yrs' : '—',
                icon: Icons.signal_cellular_alt,
              ),
              const SizedBox(width: 12),
              _StatBox(
                label: 'Availability',
                value: avail.replaceAll('_', ' '),
                icon: Icons.hourglass_top_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Info tiles
          _sectionTitle('Personal Info'),
          const SizedBox(height: 10),
          _infoTile(Icons.cake_outlined,         'Date of Birth',   dob),
          _infoTile(Icons.location_on_outlined,  'Location',        location),
          _infoTile(Icons.email_outlined,        'Email',           email),
          const SizedBox(height: 20),

          _sectionTitle('Career Info'),
          const SizedBox(height: 10),
          _infoTile(Icons.work_outline,          'Current Role',    currentJob),
          _infoTile(Icons.flag_outlined,         'Desired Role',    desiredJob),

          const SizedBox(height: 20),
          // Coming soon banner
          _ComingSoonBanner(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _avatarWidget(String? url, {double radius = 36}) =>
      CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
        backgroundImage: url != null ? NetworkImage(url) : null,
        child: url == null
            ? Icon(Icons.person,
                color: AppColors.primaryCyan, size: radius * 0.9)
            : null,
      );

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(
          color: AppColors.primaryCyan,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1));

  Widget _infoTile(IconData icon, String label, String value) =>
      Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.symmetric(
            horizontal: 15, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(13),
          border:
              Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryCyan, size: 18),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.38),
                        fontSize: 10)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14)),
              ],
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────
// EDUCATION TAB
// ─────────────────────────────────────────────────────────
class _EducationPage extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onRefresh;
  const _EducationPage(
      {required this.profile, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final items =
        (profile['education'] as List<dynamic>?) ?? [];
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 16),
        children: [
          _PageHeader(title: 'Education', subtitle: 'Your academic history'),
          const SizedBox(height: 16),
          _AddButton(
            label: 'Add Education',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const EducationFormPage()),
            ).then((_) => onRefresh()),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            _EmptyState(
                icon: Icons.school_outlined,
                message:
                    'No education entries yet.\nTap + to add one.')
          else
            ...items.map((e) {
              final item = e as Map<String, dynamic>;
              return _EducationCard(
                item: item,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          EducationFormPage(existing: item)),
                ).then((_) => onRefresh()),
                onDelete: () async {
                  final token = await TokenStore.getAccess();
                  if (token == null) return;
                  await ApiService.deleteEducation(
                      token: token, id: item['id'] as int);
                  onRefresh();
                },
              );
            }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// EXPERIENCE TAB
// ─────────────────────────────────────────────────────────
class _ExperiencePage extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onRefresh;
  const _ExperiencePage(
      {required this.profile, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final items =
        (profile['work_experience'] as List<dynamic>?) ?? [];
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(
            horizontal: 20, vertical: 16),
        children: [
          _PageHeader(
              title: 'Work Experience',
              subtitle: 'Your career history'),
          const SizedBox(height: 16),
          _AddButton(
            label: 'Add Work Experience',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      const WorkExperienceFormPage()),
            ).then((_) => onRefresh()),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            _EmptyState(
                icon: Icons.work_outline,
                message:
                    'No work experience yet.\nTap + to add one.')
          else
            ...items.map((w) {
              final item = w as Map<String, dynamic>;
              return _WorkCard(
                item: item,
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          WorkExperienceFormPage(
                              existing: item)),
                ).then((_) => onRefresh()),
                onDelete: () async {
                  final token = await TokenStore.getAccess();
                  if (token == null) return;
                  await ApiService.deleteWorkExperience(
                      token: token, id: item['id'] as int);
                  onRefresh();
                },
              );
            }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Shared card widgets
// ─────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final String name, headline, email;
  final String? pictureUrl;
  final String badge;
  final IconData badgeIcon;

  const _ProfileCard({
    required this.name,
    required this.headline,
    required this.email,
    required this.pictureUrl,
    required this.badge,
    required this.badgeIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: AppColors.primaryCyan.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
              color: AppColors.primaryCyan.withOpacity(0.06),
              blurRadius: 20)
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 38,
            backgroundColor:
                AppColors.primaryCyan.withOpacity(0.2),
            backgroundImage: pictureUrl != null
                ? NetworkImage(pictureUrl!)
                : null,
            child: pictureUrl == null
                ? const Icon(Icons.person,
                    color: AppColors.primaryCyan, size: 32)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(headline,
                    style: const TextStyle(
                        color: AppColors.primaryCyan,
                        fontSize: 13)),
                const SizedBox(height: 3),
                Text(email,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primaryCyan
                            .withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon,
                          color: AppColors.primaryCyan,
                          size: 12),
                      const SizedBox(width: 5),
                      Text(badge,
                          style: const TextStyle(
                              color: AppColors.primaryCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ],
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

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const _StatBox(
      {required this.label,
      required this.value,
      required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(
          vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              color: AppColors.primaryCyan, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11)),
        ],
      ),
    ),
  );
}

class _ComingSoonBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.primaryCyan.withOpacity(0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
          color: AppColors.primaryCyan.withOpacity(0.15)),
    ),
    child: Row(
      children: [
        const Icon(Icons.rocket_launch_outlined,
            color: AppColors.primaryCyan, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('More features coming soon',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
              const SizedBox(height: 3),
              Text('Job listings, AI match & more.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 12)),
            ],
          ),
        ),
      ],
    ),
  );
}

class _EducationCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit, onDelete;
  const _EducationCard(
      {required this.item,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isCurrent =
        item['is_current'] == 1 || item['is_current'] == true;
    final endLabel =
        isCurrent ? 'Present' : '${item['end_year'] ?? ''}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withOpacity(0.07)),
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
            child: const Icon(Icons.school_outlined,
                color: AppColors.primaryCyan, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['institution'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 3),
                Text(
                    '${item['degree']} · ${item['field_of_study']}',
                    style: const TextStyle(
                        color: AppColors.primaryCyan,
                        fontSize: 12)),
                const SizedBox(height: 3),
                Text(
                    '${item['start_year']} – $endLabel',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11)),
              ],
            ),
          ),
          _ActionBtns(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

class _WorkCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit, onDelete;
  const _WorkCard(
      {required this.item,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isCurrent =
        item['is_current'] == 1 || item['is_current'] == true;
    final endLabel =
        isCurrent ? 'Present' : (item['end_date'] ?? '');
    final empType =
        (item['employment_type'] as String? ?? '')
            .replaceAll('_', ' ')
            .toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: Colors.white.withOpacity(0.07)),
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
            child: const Icon(Icons.business_center_outlined,
                color: AppColors.primaryCyan, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['job_title'] ?? '',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 3),
                Text(item['company'] ?? '',
                    style: const TextStyle(
                        color: AppColors.primaryCyan,
                        fontSize: 12)),
                const SizedBox(height: 3),
                Row(children: [
                  Text(
                      '${item['start_date']} – $endLabel',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 11)),
                  if (empType.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(empType,
                          style: TextStyle(
                              color:
                                  Colors.white.withOpacity(0.4),
                              fontSize: 10)),
                    ),
                  ]
                ]),
              ],
            ),
          ),
          _ActionBtns(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Micro widgets
// ─────────────────────────────────────────────────────────
class _PageHeader extends StatelessWidget {
  final String title, subtitle;
  const _PageHeader(
      {required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(subtitle,
          style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 13)),
    ],
  );
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddButton(
      {required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppColors.primaryCyan.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_circle_outline,
              color: AppColors.primaryCyan, size: 19),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                  color: AppColors.primaryCyan,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState(
      {required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 50),
    child: Column(children: [
      Icon(icon, color: Colors.white10, size: 52),
      const SizedBox(height: 14),
      Text(message,
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.white.withOpacity(0.28),
              fontSize: 13,
              height: 1.7)),
    ]),
  );
}

class _ActionBtns extends StatelessWidget {
  final VoidCallback onEdit, onDelete;
  const _ActionBtns(
      {required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => Column(children: [
    IconButton(
      icon: const Icon(Icons.edit_outlined,
          color: AppColors.primaryCyan, size: 17),
      onPressed: onEdit,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    ),
    const SizedBox(height: 6),
    IconButton(
      icon: Icon(Icons.delete_outline,
          color: Colors.redAccent.withOpacity(0.65),
          size: 17),
      onPressed: onDelete,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    ),
  ]);
}

// ─────────────────────────────────────────────────────────
// Bottom Nav
// ─────────────────────────────────────────────────────────
class _NavItem {
  final IconData outlinedIcon, filledIcon;
  final String label;
  const _NavItem(this.outlinedIcon, this.filledIcon, this.label);
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
            top: BorderSide(
                color: Colors.white.withOpacity(0.08))),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item    = items[i];
              final sel     = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppColors.primaryCyan.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sel
                            ? item.filledIcon
                            : item.outlinedIcon,
                        color: sel
                            ? AppColors.primaryCyan
                            : Colors.white38,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(item.label,
                          style: TextStyle(
                              color: sel
                                  ? AppColors.primaryCyan
                                  : Colors.white38,
                              fontSize: 10,
                              fontWeight: sel
                                  ? FontWeight.bold
                                  : FontWeight.normal)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
