import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_service.dart';
import '../../services/token_store.dart';
import '../../core/themes/app_theme.dart';
import 'sign_in_page.dart';
import 'edit_profile_page.dart';
import 'about_us_page.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // ── App Theme ────────────────────────────────
                _label('App Theme'),
                const SizedBox(height: 12),
                _ThemePicker(theme: theme),
                const SizedBox(height: 28),

                // ── Account ──────────────────────────────────
                _label('Account'),
                const SizedBox(height: 12),
                _Tile(
                  icon: Icons.person_outline,
                  label: 'Edit Profile',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  ),
                ),
                _Tile(
                  icon: Icons.lock_outline,
                  label: 'Change Password',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  ),
                ),
                _Tile(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () => _snack(context, 'Coming soon'),
                ),
                _Tile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy & Security',
                  onTap: () => _snack(context, 'Coming soon'),
                ),
                const SizedBox(height: 28),

                // ── Support ───────────────────────────────────
                _label('Support'),
                const SizedBox(height: 12),
                _Tile(
                  icon: Icons.help_outline,
                  label: 'Help & FAQ',
                  onTap: () => _snack(context, 'Coming soon'),
                ),
                _Tile(
                  icon: Icons.feedback_outlined,
                  label: 'Send Feedback',
                  onTap: () => _snack(context, 'Coming soon'),
                ),
                _Tile(
                  icon: Icons.info_outline,
                  label: 'About Us',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutUsPage()),
                  ),
                ),
                const SizedBox(height: 28),

                // ── Danger zone ───────────────────────────────
                _label('Account Actions'),
                const SizedBox(height: 12),
                _Tile(
                  icon: Icons.delete_outline,
                  label: 'Delete Account',
                  color: Colors.redAccent,
                  onTap: () => _confirmDelete(context),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => _logout(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.35),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.redAccent, size: 20),
                        SizedBox(width: 10),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String t) => Text(
    t,
    style: const TextStyle(
      color: AppColors.primaryCyan,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  );

  Future<void> _logout(BuildContext context) async {
    await TokenStore.clear();
    if (context.mounted)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (_) => false,
      );
  }

  void _snack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'This will permanently delete your account. Are you sure?',
          style: TextStyle(color: Colors.white.withOpacity(0.65)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _snack(context, 'Coming soon');
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

// ─────────────────────────────────────────────────────────
// Theme Picker
// ─────────────────────────────────────────────────────────
class _ThemePicker extends StatelessWidget {
  final AppThemeProvider theme;
  const _ThemePicker({required this.theme});

  @override
  Widget build(BuildContext context) => Row(
    children: AppBackground.values.map((bg) {
      final sel = theme.background == bg;
      return Expanded(
        child: GestureDetector(
          onTap: () => theme.setBackground(bg),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: sel
                    ? AppColors.primaryCyan
                    : Colors.white.withOpacity(0.12),
                width: sel ? 2.5 : 1,
              ),
              image: DecorationImage(
                image: AssetImage(bg.assetPath),
                fit: BoxFit.cover,
                opacity: 0.80,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(13),
                color: sel
                    ? AppColors.primaryCyan.withOpacity(0.18)
                    : Colors.black.withOpacity(0.38),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (sel)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.primaryCyan,
                      size: 18,
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      bg.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: sel ? AppColors.primaryCyan : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

// ─────────────────────────────────────────────────────────
// Settings Tile
// ─────────────────────────────────────────────────────────
class _Tile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _Tile({
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Icon(icon, color: c.withOpacity(0.8), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(color: c, fontSize: 14)),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withOpacity(0.25),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Change Password Page
// ─────────────────────────────────────────────────────────
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _codeSent = false;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _snack('Enter a valid email');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await ApiService.forgotPassword(email);
      if (mounted) {
        setState(() {
          _codeSent = true;
          _loading = false;
        });
        _snack(res['message'] ?? 'Code sent!');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        _snack('Network error');
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailCtrl.text.trim();
    final code = _codeCtrl.text.trim();
    final pass = _passCtrl.text;
    if (code.isEmpty || pass.length < 6) {
      _snack('Enter code and a password of at least 6 chars');
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await ApiService.resetPassword(
        email: email,
        code: code,
        password: pass,
      );
      if (!mounted) return;
      if (res['success'] == true) {
        _snack('Password changed! Please log in.');
        await TokenStore.clear();
        if (mounted)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SignInPage()),
            (_) => false,
          );
      } else {
        _snack(res['message'] ?? 'Failed');
      }
    } catch (_) {
      if (mounted) _snack('Network error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.white),
        ),
      ),
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
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            TextFormField(
              controller: _emailCtrl,
              enabled: !_codeSent,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: buildInputDecoration(
                icon: Icons.email_outlined,
                label: 'Email Address',
              ),
            ),
            if (_codeSent) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: buildInputDecoration(
                  icon: Icons.lock_clock_outlined,
                  label: '6-digit Reset Code',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white),
                decoration: buildInputDecoration(
                  icon: Icons.lock_outline,
                  label: 'New Password',
                  suffix: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.primaryCyan,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading
                  ? null
                  : (_codeSent ? _resetPassword : _sendCode),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCyan,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : Text(
                      _codeSent ? 'RESET PASSWORD' : 'SEND RESET CODE',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
            if (_codeSent) ...[
              const SizedBox(height: 14),
              Center(
                child: TextButton(
                  onPressed: () => setState(() => _codeSent = false),
                  child: Text(
                    '← Change email',
                    style: TextStyle(color: Colors.white.withOpacity(0.5)),
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
