import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_store.dart';
import '../theme/app_theme.dart';
import 'sign_in_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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
          // ── bg8 as dashboard background ───────────────────────
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/bg8.png'),
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
            ),
          ),
          Container(
            color: AppColors.darkBackground.withOpacity(0.80),
          ),
          SafeArea(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryCyan,
                    ),
                  )
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final p = _profile ?? {};
    final name =
        (p['full_name'] as String?) ?? (p['email'] as String?) ?? 'User';
    final email = (p['email'] as String?) ?? '';
    final role = (p['role'] as String?) ?? 'job_seeker';
    final headline = (p['headline'] as String?) ?? 'Job Seeker';
    final pictureUrl = p['profile_picture'] as String?;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      color: AppColors.primaryCyan,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        children: [
          // ── Top bar ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CAREER NAVIGATOR',
                style: TextStyle(
                  color: AppColors.primaryCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                onPressed: _logout,
              ),
            ],
          ),
          const SizedBox(height: 30),

          // ── Profile card with bg8 overlay feel ───────────────
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              // Subtle bg8 visible through the card
              image: const DecorationImage(
                image: AssetImage('assets/background/bg8.png'),
                fit: BoxFit.cover,
                opacity: 0.18,
              ),
              border: Border.all(
                color: AppColors.primaryCyan.withOpacity(0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCyan.withOpacity(0.08),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.07),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  // Avatar
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
                        backgroundImage: pictureUrl != null
                            ? NetworkImage(pictureUrl)
                            : null,
                        child: pictureUrl == null
                            ? const Icon(
                                Icons.person,
                                color: AppColors.primaryCyan,
                                size: 44,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryCyan,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.black,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    headline,
                    style: const TextStyle(
                      color: AppColors.primaryCyan,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _roleBadge(role),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Info tiles ────────────────────────────────────────
          _infoTile(icon: Icons.badge_outlined, label: 'Full name', value: name),
          _infoTile(icon: Icons.email_outlined, label: 'Email', value: email),
          _infoTile(
            icon: Icons.cake_outlined,
            label: 'Date of birth',
            value: (p['date_of_birth'] as String?) ?? '—',
          ),
          _infoTile(
            icon: Icons.work_outline,
            label: 'Current role',
            value: (p['current_job_title'] as String?) ?? '—',
          ),
          _infoTile(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: (p['location'] as String?) ?? '—',
          ),
          _infoTile(
            icon: Icons.signal_cellular_alt,
            label: 'Experience',
            value: p['years_of_experience'] != null
                ? '${p['years_of_experience']} years'
                : '—',
          ),

          const SizedBox(height: 30),

          // ── Coming soon banner ────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryCyan.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.rocket_launch_outlined,
                  color: AppColors.primaryCyan,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'More features coming soon',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Job listings, mentors, and more.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.55),
                          fontSize: 13,
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

  Widget _roleBadge(String role) {
    final label = role == 'job_seeker'
        ? 'Job Seeker'
        : role == 'mentor'
            ? 'Mentor'
            : 'Admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryCyan,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryCyan, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.45),
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
