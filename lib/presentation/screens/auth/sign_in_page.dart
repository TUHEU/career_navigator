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

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
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
                  onTap: () => _showForgotPasswordDialog(isDark),
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

  // COMPLETE FORGOT PASSWORD FLOW
  void _showForgotPasswordDialog(bool isDark) {
    final emailController = TextEditingController();
    final codeController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool codeSent = false;
    bool isLoading = false;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
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
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.lock_reset,
                      color: AppColors.primaryCyan,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Reset Password',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.lightText,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  codeSent
                      ? 'Enter the 6-digit reset code sent to your email, then create a new password.'
                      : 'Enter your email address and we\'ll send you a 6-digit reset code.',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.55)
                        : AppColors.lightTextSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Email Field (always visible)
                CustomTextField(
                  controller: emailController,
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                  enabled: !codeSent,
                  isDark: isDark,
                ),

                // Reset Code Field (visible after code sent)
                if (codeSent) ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: codeController,
                    icon: Icons.lock_clock_outlined,
                    label: '6-digit Reset Code',
                    keyboardType: TextInputType.number,
                    isDark: isDark,
                  ),
                ],

                // New Password Fields (visible after code sent)
                if (codeSent) ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: newPasswordController,
                    icon: Icons.lock_outline,
                    label: 'New Password',
                    obscureText: obscureNewPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNewPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.primaryCyan,
                      ),
                      onPressed: () => setSheetState(
                        () => obscureNewPassword = !obscureNewPassword,
                      ),
                    ),
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: confirmPasswordController,
                    icon: Icons.lock_outline,
                    label: 'Confirm New Password',
                    obscureText: obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.primaryCyan,
                      ),
                      onPressed: () => setSheetState(
                        () => obscureConfirmPassword = !obscureConfirmPassword,
                      ),
                    ),
                    isDark: isDark,
                  ),
                ],

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (!codeSent) {
                              // STEP 1: Send reset code
                              final email = emailController.text.trim();
                              if (email.isEmpty || !email.contains('@')) {
                                Helpers.showSnackBar(
                                  ctx,
                                  'Enter a valid email',
                                  isError: true,
                                );
                                return;
                              }

                              setSheetState(() => isLoading = true);
                              final authProvider = context.read<AuthProvider>();
                              final success = await authProvider.forgotPassword(
                                email,
                              );
                              setSheetState(() => isLoading = false);

                              if (success) {
                                setSheetState(() => codeSent = true);
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
                            } else {
                              // STEP 2: Reset password with code
                              final email = emailController.text.trim();
                              final code = codeController.text.trim();
                              final newPassword = newPasswordController.text;
                              final confirmPassword =
                                  confirmPasswordController.text;

                              // Validations
                              if (code.isEmpty || code.length < 6) {
                                Helpers.showSnackBar(
                                  ctx,
                                  'Enter the 6-digit code',
                                  isError: true,
                                );
                                return;
                              }
                              if (newPassword.isEmpty) {
                                Helpers.showSnackBar(
                                  ctx,
                                  'Please enter a new password',
                                  isError: true,
                                );
                                return;
                              }
                              if (newPassword.length < 6) {
                                Helpers.showSnackBar(
                                  ctx,
                                  'Password must be at least 6 characters',
                                  isError: true,
                                );
                                return;
                              }
                              if (newPassword != confirmPassword) {
                                Helpers.showSnackBar(
                                  ctx,
                                  'Passwords do not match',
                                  isError: true,
                                );
                                return;
                              }

                              setSheetState(() => isLoading = true);
                              final authProvider = context.read<AuthProvider>();
                              final success = await authProvider.resetPassword(
                                email,
                                code,
                                newPassword,
                              );
                              setSheetState(() => isLoading = false);

                              if (success) {
                                // Close bottom sheet
                                Navigator.pop(ctx);

                                // Show success dialog
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (dialogCtx) => AlertDialog(
                                    backgroundColor: isDark
                                        ? AppColors.darkSurface
                                        : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Row(
                                      children: const [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 28,
                                        ),
                                        SizedBox(width: 12),
                                        Text('Success!'),
                                      ],
                                    ),
                                    content: const Text(
                                      'Your password has been changed successfully. Please log in with your new password.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogCtx);
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                Helpers.showSnackBar(
                                  ctx,
                                  authProvider.error ??
                                      'Failed to reset password',
                                  isError: true,
                                );
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            codeSent ? 'RESET PASSWORD' : 'SEND RESET CODE',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),

                // Back to email button (when code sent)
                if (codeSent) ...[
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setSheetState(() {
                          codeSent = false;
                          codeController.clear();
                          newPasswordController.clear();
                          confirmPasswordController.clear();
                        });
                      },
                      child: Text(
                        '← Use a different email',
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
          );
        },
      ),
    );
  }
}
