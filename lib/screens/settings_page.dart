import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/token_store.dart';
import '../theme/app_theme.dart';
import 'sign_in_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppThemeProvider>();
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
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 16),
              children: [
                // ── Header ──────────────────────────────────
                const Text('Settings',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),

                // ── Theme / Background ───────────────────────
                _sectionLabel('App Theme'),
                const SizedBox(height: 12),
                _ThemePicker(theme: theme),
                const SizedBox(height: 28),

                // ── Account section ─────────────────────────
                _sectionLabel('Account'),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.person_outline,
                  label: 'Edit Profile',
                  onTap: () =>
                      _snack(context, 'Open profile setup'),
                ),
                _SettingsTile(
                  icon: Icons.lock_outline,
                  label: 'Change Password',
                  onTap: () =>
                      _snack(context, 'Coming soon'),
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () =>
                      _snack(context, 'Coming soon'),
                ),
                _SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy & Security',
                  onTap: () =>
                      _snack(context, 'Coming soon'),
                ),
                const SizedBox(height: 28),

                // ── Support section ──────────────────────────
                _sectionLabel('Support'),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.help_outline,
                  label: 'Help & FAQ',
                  onTap: () =>
                      _snack(context, 'Coming soon'),
                ),
                _SettingsTile(
                  icon: Icons.feedback_outlined,
                  label: 'Send Feedback',
                  onTap: () =>
                      _snack(context, 'Coming soon'),
                ),
                _SettingsTile(
                  icon: Icons.info_outline,
                  label: 'About Career Navigator',
                  onTap: () => _showAbout(context),
                ),
                const SizedBox(height: 28),

                // ── Danger zone ──────────────────────────────
                _sectionLabel('Account Actions'),
                const SizedBox(height: 12),
                _SettingsTile(
                  icon: Icons.delete_outline,
                  label: 'Delete Account',
                  color: Colors.redAccent,
                  onTap: () =>
                      _confirmDelete(context),
                ),
                const SizedBox(height: 8),
                // Logout button
                GestureDetector(
                  onTap: () => _logout(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color:
                              Colors.redAccent.withOpacity(0.35)),
                    ),
                    child: const Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout,
                            color: Colors.redAccent, size: 20),
                        SizedBox(width: 10),
                        Text('Log Out',
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
            color: AppColors.primaryCyan,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2),
      );

  Future<void> _logout(BuildContext context) async {
    await TokenStore.clear();
    if (context.mounted)
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
          (_) => false);
  }

  void _snack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Career Navigator',
            style: TextStyle(color: Colors.white)),
        content: Text(
            'Version 2.0\nBuilt to connect job seekers and mentors.',
            style: TextStyle(
                color: Colors.white.withOpacity(0.65))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close',
                  style: TextStyle(
                      color: AppColors.primaryCyan)))
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text('Delete Account',
            style: TextStyle(color: Colors.white)),
        content: Text(
            'This will permanently delete your account. Are you sure?',
            style: TextStyle(
                color: Colors.white.withOpacity(0.65))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5)))),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _snack(context, 'Coming soon');
              },
              child: const Text('Delete',
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Theme Picker Widget
// ─────────────────────────────────────────────────────────
class _ThemePicker extends StatelessWidget {
  final AppThemeProvider theme;
  const _ThemePicker({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppBackground.values.map((bg) {
        final selected = theme.background == bg;
        return Expanded(
          child: GestureDetector(
            onTap: () => theme.setBackground(bg),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              height: 110,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected
                      ? AppColors.primaryCyan
                      : Colors.white.withOpacity(0.12),
                  width: selected ? 2.5 : 1,
                ),
                image: DecorationImage(
                  image: AssetImage(bg.assetPath),
                  fit: BoxFit.cover,
                  opacity: 0.75,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: selected
                      ? AppColors.primaryCyan.withOpacity(0.18)
                      : Colors.black.withOpacity(0.35),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (selected)
                      const Icon(Icons.check_circle,
                          color: AppColors.primaryCyan,
                          size: 20),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(bg.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: selected
                                  ? AppColors.primaryCyan
                                  : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Reusable settings tile
// ─────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(
            horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Icon(icon, color: c.withOpacity(0.8), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: c, fontSize: 14)),
            ),
            Icon(Icons.chevron_right,
                color: Colors.white.withOpacity(0.25),
                size: 18),
          ],
        ),
      ),
    );
  }
}
