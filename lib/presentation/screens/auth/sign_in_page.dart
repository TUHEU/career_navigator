// presentation/screens/auth/sign_in_page.dart — v11
// Complete redesign: glassmorphism card, animated fields, social hints,
// biometric hint, guest login, improved error UX
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guest_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/buttons.dart';
import '../dashboard/admin_dashboard.dart';
import '../dashboard/job_seeker_dashboard.dart';
import '../dashboard/mentor_dashboard.dart';
import 'registration_page.dart';
import 'forgot_password_page.dart';

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
  bool _remember   = false;
  String? _errorMsg;

  late AnimationController _animCtrl;
  late Animation<double>   _fadeIn;
  late Animation<Offset>   _slideIn;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _fadeIn  = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: 0.0, end: 1.0));
    _slideIn = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: const Offset(0, 0.06), end: Offset.zero));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _errorMsg = null);

    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);

    if (!mounted) return;

    if (ok && auth.currentUser != null) {
      final role = auth.currentUser!.role;
      Widget dest;
      if (role == 'admin') {
        dest = const AdminDashboard();
      } else if (role == 'mentor') {
        dest = const MentorDashboard();
      } else {
        dest = const JobSeekerDashboard();
      }
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => dest), (_) => false);
    } else {
      setState(() => _errorMsg = auth.error ?? 'Login failed. Check your credentials.');
    }
  }

  void _loginAsGuest() {
    context.read<GuestProvider>().enterGuestMode();
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => const JobSeekerDashboard()),
      (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final auth   = context.watch<AuthProvider>();
    final lang   = context.watch<LanguageProvider>();
    final size   = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF060912), const Color(0xFF0B1630),
                   const Color(0xFF060912)]
                : [const Color(0xFFF0F9FF), const Color(0xFFE8F5FF),
                   const Color(0xFFF0F9FF)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Stack(children: [
          // Background orbs
          Positioned(top: -80, right: -60,
            child: _GlowOrb(260, AppColors.primaryCyan, 0.08, isDark)),
          Positioned(bottom: -100, left: -80,
            child: _GlowOrb(300, const Color(0xFF7C3AED), 0.06, isDark)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideIn,
                  child: Form(
                    key: _formKey,
                    child: Column(children: [
                      SizedBox(height: size.height * 0.07),

                      // ── Logo ──────────────────────────────
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryCyan.withOpacity(0.1),
                          border: Border.all(
                            color: AppColors.primaryCyan.withOpacity(0.3), width: 2),
                          boxShadow: [BoxShadow(
                            color: AppColors.primaryCyan.withOpacity(0.2),
                            blurRadius: 30)]),
                        child: ClipOval(child: Image.asset(
                          'assets/logo/logo.png', fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.compass_calibration_outlined,
                            color: AppColors.primaryCyan, size: 38))),
                      ),
                      const SizedBox(height: 20),

                      ShaderMask(
                        shaderCallback: (b) => const LinearGradient(
                          colors: [AppColors.primaryCyan, Color(0xFF7C3AED)],
                        ).createShader(b),
                        blendMode: BlendMode.srcIn,
                        child: const Text('Career Navigator',
                          style: TextStyle(fontSize: 24,
                            fontWeight: FontWeight.w900, color: Colors.white)),
                      ),
                      const SizedBox(height: 6),
                      Text(lang.t(S.welcomeBack) + '! 👋',
                        style: TextStyle(
                          color: AppColors.textMuted(isDark), fontSize: 14)),
                      const SizedBox(height: 36),

                      // ── Card ──────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.04)
                              : Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.grey.withOpacity(0.15)),
                          boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.3 : 0.07),
                            blurRadius: 30, offset: const Offset(0, 8))]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Text(lang.t(S.signIn),
                            style: TextStyle(
                              color: AppColors.text(isDark),
                              fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Enter your credentials to continue',
                            style: TextStyle(
                              color: AppColors.textMuted(isDark), fontSize: 13)),
                          const SizedBox(height: 24),

                          // Error banner
                          if (_errorMsg != null) ...[
                            _ErrorBanner(message: _errorMsg!, isDark: isDark,
                              onDismiss: () => setState(() => _errorMsg = null)),
                            const SizedBox(height: 16),
                          ],

                          // Email field
                          _Field(
                            ctrl: _emailCtrl, isDark: isDark,
                            label: lang.t(S.emailAddress),
                            hint: 'you@example.com',
                            icon: Icons.email_outlined,
                            type: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Email required';
                              if (!v.contains('@')) return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Password field
                          _Field(
                            ctrl: _passCtrl, isDark: isDark,
                            label: lang.t(S.password),
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            obscure: _obscure,
                            suffix: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.primaryCyan, size: 20),
                              onPressed: () => setState(() => _obscure = !_obscure)),
                            validator: (v) =>
                              v == null || v.isEmpty ? 'Password required' : null,
                          ),
                          const SizedBox(height: 12),

                          // Remember + Forgot
                          Row(children: [
                            GestureDetector(
                              onTap: () => setState(() => _remember = !_remember),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 20, height: 20,
                                  decoration: BoxDecoration(
                                    color: _remember
                                        ? AppColors.primaryCyan
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: _remember
                                          ? AppColors.primaryCyan
                                          : AppColors.border(isDark),
                                      width: 1.5),
                                    borderRadius: BorderRadius.circular(5)),
                                  child: _remember
                                      ? const Icon(Icons.check, color: Colors.black,
                                          size: 13) : null),
                                const SizedBox(width: 8),
                                Text(lang.t(S.rememberMe),
                                  style: TextStyle(
                                    color: AppColors.textMuted(isDark), fontSize: 13)),
                              ]),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.push(context,
                                  MaterialPageRoute(
                                      builder: (_) => const ForgotPasswordPage())),
                              child: Text(lang.t(S.forgotPassword),
                                style: const TextStyle(
                                  color: AppColors.primaryCyan,
                                  fontSize: 13, fontWeight: FontWeight.w600))),
                          ]),
                          const SizedBox(height: 24),

                          // Sign In button
                          auth.isLoading
                              ? const Center(child: SizedBox(
                                  width: 28, height: 28,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.primaryCyan)))
                              : _PrimaryBtn(
                                  label: lang.t(S.signIn),
                                  icon: Icons.login_rounded,
                                  onTap: _login),
                        ]),
                      ),
                      const SizedBox(height: 16),

                      // Divider
                      Row(children: [
                        Expanded(child: Divider(color: AppColors.border(isDark))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text('or', style: TextStyle(
                            color: AppColors.textMuted(isDark), fontSize: 13))),
                        Expanded(child: Divider(color: AppColors.border(isDark))),
                      ]),
                      const SizedBox(height: 16),

                      // Guest login
                      _OutlineBtn(
                        label: 'Continue as Guest',
                        icon: Icons.person_outline_rounded,
                        onTap: _loginAsGuest, isDark: isDark),
                      const SizedBox(height: 28),

                      // Sign up link
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(lang.t(S.dontHaveAccount),
                          style: TextStyle(
                            color: AppColors.textMuted(isDark), fontSize: 14)),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (_) => const RegistrationPage())),
                          child: Text(lang.t(S.createAccount),
                            style: const TextStyle(
                              color: AppColors.primaryCyan,
                              fontWeight: FontWeight.bold, fontSize: 14))),
                      ]),
                      const SizedBox(height: 32),
                    ])),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────
