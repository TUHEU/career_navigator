// presentation/screens/settings/settings_page.dart
// v9 — Redesigned with profile header, sections cards, improved visual
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/datasources/local/token_store.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guest_provider.dart';
import '../../../providers/theme_provider.dart';
import '../auth/sign_in_page.dart';
import '../profile/edit_profile_page.dart';
import 'about_us_page.dart';
import 'help_faq_page.dart';
import 'privacy_policy_page.dart';
import 'send_feedback_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final theme = context.watch<ThemeProvider>();
    final lang = context.watch<LanguageProvider>();
    final auth = context.read<AuthProvider>();
    final guest = context.watch<GuestProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text(
              lang.t(S.settings),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.text(isDark),
              ),
            ),
            const SizedBox(height: 20),

            // ── Profile hero card ────────────────────────────────
            if (!guest.isGuest) ...[
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    ),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isDark
                              ? [
                                const Color(0xFF0D1F2D),
                                const Color(0xFF0A1628),
                              ]
                              : [
                                const Color(0xFFE0F7FA),
                                const Color(0xFFEFF8FF),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primaryCyan.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.primaryCyan.withOpacity(
                          0.15,
                        ),
                        backgroundImage:
                            user?.profilePictureUrl != null
                                ? NetworkImage(user!.profilePictureUrl!)
                                : null,
                        child:
                            user?.profilePictureUrl == null
                                ? Text(
                                  (user?.displayName ?? 'U').isNotEmpty
                                      ? (user?.displayName ?? 'U')[0]
                                          .toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: AppColors.primaryCyan,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
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
                                color: AppColors.text(isDark),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                color: AppColors.textMuted(isDark),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Edit Profile →',
                              style: TextStyle(
                                color: AppColors.primaryCyan,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── Guest banner ──────────────────────────────────────
            if (guest.isGuest) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      color: AppColors.warning,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.t(S.guestMode),
                            style: const TextStyle(
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            lang.t(S.guestWarning),
                            style: TextStyle(
                              color: AppColors.warning.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ── APPEARANCE ────────────────────────────────────────
            _Section(
              title: lang.t(S.appearance),
              isDark: isDark,
              children: [
                _SwitchTile(
                  icon: isDark ? Icons.dark_mode : Icons.light_mode_outlined,
                  label: lang.t(S.darkMode),
                  value: isDark,
                  onChanged: (_) => theme.toggleTheme(),
                  isDark: isDark,
                ),
                _LanguageTile(lang: lang, isDark: isDark),
              ],
            ),
            const SizedBox(height: 16),

            // ── ACCOUNT ───────────────────────────────────────────
            if (!guest.isGuest) ...[
              _Section(
                title: lang.t(S.account),
                isDark: isDark,
                children: [
                  _Tile(
                    icon: Icons.person_outline_rounded,
                    label: lang.t(S.editProfile),
                    isDark: isDark,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        ),
                  ),
                  _Tile(
                    icon: Icons.lock_outline_rounded,
                    label: lang.t(S.changePassword),
                    isDark: isDark,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const _ChangePasswordPage(),
                          ),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // ── SUPPORT ───────────────────────────────────────────
            _Section(
              title: lang.t(S.support),
              isDark: isDark,
              children: [
                _Tile(
                  icon: Icons.help_outline_rounded,
                  label: lang.t(S.helpFaq),
                  isDark: isDark,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpFaqPage()),
                      ),
                ),
                _Tile(
                  icon: Icons.info_outline_rounded,
                  label: lang.t(S.aboutUs),
                  isDark: isDark,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AboutUsPage()),
                      ),
                ),
                _Tile(
                  icon: Icons.privacy_tip_outlined,
                  label: lang.t(S.privacyPolicy),
                  isDark: isDark,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacyPolicyPage(),
                        ),
                      ),
                ),
                if (!guest.isGuest)
                  _Tile(
                    icon: Icons.feedback_outlined,
                    label: lang.t(S.sendFeedback),
                    isDark: isDark,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SendFeedbackPage(),
                          ),
                        ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Logout / Sign in ──────────────────────────────────
            guest.isGuest
                ? _AuthButton(
                  label: lang.t(S.signIn),
                  icon: Icons.login_rounded,
                  color: AppColors.primaryCyan,
                  onTap: () {
                    context.read<GuestProvider>().exitGuestMode();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInPage()),
                      (_) => false,
                    );
                  },
                )
                : _AuthButton(
                  label: lang.t(S.logout),
                  icon: Icons.logout_rounded,
                  color: AppColors.danger,
                  onTap: () async {
                    await auth.logout();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInPage()),
                        (_) => false,
                      );
                    }
                  },
                ),
            const SizedBox(height: 24),

            // Version
            Center(
              child: Text(
                'Career Navigator v7.0',
                style: TextStyle(
                  color: AppColors.textMuted(isDark),
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Section container ─────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<Widget> children;
  const _Section({
    required this.title,
    required this.isDark,
    required this.children,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.primaryCyan,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
      Container(
        decoration: BoxDecoration(
          color: AppColors.card(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Column(
          children:
              children.asMap().entries.map((e) {
                final isLast = e.key == children.length - 1;
                return Column(
                  children: [
                    e.value,
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 52,
                        color: AppColors.border(isDark),
                      ),
                  ],
                );
              }).toList(),
        ),
      ),
    ],
  );
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final Color? iconColor;
  const _Tile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
    this.iconColor,
  });
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: (iconColor ?? AppColors.primaryCyan).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: iconColor ?? AppColors.primaryCyan, size: 18),
    ),
    title: Text(
      label,
      style: TextStyle(
        color: iconColor ?? AppColors.text(isDark),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    trailing: Icon(
      Icons.chevron_right_rounded,
      color: AppColors.textMuted(isDark),
      size: 20,
    ),
    onTap: onTap,
    dense: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;
  const _SwitchTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) => SwitchListTile(
    secondary: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppColors.primaryCyan, size: 18),
    ),
    title: Text(
      label,
      style: TextStyle(
        color: AppColors.text(isDark),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    value: value,
    onChanged: onChanged,
    activeColor: AppColors.primaryCyan,
    dense: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );
}

