import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/buttons.dart';
import '../../widgets/shared/inputs.dart';
import 'registration_page.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  late AnimationController _slideCtrl;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(-0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));
    _slideCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      final user = authProvider.currentUser;
      if (user?.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else if (user?.role == 'mentor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MentorDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const JobSeekerDashboard()),
        );
      }
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.error ?? 'Login failed',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackground
                  : AppColors.lightBackground,
              image: DecorationImage(
                image: AssetImage(
                  isDark
                      ? 'assets/background/bg8.png'
                      : 'assets/background/bg6.png',
                ),
                fit: BoxFit.cover,
                opacity: 0.35,
              ),
            ),
          ),
          Container(
            color: isDark
                ? Colors.black.withOpacity(0.50)
                : Colors.white.withOpacity(0.92),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: SlideTransition(
                  position: _slideAnim,
                  child: Column(
                    children: [
                      _buildHeader(isDark),
                      const SizedBox(height: 28),
                      _buildGlassCard(isDark, authProvider.isLoading),
                      const SizedBox(height: 28),
                      _buildSignUpRow(isDark),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) => Column(
    children: [
      Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryCyan.withOpacity(0.4),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/logo/logo.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.primaryCyan.withOpacity(0.2),
              child: const Icon(
                Icons.school,
                color: AppColors.primaryCyan,
                size: 40,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'Welcome Back',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.lightText,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Sign in to continue your journey',
        style: TextStyle(
          color: isDark
              ? Colors.white.withOpacity(0.55)
              : AppColors.lightTextSecondary,
          fontSize: 14,
        ),
      ),
    ],
  );

  Widget _buildGlassCard(bool isDark, bool isLoading) => ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.13)
                : Colors.grey.shade200,
          ),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _emailCtrl,
                icon: Icons.email_outlined,
                label: 'Email Address',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passCtrl,
                icon: Icons.lock_outline,
                label: 'Password',
                obscureText: _obscure,
                validator: Validators.validatePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.primaryCyan,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                isDark: isDark,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => _showForgotSheet(isDark),
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(
                      color: AppColors.primaryCyan,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                text: 'SIGN IN',
                onPressed: _signIn,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildSignUpRow(bool isDark) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Don't have an account? ",
        style: TextStyle(
          color: isDark
              ? Colors.white.withOpacity(0.60)
              : AppColors.lightTextSecondary,
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegistrationPage()),
        ),
        child: const Text(
          'Sign Up',
          style: TextStyle(
            color: AppColors.primaryCyan,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    ],
  );

  void _showForgotSheet(bool isDark) {
    final emailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          bool sending = false;
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 28,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reset Password',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Enter your email and we'll send a reset code.",
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.55)
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: emailCtrl,
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                PrimaryButton(
                  text: 'SEND RESET CODE',
                  onPressed: sending
                      ? null
                      : () async {
                          setSheetState(() => sending = true);
                          final authProvider = context.read<AuthProvider>();
                          final success = await authProvider.forgotPassword(
                            emailCtrl.text.trim(),
                          );
                          setSheetState(() => sending = false);
                          Navigator.pop(ctx);
                          if (success) {
                            Helpers.showSnackBar(
                              ctx,
                              'Reset code sent! Check your email.',
                            );
                          } else {
                            Helpers.showSnackBar(
                              ctx,
                              authProvider.error ?? 'Failed to send code',
                              isError: true,
                            );
                          }
                        },
                  isLoading: sending,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
