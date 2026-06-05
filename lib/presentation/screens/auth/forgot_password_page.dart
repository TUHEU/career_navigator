// presentation/screens/auth/forgot_password_page.dart
// 3-step flow: Step 1 → Enter Email, Step 2 → Enter Code + New Password
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import 'sign_in_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {

  // ── Step tracking ─────────────────────────────────────
  int _step = 1; // 1 = email entry, 2 = code + new password

  // ── Step 1 ────────────────────────────────────────────
  final _emailCtrl = TextEditingController();
  bool _sendingCode = false;

  // ── Step 2 ────────────────────────────────────────────
  final List<TextEditingController> _codeCtrl =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _codeFocus = List.generate(6, (_) => FocusNode());
  final _newPassCtrl     = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscureNew     = true;
  bool _obscureConfirm = true;
  bool _resending      = false;
  bool _resetting      = false;

  String get _email => _emailCtrl.text.trim();
  String get _code  => _codeCtrl.map((c) => c.text).join();

  // ── Animation ─────────────────────────────────────────
  late final AnimationController _animCtrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 350));
  late final Animation<double> _fadeAnim =
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);

  @override
  void initState() {
    super.initState();
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    for (final c in _codeCtrl) c.dispose();
    for (final f in _codeFocus) f.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Step 1: Send code ─────────────────────────────────
  Future<void> _sendCode() async {
    final email = _email;
    if (email.isEmpty) {
      Helpers.showSnackBar(context, 'Please enter your email', isError: true);
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      Helpers.showSnackBar(context, 'Please enter a valid email', isError: true);
      return;
    }

    setState(() => _sendingCode = true);
    final ok = await context.read<AuthProvider>().forgotPassword(email);
    if (!mounted) return;
    setState(() => _sendingCode = false);

    if (ok) {
      // Animate to step 2
      await _animCtrl.reverse();
      setState(() => _step = 2);
      _animCtrl.forward();
    } else {
      Helpers.showSnackBar(
        context,
        context.read<AuthProvider>().error ?? 'Failed to send code',
        isError: true,
      );
    }
  }

  // ── Step 2: OTP input ─────────────────────────────────
  void _onDigit(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_codeFocus[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_codeFocus[index - 1]);
    }
  }

  Future<void> _resend() async {
    if (_resending) return;
    setState(() => _resending = true);
    final ok = await context.read<AuthProvider>().forgotPassword(_email);
    if (!mounted) return;
    setState(() => _resending = false);
    if (ok) {
      for (final c in _codeCtrl) c.clear();
      _codeFocus[0].requestFocus();
      Helpers.showSnackBar(context, 'New code sent to $_email');
    } else {
      Helpers.showSnackBar(
        context,
        context.read<AuthProvider>().error ?? 'Failed to resend',
        isError: true,
      );
    }
  }

  Future<void> _resetPassword() async {
    if (_code.length < 6) {
      Helpers.showSnackBar(context, 'Enter the complete 6-digit code',
          isError: true);
      return;
    }
    if (_newPassCtrl.text.length < 8) {
      Helpers.showSnackBar(context, 'Password must be at least 8 characters',
          isError: true);
      return;
    }
    if (_newPassCtrl.text != _confirmPassCtrl.text) {
      Helpers.showSnackBar(context, 'Passwords do not match', isError: true);
      return;
    }

    setState(() => _resetting = true);
    final ok = await context.read<AuthProvider>().resetPassword(
          _email, _code, _newPassCtrl.text);
    if (!mounted) return;
    setState(() => _resetting = false);

    if (ok) {
      // Show success then go to sign in
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SuccessDialog(email: _email),
      );
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
          (_) => false,
        );
      }
    } else {
      Helpers.showSnackBar(
        context,
        context.read<AuthProvider>().error ?? 'Invalid or expired code',
        isError: true,
      );
      for (final c in _codeCtrl) c.clear();
      _codeFocus[0].requestFocus();
    }
  }

  // ── Build ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : AppColors.lightText, size: 20),
          onPressed: () {
            if (_step == 2) {
              _animCtrl.reverse().then((_) {
                setState(() => _step = 1);
                _animCtrl.forward();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _step == 1 ? 'Forgot Password' : 'Reset Password',
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.lightText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: _step == 1
            ? _buildStep1(isDark)
            : _buildStep2(isDark),
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // STEP 1 — Email entry
  // ══════════════════════════════════════════════════════
  Widget _buildStep1(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryCyan.withOpacity(0.1),
              border: Border.all(
                  color: AppColors.primaryCyan.withOpacity(0.3), width: 2),
            ),
            child: const Icon(Icons.email_outlined,
                color: AppColors.primaryCyan, size: 42),
          ),
          const SizedBox(height: 28),

          // Title & subtitle
          Text('Forgot your password?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightText,
              )),
          const SizedBox(height: 10),
          Text(
            "No worries! Enter your account email and we'll\nsend you a 6-digit reset code.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14, height: 1.5,
              color: isDark
                  ? Colors.white.withOpacity(0.55)
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 40),

          // Email field
          _EmailField(controller: _emailCtrl, isDark: isDark,
              onSubmit: _sendCode),
          const SizedBox(height: 28),

          // Send button
          _ActionButton(
            label: 'SEND RESET CODE',
            icon: Icons.send_rounded,
            isLoading: _sendingCode,
            onTap: _sendCode,
          ),
          const SizedBox(height: 24),

          // Back to sign in
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: RichText(
              text: TextSpan(
                text: 'Remember your password? ',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.55)
                      : AppColors.lightTextSecondary,
                  fontSize: 13,
                ),
                children: const [
                  TextSpan(
                    text: 'Sign In',
                    style: TextStyle(
                      color: AppColors.primaryCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════
  // STEP 2 — Code + New Password
  // ══════════════════════════════════════════════════════
  Widget _buildStep2(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // Icon
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryCyan.withOpacity(0.1),
              border: Border.all(
                  color: AppColors.primaryCyan.withOpacity(0.3), width: 2),
            ),
            child: const Icon(Icons.lock_reset_outlined,
                color: AppColors.primaryCyan, size: 42),
          ),
          const SizedBox(height: 20),

          Text('Enter Reset Code',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightText,
              )),
          const SizedBox(height: 8),
          Text('We sent a 6-digit code to',
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? Colors.white.withOpacity(0.55)
                    : AppColors.lightTextSecondary,
              )),
          const SizedBox(height: 4),
          Text(_email,
              style: const TextStyle(
                color: AppColors.primaryCyan,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              )),
          const SizedBox(height: 28),

          // OTP boxes
          _OtpRow(
              controllers: _codeCtrl,
              focusNodes: _codeFocus,
              isDark: isDark,
              onChanged: _onDigit),
          const SizedBox(height: 8),

          // Resend
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text("Didn't receive the code? ",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? Colors.white.withOpacity(0.55)
                      : AppColors.lightTextSecondary,
                )),
            GestureDetector(
              onTap: _resending ? null : _resend,
              child: _resending
                  ? const SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primaryCyan))
                  : const Text('Resend',
                      style: TextStyle(
                        color: AppColors.primaryCyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      )),
            ),
          ]),
          const SizedBox(height: 28),

          // Divider
          Row(children: [
            Expanded(child: Divider(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.grey.shade300)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('New Password',
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: isDark
                        ? Colors.white.withOpacity(0.4)
                        : Colors.grey.shade500,
                  )),
            ),
            Expanded(child: Divider(
                color: isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.grey.shade300)),
          ]),
          const SizedBox(height: 20),

          // New password
          _PasswordField(
            controller: _newPassCtrl,
            label: 'New Password',
            obscure: _obscureNew,
            onToggle: () => setState(() => _obscureNew = !_obscureNew),
            isDark: isDark,
          ),
          const SizedBox(height: 14),

          // Confirm password
          _PasswordField(
            controller: _confirmPassCtrl,
            label: 'Confirm New Password',
            obscure: _obscureConfirm,
            onToggle: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            isDark: isDark,
          ),
          const SizedBox(height: 30),

          // Reset button
          _ActionButton(
            label: 'RESET PASSWORD',
            icon: Icons.lock_open_rounded,
            isLoading: _resetting,
            onTap: _resetPassword,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────

class _EmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSubmit;
  const _EmailField(
      {required this.controller,
      required this.isDark,
      required this.onSubmit});

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => onSubmit(),
        style: TextStyle(
            color: isDark ? Colors.white : AppColors.lightText),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.email_outlined,
              color: AppColors.primaryCyan),
          labelText: 'Email Address',
          labelStyle: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.6)
                : Colors.grey.shade600,
          ),
          filled: true,
          fillColor: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.shade100,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.grey.shade300,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                  color: AppColors.primaryCyan, width: 1.8)),
        ),
      );
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;
  final bool isDark;
  const _PasswordField({
    required this.controller, required this.label,
    required this.obscure, required this.onToggle, required this.isDark,
  });

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        obscureText: obscure,
        style: TextStyle(
            color: isDark ? Colors.white : AppColors.lightText),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.lock_outline_rounded,
              color: AppColors.primaryCyan),
          labelText: label,
          labelStyle: TextStyle(
            color: isDark
                ? Colors.white.withOpacity(0.6)
                : Colors.grey.shade600,
          ),
          filled: true,
          fillColor: isDark
              ? Colors.white.withOpacity(0.05)
              : Colors.grey.shade100,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.15)
                    : Colors.grey.shade300,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                  color: AppColors.primaryCyan, width: 1.8)),
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.primaryCyan,
            ),
            onPressed: onToggle,
          ),
        ),
      );
}

class _OtpRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool isDark;
  final void Function(int, String) onChanged;
  const _OtpRow({
    required this.controllers, required this.focusNodes,
    required this.isDark, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (i) {
          return Container(
            width: 46, height: 54,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: TextFormField(
              controller: controllers[i],
              focusNode: focusNodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold,
                color: AppColors.primaryCyan,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.grey.shade100,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.18)
                          : Colors.grey.shade300,
                    )),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: AppColors.primaryCyan, width: 2.2)),
              ),
              onChanged: (v) => onChanged(i, v),
            ),
          );
        }),
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback onTap;
  const _ActionButton({
    required this.label, required this.icon,
    required this.isLoading, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: isLoading ? null : onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryCyan,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                AppColors.primaryCyan.withOpacity(0.5),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                    Text(label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.8,
                        )),
                  ],
                ),
        ),
      );
}

class _SuccessDialog extends StatelessWidget {
  final String email;
  const _SuccessDialog({required this.email});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green.withOpacity(0.12),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: Colors.green, size: 48),
          ),
          const SizedBox(height: 20),
          const Text('Password Reset!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'Your password has been reset successfully.\nYou can now sign in with your new password.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCyan,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Sign In Now',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }
}