class _LanguageTile extends StatelessWidget {
  final LanguageProvider lang;
  final bool isDark;
  const _LanguageTile({required this.lang, required this.isDark});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.language_rounded,
        color: AppColors.primaryCyan,
        size: 18,
      ),
    ),
    title: Text(
      lang.t(S.language),
      style: TextStyle(
        color: AppColors.text(isDark),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          lang.languageCode == 'en' ? '🇬🇧 English' : '🇫🇷 Français',
          style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 13),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textMuted(isDark),
          size: 20,
        ),
      ],
    ),
    dense: true,
    onTap: () => _showLangPicker(context),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  void _showLangPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  lang.t(S.language),
                  style: TextStyle(
                    color: AppColors.text(isDark),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...['en', 'fr'].map((code) {
                  final label =
                      code == 'en' ? '🇬🇧  English' : '🇫🇷  Français';
                  final sel = lang.languageCode == code;
                  return ListTile(
                    title: Text(
                      label,
                      style: TextStyle(
                        color:
                            sel
                                ? AppColors.primaryCyan
                                : AppColors.text(isDark),
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing:
                        sel
                            ? const Icon(
                              Icons.check_circle,
                              color: AppColors.primaryCyan,
                            )
                            : null,
                    onTap: () {
                      lang.setLanguage(
                        code == 'fr' ? AppLanguage.french : AppLanguage.english,
                      );
                      Navigator.pop(context);
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _AuthButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Change Password Page ──────────────────────────────────────────
class _ChangePasswordPage extends StatefulWidget {
  const _ChangePasswordPage();
  @override
  State<_ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<_ChangePasswordPage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _obs1 = true, _obs2 = true, _obs3 = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _change() async {
    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(
      const Duration(seconds: 1),
    ); // replace with actual API call
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: Text(
          'Change Password',
          style: TextStyle(color: AppColors.text(isDark)),
        ),
        backgroundColor: AppColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(isDark)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _passField(
              'Current Password',
              _currentCtrl,
              _obs1,
              () => setState(() => _obs1 = !_obs1),
              isDark,
            ),
            _passField(
              'New Password',
              _newCtrl,
              _obs2,
              () => setState(() => _obs2 = !_obs2),
              isDark,
            ),
            _passField(
              'Confirm New Password',
              _confirmCtrl,
              _obs3,
              () => setState(() => _obs3 = !_obs3),
              isDark,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _change,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child:
                    _loading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                        : const Text(
                          'Change Password',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passField(
    String label,
    TextEditingController ctrl,
    bool obs,
    VoidCallback toggle,
    bool isDark,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextField(
      controller: ctrl,
      obscureText: obs,
      style: TextStyle(color: AppColors.text(isDark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textMuted(isDark)),
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppColors.primaryCyan,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obs ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.primaryCyan,
          ),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: AppColors.card(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryCyan),
        ),
      ),
    ),
  );
}