class _GlowOrb extends StatelessWidget {
  final double size; final Color color;
  final double opacity; final bool isDark;
  const _GlowOrb(this.size, this.color, this.opacity, this.isDark);
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(opacity)));
}

class _ErrorBanner extends StatelessWidget {
  final String message; final bool isDark; final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.isDark,
    required this.onDismiss});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.danger.withOpacity(0.09),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.danger.withOpacity(0.3))),
    child: Row(children: [
      const Icon(Icons.error_outline_rounded,
          color: AppColors.danger, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(message, style: const TextStyle(
        color: AppColors.danger, fontSize: 13))),
      GestureDetector(onTap: onDismiss,
        child: const Icon(Icons.close, color: AppColors.danger, size: 16)),
    ]));
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final bool isDark;
  final String label, hint;
  final IconData icon;
  final bool obscure;
  final TextInputType type;
  final Widget? suffix;
  final String? Function(String?)? validator;

  const _Field({
    required this.ctrl, required this.isDark,
    required this.label, required this.hint, required this.icon,
    this.obscure = false, this.type = TextInputType.text,
    this.suffix, this.validator,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl, obscureText: obscure,
    keyboardType: type, validator: validator,
    style: TextStyle(color: AppColors.text(isDark)),
    decoration: InputDecoration(
      labelText: label, hintText: hint,
      hintStyle: TextStyle(color: AppColors.textMuted(isDark), fontSize: 13),
      labelStyle: TextStyle(color: AppColors.textMuted(isDark)),
      prefixIcon: Icon(icon, color: AppColors.primaryCyan, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.04)
          : Colors.grey.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border(isDark))),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryCyan, width: 1.5)),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger))),
  );
}

class _PrimaryBtn extends StatelessWidget {
  final String label; final IconData icon; final VoidCallback onTap;
  const _PrimaryBtn({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryCyan, Color(0xFF0099CC)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
          color: AppColors.primaryCyan.withOpacity(0.35),
          blurRadius: 16, offset: const Offset(0, 6))]),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: Colors.black, size: 20),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(
          color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
      ])));
}

class _OutlineBtn extends StatelessWidget {
  final String label; final IconData icon;
  final VoidCallback onTap; final bool isDark;
  const _OutlineBtn({required this.label, required this.icon,
    required this.onTap, required this.isDark});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, height: 52,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryCyan.withOpacity(0.5), width: 1.5)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: AppColors.primaryCyan, size: 20),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(
          color: AppColors.primaryCyan,
          fontWeight: FontWeight.w600, fontSize: 15)),
      ])));
}
