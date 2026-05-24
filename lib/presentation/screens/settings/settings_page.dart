// presentation/screens/settings/settings_page.dart
// IMPROVED: Language switcher (EN/FR), better design, theme-aware
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../auth/sign_in_page.dart';
import '../profile/edit_profile_page.dart';
import 'about_us_page.dart';
import 'help_faq_page.dart';
import 'privacy_policy_page.dart';
import 'send_feedback_page.dart';

// ── Change Password Page ──────────────────────────────────────
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    setState(() => _loading = true);
    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) {
      setState(() => _loading = false);
      return;
    }
    final res = await ApiService().changePassword(
      token,
      _currentCtrl.text,
      _newCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(res['message'] ?? 'Failed')));
    }
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    bool show,
    VoidCallback toggle,
    bool isDark,
  ) {
    return TextField(
      controller: ctrl,
      obscureText: !show,
      style: TextStyle(color: AppColors.text(isDark)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.textSecondary(isDark)),
        filled: true,
        fillColor: AppColors.inputFill(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border(isDark)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryCyan, width: 2),
        ),
        suffixIcon: IconButton(
          onPressed: toggle,
          icon: Icon(
            show ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textMuted(isDark),
            size: 20,
          ),
        ),
      ),
    );
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
        backgroundColor: AppColors.surface(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(isDark)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _field(
              'Current Password',
              _currentCtrl,
              _showCurrent,
              () => setState(() => _showCurrent = !_showCurrent),
              isDark,
            ),
            const SizedBox(height: 16),
            _field(
              'New Password',
              _newCtrl,
              _showNew,
              () => setState(() => _showNew = !_showNew),
              isDark,
            ),
            const SizedBox(height: 16),
            _field(
              'Confirm New Password',
              _confirmCtrl,
              _showConfirm,
              () => setState(() => _showConfirm = !_showConfirm),
              isDark,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCyan,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    )
                  : const Text(
                      'Change Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Settings Page ─────────────────────────────────────────────
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 12),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.primaryCyan,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.3,
      ),
    ),
  );

  Widget _buildTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    Color? labelColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: labelColor ?? AppColors.primaryCyan,
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: labelColor ?? AppColors.text(isDark),
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.textMuted(isDark),
          size: 20,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.primaryCyan, size: 22),
        title: Text(
          label,
          style: TextStyle(
            color: AppColors.text(isDark),
            fontWeight: FontWeight.w500,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primaryCyan,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  void _showLanguagePicker(
    BuildContext context,
    LanguageProvider lang,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface(isDark),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
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
              'Choose Language',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.text(isDark),
              ),
            ),
            const SizedBox(height: 20),
            for (final option in [
              (AppLanguage.english, '🇬🇧 English'),
              (AppLanguage.french, '🇫🇷 Français'),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () async {
                    await lang.setLanguage(option.$1);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: lang.language == option.$1
                          ? AppColors.primaryCyan.withValues(alpha: 0.12)
                          : AppColors.card(isDark),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: lang.language == option.$1
                            ? AppColors.primaryCyan
                            : AppColors.border(isDark),
                        width: lang.language == option.$1 ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          option.$2,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: lang.language == option.$1
                                ? AppColors.primaryCyan
                                : AppColors.text(isDark),
                          ),
                        ),
                        const Spacer(),
                        if (lang.language == option.$1)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryCyan,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final theme = context.watch<ThemeProvider>();
    final lang = context.watch<LanguageProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text(
              lang.t('settings'),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.text(isDark),
              ),
            ),
            const SizedBox(height: 28),

            _sectionLabel(lang.t('appearance')),
            _buildSwitchTile(
              icon: isDark ? Icons.dark_mode : Icons.light_mode,
              label: lang.t('darkMode'),
              value: isDark,
              onChanged: (_) => theme.toggleTheme(),
              isDark: isDark,
            ),
            // Language selector
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.language,
                  color: AppColors.primaryCyan,
                  size: 22,
                ),
                title: Text(
                  lang.t('language'),
                  style: TextStyle(
                    color: AppColors.text(isDark),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: GestureDetector(
                  onTap: () => _showLanguagePicker(context, lang, isDark),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryCyan.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      lang.languageLabel,
                      style: const TextStyle(
                        color: AppColors.primaryCyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                onTap: () => _showLanguagePicker(context, lang, isDark),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 28),
            _sectionLabel(lang.t('account')),
            _buildTile(
              icon: Icons.person_outline,
              label: lang.t('editProfile'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              ),
              isDark: isDark,
            ),
            _buildTile(
              icon: Icons.lock_outline,
              label: lang.t('changePassword'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              ),
              isDark: isDark,
            ),

            const SizedBox(height: 28),
            _sectionLabel(lang.t('support')),
            _buildTile(
              icon: Icons.help_outline,
              label: lang.t('helpFaq'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpFaqPage()),
              ),
              isDark: isDark,
            ),
            _buildTile(
              icon: Icons.info_outline,
              label: lang.t('aboutUs'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsPage()),
              ),
              isDark: isDark,
            ),
            _buildTile(
              icon: Icons.privacy_tip_outlined,
              label: lang.t('privacyPolicy'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
              ),
              isDark: isDark,
            ),
            _buildTile(
              icon: Icons.feedback_outlined,
              label: lang.t('sendFeedback'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SendFeedbackPage()),
              ),
              isDark: isDark,
            ),

            const SizedBox(height: 28),
            // Logout
            Container(
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.danger.withValues(alpha: 0.25),
                ),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppColors.danger),
                title: Text(
                  lang.t('logout'),
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w600,
                  ),
                ),
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
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
