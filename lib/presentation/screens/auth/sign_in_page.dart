// presentation/screens/auth/sign_in_page.dart
// v8: Language-aware + Guest mode login + improved buttons
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guest_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/inputs.dart';
import 'registration_page.dart';
import 'reset_password_page.dart';
import '../dashboard/job_seeker_dashboard.dart';
import '../dashboard/mentor_dashboard.dart';
import '../dashboard/admin_dashboard.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage>
    with SingleTickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 800));
    _fadeAnim  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _passCtrl.dispose(); _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final auth    = context.read<AuthProvider>();
    final success = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (success) {
      final role = auth.currentUser?.role;
      if (role == 'admin')  { _go(const AdminDashboard());     return; }
      if (role == 'mentor') { _go(const MentorDashboard());    return; }
      _go(const JobSeekerDashboard());
    } else {
      Helpers.showSnackBar(context, auth.error ?? 'Login failed', isError: true);
    }
  }

  void _continueAsGuest() {
    context.read<GuestProvider>().enterGuestMode();
    _go(const JobSeekerDashboard());
  }

  void _go(Widget page) => Navigator.pushReplacement(
      context, MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    final isDark   = context.watch<ThemeProvider>().isDarkMode;
    final auth     = context.watch<AuthProvider>();
    final lang     = context.watch<LanguageProvider>();
    final bgPath   = context.watch<ThemeProvider>().backgroundPath;

    return Scaffold(
      body: Stack(children: [

        // Background
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            image: DecorationImage(
              image: AssetImage(bgPath), fit: BoxFit.cover, opacity: 0.3),
          ),
        ),
        Container(
          color: isDark
              ? Colors.black.withValues(alpha: 0.55)
              : Colors.white.withValues(alpha: 0.90),
        ),

        SafeArea(child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Center(child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(children: [
                _Header(isDark: isDark, lang: lang),
                const SizedBox(height: 28),
                _Card(
                  isDark: isDark, lang: lang,
                  formKey: _formKey,
                  emailCtrl: _emailCtrl, passCtrl: _passCtrl,
                  obscure: _obscure,
                  onToggleObscure: () => setState(() => _obscure = !_obscure),
                  onSignIn: _signIn,
                  isLoading: auth.isLoading,
                ),
                const SizedBox(height: 20),

                // ── Guest mode button ──────────────────────
                _GuestButton(lang: lang, onTap: _continueAsGuest),
                const SizedBox(height: 20),

                // Sign up row
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${lang.t(S.dontHaveAccount)} ',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.60)
                          : AppColors.lightTextSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegistrationPage())),
                    child: Text(lang.t(S.signUp), style: const TextStyle(
                        color: AppColors.primaryCyan,
                        fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ]),
              ]),
            )),
          ),
        )),
      ]),
    );
  }
}

// ── Subwidgets ─────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isDark; final LanguageProvider lang;
  const _Header({required this.isDark, required this.lang});
  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      width: 88, height: 88,
      decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
        BoxShadow(color: AppColors.primaryCyan.withValues(alpha: 0.4),
            blurRadius: 28, spreadRadius: 4)]),
      child: ClipOval(child: Image.asset('assets/logo/logo.png',
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          color: AppColors.primaryCyan.withValues(alpha: 0.2),
          child: const Icon(Icons.compass_calibration_outlined,
              color: AppColors.primaryCyan, size: 42)))),
    ),
    const SizedBox(height: 16),
    Text(lang.t(S.welcomeBack), style: TextStyle(
      fontSize: 28, fontWeight: FontWeight.bold,
      color: isDark ? Colors.white : AppColors.lightText, letterSpacing: 0.5)),
    const SizedBox(height: 6),
    Text('Sign in to continue your journey', style: TextStyle(
      color: isDark ? Colors.white.withValues(alpha: 0.55) : AppColors.lightTextSecondary,
      fontSize: 14)),
  ]);
}

class _Card extends StatelessWidget {
  final bool isDark; final LanguageProvider lang;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl, passCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure, onSignIn;
  final bool isLoading;

  const _Card({
    required this.isDark, required this.lang, required this.formKey,
    required this.emailCtrl, required this.passCtrl,
    required this.obscure, required this.onToggleObscure,
    required this.onSignIn, required this.isLoading,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: isDark
              ? Colors.white.withValues(alpha: 0.13) : Colors.grey.shade200)),
        child: Form(key: formKey, child: Column(children: [
          CustomTextField(
            controller: emailCtrl, icon: Icons.email_outlined,
            label: lang.t(S.email),
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail, isDark: isDark),
          const SizedBox(height: 16),
          CustomTextField(
            controller: passCtrl, icon: Icons.lock_outline,
            label: lang.t(S.password),
            obscureText: obscure,
            validator: Validators.validatePassword,
            isDark: isDark,
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined, color: AppColors.primaryCyan),
              onPressed: onToggleObscure)),
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(
                    builder: (_) => const ResetPasswordPage(email: ''))),
              child: Text(lang.t(S.forgotPassword), style: const TextStyle(
                color: AppColors.primaryCyan, fontSize: 13,
                fontWeight: FontWeight.w600)))),
          const SizedBox(height: 22),
          // ── Improved CTA button ──
          _SignInButton(label: lang.t(S.signIn).toUpperCase(),
              onPressed: onSignIn, isLoading: isLoading),
        ])),
      ),
    ),
  );
}

class _SignInButton extends StatefulWidget {
  final String label; final VoidCallback onPressed; final bool isLoading;
  const _SignInButton({required this.label, required this.onPressed,
      required this.isLoading});
  @override State<_SignInButton> createState() => _SignInButtonState();
}
class _SignInButtonState extends State<_SignInButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 120));
    _s = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) { if (!widget.isLoading) _c.forward(); },
    onTapUp:   (_) { _c.reverse(); if (!widget.isLoading) widget.onPressed(); },
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
            color: AppColors.primaryCyan.withValues(alpha: 0.4),
            blurRadius: 20, offset: const Offset(0, 6))]),
        child: Center(child: widget.isLoading
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.black))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.login_rounded, color: Colors.black, size: 18),
                const SizedBox(width: 8),
                Text(widget.label, style: const TextStyle(
                  color: Colors.black, fontSize: 15, fontWeight: FontWeight.w800,
                  letterSpacing: 1)),
              ])),
      ),
    ),
  );
}

class _GuestButton extends StatefulWidget {
  final LanguageProvider lang; final VoidCallback onTap;
  const _GuestButton({required this.lang, required this.onTap});
  @override State<_GuestButton> createState() => _GuestButtonState();
}
class _GuestButtonState extends State<_GuestButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  final bool _hover = false;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 120));
    _s = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Column(children: [
      Row(children: [
        Expanded(child: Divider(color: AppColors.border(isDark))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(
            color: AppColors.textMuted(isDark), fontSize: 13))),
        Expanded(child: Divider(color: AppColors.border(isDark))),
      ]),
      const SizedBox(height: 16),
      GestureDetector(
        onTapDown: (_) => _c.forward(),
        onTapUp:   (_) { _c.reverse(); widget.onTap(); },
        onTapCancel: () => _c.reverse(),
        child: ScaleTransition(scale: _s,
          child: Container(
            width: double.infinity, height: 52,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.15)
                    : Colors.grey.shade300),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.person_outline_rounded,
                color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                size: 20),
              const SizedBox(width: 8),
              Text(widget.lang.t(S.continueAsGuest), style: TextStyle(
                color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600, fontSize: 14)),
            ]),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(widget.lang.t(S.guestWarning), style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 11),
        textAlign: TextAlign.center),
    ]);
  }
}
