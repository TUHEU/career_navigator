// presentation/screens/auth/email_verification_page.dart
// v8: Fixed OTP boxes + language-aware + auto-verify
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import 'profile_setup_page.dart';
import 'sign_in_page.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  const EmailVerificationPage({super.key, required this.email});
  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final _ctrls = List.generate(6, (_) => TextEditingController());
  final _nodes = List.generate(6, (_) => FocusNode());

  bool _verifying = false;
  bool _resending  = false;
  bool _autoTriggered = false;

  @override
  void dispose() {
    for (final c in _ctrls) c.dispose();
    for (final n in _nodes) n.dispose();
    super.dispose();
  }

  String get _code => _ctrls.map((c) => c.text).join();

  void _onChanged(int i, String v) {
    if (v.isNotEmpty && i < 5) _nodes[i + 1].requestFocus();
    if (v.isEmpty   && i > 0) _nodes[i - 1].requestFocus();
    if (_code.length == 6 && !_autoTriggered && !_verifying) {
      _autoTriggered = true;
      _verify();
    } else if (_code.length != 6) {
      _autoTriggered = false;
    }
  }

  Future<void> _verify() async {
    if (_verifying) return;
    if (_code.length < 6) {
      Helpers.showSnackBar(context,
          'Please enter the complete 6-digit code.', isError: true);
      return;
    }
    setState(() => _verifying = true);
    final auth    = context.read<AuthProvider>();
    final success = await auth.verifyEmail(widget.email, _code);
    if (!mounted) return;
    setState(() => _verifying = false);
    if (success) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const ProfileSetupPage()));
    } else {
      Helpers.showSnackBar(context, auth.error ?? 'Invalid code', isError: true);
      for (final c in _ctrls) c.clear();
      _nodes[0].requestFocus();
      _autoTriggered = false;
    }
  }

  Future<void> _resend() async {
    if (_resending) return;
    setState(() => _resending = true);
    final auth    = context.read<AuthProvider>();
    final success = await auth.resendCode(widget.email);
    if (!mounted) return;
    setState(() => _resending = false);
    if (success) {
      Helpers.showSnackBar(context, 'New code sent!');
      for (final c in _ctrls) c.clear();
      _nodes[0].requestFocus();
      _autoTriggered = false;
    } else {
      Helpers.showSnackBar(context, auth.error ?? 'Failed', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final lang   = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(child: Center(child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          // Logo
          Container(
            width: 82, height: 82,
            decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
              BoxShadow(color: AppColors.primaryCyan.withOpacity(0.35),
                  blurRadius: 24)]),
            child: ClipOval(child: Image.asset('assets/logo/logo.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.primaryCyan.withOpacity(0.2),
                child: const Icon(Icons.compass_calibration_outlined,
                    color: AppColors.primaryCyan, size: 38)))),
          ),
          const SizedBox(height: 24),

          // Email icon
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppColors.primaryCyan.withOpacity(0.1),
              border: Border.all(
                  color: AppColors.primaryCyan.withOpacity(0.3), width: 1.5)),
            child: const Icon(Icons.mark_email_read_outlined,
                color: AppColors.primaryCyan, size: 48),
          ),
          const SizedBox(height: 24),

          Text(lang.t(S.verifyEmail), style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.lightText)),
          const SizedBox(height: 10),
          Text(lang.t(S.verifyEmailSub), textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary(isDark), fontSize: 14)),
          const SizedBox(height: 4),
          Text(widget.email, textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.primaryCyan,
                fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 32),

          // ── OTP BOXES (FIXED) ───────────────────────────
          LayoutBuilder(builder: (_, constraints) {
            const n = 6;
            final box = ((constraints.maxWidth - 32 - 8.0 * n) / n).clamp(40.0, 54.0);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(n, (i) => Container(
                width: box, height: box + 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  // FIX: solid visible background in both modes
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFEEF2F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.border(isDark), width: 1.5)),
                child: TextFormField(
                  controller: _ctrls[i],
                  focusNode: _nodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: TextStyle(
                    fontSize: box * 0.44,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryCyan),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                          color: AppColors.primaryCyan, width: 2)),
                  ),
                  onChanged: (v) => _onChanged(i, v),
                ),
              )),
            );
          }),
          const SizedBox(height: 32),

          // Verify button
          _VerifyButton(
            label: lang.t(S.verifyBtn),
            onTap: _verify,
            isLoading: _verifying,
          ),
          const SizedBox(height: 20),

          // Resend row
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(lang.t(S.didntReceive) + ' ',
                style: TextStyle(color: AppColors.textSecondary(isDark))),
            _resending
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primaryCyan))
                : GestureDetector(
                    onTap: _resend,
                    child: Text(lang.t(S.resend), style: const TextStyle(
                      color: AppColors.primaryCyan, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 16),

          TextButton(
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const SignInPage())),
            child: Text(lang.t(S.backToSignIn),
                style: TextStyle(color: AppColors.textMuted(isDark)))),
        ]),
      ))),
    );
  }
}

class _VerifyButton extends StatefulWidget {
  final String label; final VoidCallback onTap; final bool isLoading;
  const _VerifyButton({required this.label, required this.onTap,
      required this.isLoading});
  @override State<_VerifyButton> createState() => _VerifyButtonState();
}
class _VerifyButtonState extends State<_VerifyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _s = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) { if (!widget.isLoading) _c.forward(); },
    onTapUp:   (_) { _c.reverse(); if (!widget.isLoading) widget.onTap(); },
    onTapCancel: () => _c.reverse(),
    child: ScaleTransition(scale: _s,
      child: Container(
        width: double.infinity, height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryCyan, Color(0xFF0097A7)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: AppColors.primaryCyan.withOpacity(0.4),
            blurRadius: 20, offset: const Offset(0, 6))]),
        child: Center(child: widget.isLoading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.black))
            : Text(widget.label, style: const TextStyle(
                color: Colors.black, fontSize: 14,
                fontWeight: FontWeight.w800, letterSpacing: 1))),
      ),
    ),
  );
}
