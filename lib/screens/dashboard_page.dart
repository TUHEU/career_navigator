import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_store.dart';
import '../core/themes/app_theme.dart';
import 'sign_in_page.dart';
import 'education_form_page.dart';
import 'work_experience_form_page.dart';
import 'mentor_profile_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await TokenStore.clear();
    if (mounted)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/bg8.png'),
                fit: BoxFit.cover,
                opacity: 0.18,
              ),
            ),
          ),
          Container(color: AppColors.darkBackground.withOpacity(0.82)),
          SafeArea(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryCyan,
                    ),
                  )
                : _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    final p = _profile ?? {};
    final role = (p['role'] as String?) ?? 'job_seeker';

    return Column(
      children: [
        _buildTopBar(),
        _buildProfileCard(p, role),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Profile'),
              Tab(text: 'Education'),
              Tab(text: 'Experience'),
            ],
            labelColor: AppColors.primaryCyan,
            unselectedLabelColor: Colors.white38,
            indicator: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3)),
            ),
            dividerColor: Colors.transparent,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ProfileTab(profile: p, role: role, onRefresh: _loadProfile),
              _EducationTab(profile: p, onRefresh: _loadProfile),
              _WorkTab(profile: p, onRefresh: _loadProfile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'CAREER NAVIGATOR',
          style: TextStyle(
            color: AppColors.primaryCyan,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white54, size: 22),
          onPressed: _logout,
        ),
      ],
    ),
  );

  Widget _buildProfileCard(Map<String, dynamic> p, String role) {
    final name =
        (p['full_name'] as String?) ?? (p['email'] as String?) ?? 'User';
    final headline = (p['headline'] as String?) ?? '';
    final pictureUrl = p['profile_picture'] as String?;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        image: const DecorationImage(
          image: AssetImage('assets/background/bg8.png'),
          fit: BoxFit.cover,
          opacity: 0.16,
        ),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.22)),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
              backgroundImage: pictureUrl != null
                  ? NetworkImage(pictureUrl)
                  : null,
              child: pictureUrl == null
                  ? const Icon(
                      Icons.person,
                      color: AppColors.primaryCyan,
                      size: 30,
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (headline.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      headline,
                      style: const TextStyle(
                        color: AppColors.primaryCyan,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  _roleBadge(role),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleBadge(String role) {
    final label = role == 'mentor' ? 'Mentor' : 'Job Seeker';
    final icon = role == 'mentor' ? Icons.school_outlined : Icons.search;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryCyan, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryCyan,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// PROFILE TAB
// ─────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final Map<String, dynamic> profile;
  final String role;
  final VoidCallback onRefresh;
  const _ProfileTab({
    required this.profile,
    required this.role,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final p = profile;
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _tile(
            Icons.badge_outlined,
            'Full name',
            (p['full_name'] as String?) ?? '—',
          ),
          _tile(Icons.email_outlined, 'Email', (p['email'] as String?) ?? '—'),
          _tile(
            Icons.cake_outlined,
            'Date of birth',
            (p['date_of_birth'] as String?) ?? '—',
          ),
          _tile(Icons.phone_outlined, 'Phone', (p['phone'] as String?) ?? '—'),
          _tile(
            Icons.location_on_outlined,
            'Location',
            (p['location'] as String?) ?? '—',
          ),
          _tile(
            Icons.work_outline,
            'Current role',
            (p['current_job_title'] as String?) ?? '—',
          ),
          _tile(
            Icons.signal_cellular_alt,
            'Experience',
            p['years_of_experience'] != null
                ? '${p['years_of_experience']} yrs'
                : '—',
          ),
          if (role == 'job_seeker') ...[
            _tile(
              Icons.flag_outlined,
              'Desired role',
              (p['desired_job_title'] as String?) ?? '—',
            ),
            _tile(
              Icons.hourglass_top_outlined,
              'Availability',
              (p['availability'] as String?) ?? '—',
            ),
          ],
          if (role == 'mentor') ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MentorProfilePage(profile: profile),
                ),
              ).then((_) => onRefresh()),
              icon: const Icon(
                Icons.edit_outlined,
                size: 17,
                color: AppColors.primaryCyan,
              ),
              label: const Text(
                'Edit Mentor Profile',
                style: TextStyle(color: AppColors.primaryCyan),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryCyan),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 46),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryCyan.withOpacity(0.15),
              ),
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
                      const Text(
                        'More features coming soon',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Job listings, AI recommendations & more.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, String value) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.04),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: Colors.white.withOpacity(0.07)),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.primaryCyan, size: 18),
        const SizedBox(width: 13),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.38),
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────
// EDUCATION TAB
// ─────────────────────────────────────────────────────────
class _EducationTab extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onRefresh;
  const _EducationTab({required this.profile, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items = (profile['education'] as List<dynamic>?) ?? [];
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _AddButton(
            label: 'Add Education',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EducationFormPage()),
            ).then((_) => onRefresh()),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            _EmptyState(
              icon: Icons.school_outlined,
              message: 'No education entries yet.\nTap + to add one.',
            )
          else
            ...items.map((e) {
              final item = e as Map<String, dynamic>;
              return _EducationCard(
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

class _EducationCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _EducationCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = item['is_current'] == 1 || item['is_current'] == true;
    final endLabel = isCurrent ? 'Present' : '${item['end_year'] ?? ''}';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  item['institution'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item['degree']} · ${item['field_of_study']}',
                  style: const TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${item['start_year']} – $endLabel',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          _ActionButtons(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// WORK EXPERIENCE TAB
// ─────────────────────────────────────────────────────────
class _WorkTab extends StatelessWidget {
  final Map<String, dynamic> profile;
  final VoidCallback onRefresh;
  const _WorkTab({required this.profile, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items =
        (profile['work_experience'] as List<dynamic>?) ?? [];
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _AddButton(
            label: 'Add Work Experience',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkExperienceFormPage()),
            ).then((_) => onRefresh()),
          ),
          const SizedBox(height: 16),
          if (items.isEmpty)
            _EmptyState(
              icon: Icons.work_outline,
              message: 'No work experience yet.\nTap + to add one.',
            )
          else
            ...items.map((w) {
              final item = w as Map<String, dynamic>;
              return _WorkCard(
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

class _WorkCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _WorkCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = item['is_current'] == 1 || item['is_current'] == true;
    final endLabel = isCurrent ? 'Present' : (item['end_date'] ?? '');
    final empType = (item['employment_type'] as String? ?? '')
        .replaceAll('_', ' ')
        .toUpperCase();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  item['job_title'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item['company'] ?? '',
                  style: const TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '${item['start_date']} – $endLabel',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 11,
                      ),
                    ),
                    if (empType.isNotEmpty) ...[
                      const SizedBox(width: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          empType,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          _ActionButtons(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Shared widgets
// ─────────────────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.28)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_circle_outline,
            color: AppColors.primaryCyan,
            size: 19,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryCyan,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 50),
    child: Column(
      children: [
        Icon(icon, color: Colors.white10, size: 52),
        const SizedBox(height: 14),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withOpacity(0.28),
            fontSize: 13,
            height: 1.7,
          ),
        ),
      ],
    ),
  );
}

class _ActionButtons extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _ActionButtons({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      IconButton(
        icon: const Icon(
          Icons.edit_outlined,
          color: AppColors.primaryCyan,
          size: 17,
        ),
        onPressed: onEdit,
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
        onPressed: onDelete,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    ],
  );
}
