import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/buttons.dart';
import 'about_us_page.dart';
import 'help_faq_page.dart';
import 'privacy_policy_page.dart';
import 'send_feedback_page.dart';
import '../profile/edit_profile_page.dart';
import '../auth/sign_in_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 24),

            // Appearance Section
            _sectionLabel('Appearance', isDark),
            const SizedBox(height: 12),
            _buildThemeTile(isDark, themeProvider),
            const SizedBox(height: 28),

            // Account Section
            _sectionLabel('Account', isDark),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.person_outline,
              label: 'Edit Profile',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              ),
              isDark: isDark,
            ),
            _buildSettingsTile(
              icon: Icons.lock_outline,
              label: 'Change Password',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 28),

            // Support Section
            _sectionLabel('Support', isDark),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.help_outline,
              label: 'Help & FAQ',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HelpFaqPage()),
              ),
              isDark: isDark,
            ),
            _buildSettingsTile(
              icon: Icons.feedback_outlined,
              label: 'Send Feedback',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SendFeedbackPage()),
              ),
              isDark: isDark,
            ),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacy Policy',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()),
              ),
              isDark: isDark,
            ),
            _buildSettingsTile(
              icon: Icons.info_outline,
              label: 'About Us',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsPage()),
              ),
              isDark: isDark,
            ),
            const SizedBox(height: 28),

            // Account Actions
            _sectionLabel('Account Actions', isDark),
            const SizedBox(height: 12),
            _buildSettingsTile(
              icon: Icons.delete_outline,
              label: 'Delete Account',
              color: Colors.redAccent,
              onTap: () => _confirmDelete(context, isDark),
              isDark: isDark,
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => _logout(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Version Info
            Center(
              child: Text(
                'Version 2.0.0',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.primaryCyan,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildThemeTile(bool isDark, ThemeProvider themeProvider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.primaryCyan,
                size: 20,
              ),
              const SizedBox(width: 14),
              Text(
                themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.lightText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Switch(
            value: !themeProvider.isDarkMode,
            onChanged: (_) => themeProvider.toggleTheme(),
            activeColor: AppColors.primaryCyan,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    required bool isDark,
  }) {
    final textColor = color ?? (isDark ? Colors.white : AppColors.lightText);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor.withOpacity(0.8), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(color: textColor, fontSize: 14),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? Colors.white.withOpacity(0.25)
                  : Colors.grey.shade400,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final confirmed = await Helpers.showConfirmationDialog(
      context,
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmText: 'Log Out',
    );

    if (confirmed) {
      final authProvider = context.read<AuthProvider>();
      await authProvider.logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
          (_) => false,
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        title: Text(
          'Delete Account',
          style: TextStyle(color: isDark ? Colors.white : AppColors.lightText),
        ),
        content: Text(
          'This will permanently delete your account. Are you sure?',
          style: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.65)
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.5)
                    : Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final token = await context.read<AuthProvider>().getAccessToken();
              if (token != null) {
                final apiService = ApiService();
                final response = await apiService.deleteAccount(token);
                if (response['success'] == true) {
                  final authProvider = context.read<AuthProvider>();
                  await authProvider.logout();
                  if (context.mounted) {
                    Helpers.showSnackBar(context, 'Account deleted');
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInPage()),
                      (_) => false,
                    );
                  }
                } else {
                  Helpers.showSnackBar(
                    context,
                    response['message'] ?? 'Failed to delete account',
                    isError: true,
                  );
                }
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

// Change Password Page
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _codeSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      Helpers.showSnackBar(context, 'Enter a valid email', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(email);
    setState(() => _isLoading = false);

    if (success) {
      setState(() => _codeSent = true);
      Helpers.showSnackBar(context, 'Reset code sent! Check your email.');
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.error ?? 'Failed to send code',
        isError: true,
      );
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (code.isEmpty || code.length < 6) {
      Helpers.showSnackBar(context, 'Enter the 6-digit code', isError: true);
      return;
    }
    if (password.length < 6) {
      Helpers.showSnackBar(
        context,
        'Password must be at least 6 characters',
        isError: true,
      );
      return;
    }
    if (password != confirm) {
      Helpers.showSnackBar(context, 'Passwords do not match', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(email, code, password);
    setState(() => _isLoading = false);

    if (success) {
      Helpers.showSnackBar(context, 'Password changed! Please log in.');
      await authProvider.logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
          (_) => false,
        );
      }
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.error ?? 'Failed to reset password',
        isError: true,
      );
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
      appBar: AppBar(title: const Text('Change Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _codeSent
                  ? 'Enter the reset code sent to your email and choose a new password.'
                  : 'Enter your email to receive a reset code.',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.6)
                    : AppColors.lightTextSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            CustomTextField(
              controller: _emailController,
              icon: Icons.email_outlined,
              label: 'Email Address',
              enabled: !_codeSent,
              isDark: isDark,
            ),
            if (_codeSent) ...[
              const SizedBox(height: 16),
              CustomTextField(
                controller: _codeController,
                icon: Icons.lock_clock_outlined,
                label: '6-digit Reset Code',
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                icon: Icons.lock_outline,
                label: 'New Password',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.primaryCyan,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmController,
                icon: Icons.lock_outline,
                label: 'Confirm New Password',
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.primaryCyan,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                isDark: isDark,
              ),
            ],
            const SizedBox(height: 32),
            PrimaryButton(
              text: _codeSent ? 'RESET PASSWORD' : 'SEND RESET CODE',
              onPressed: _codeSent ? _resetPassword : _sendCode,
              isLoading: _isLoading,
            ),
            if (_codeSent) ...[
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _codeSent = false),
                  child: Text(
                    '← Change email',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.5)
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
