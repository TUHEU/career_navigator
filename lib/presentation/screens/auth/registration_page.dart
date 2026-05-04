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
import 'email_verification_page.dart';
import 'sign_in_page.dart'; // FIXED: Added missing import

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmPassCtrl.text) {
      Helpers.showSnackBar(context, 'Passwords do not match', isError: true);
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.register(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EmailVerificationPage(email: _emailCtrl.text.trim()),
        ),
      );
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.error ?? 'Registration failed',
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
                image: AssetImage(themeProvider.backgroundPath),
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
                    const SizedBox(height: 36),
                    _buildGlassCard(isDark, authProvider.isLoading),
                    const SizedBox(height: 20),
                    _buildSignInRow(isDark),
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
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryCyan.withOpacity(0.35),
              blurRadius: 20,
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
        'Create Account',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.lightText,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Join Career Navigator today',
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
              const SizedBox(height: 15),
              _buildPasswordField(
                controller: _passCtrl,
                label: 'Password',
                obscure: _obscurePassword,
                onToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                isDark: isDark,
              ),
              const SizedBox(height: 15),
              _buildPasswordField(
                controller: _confirmPassCtrl,
                label: 'Confirm Password',
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                isDark: isDark,
              ),
              const SizedBox(height: 25),
              PrimaryButton(
                text: 'CREATE ACCOUNT',
                onPressed: _register,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: isDark ? Colors.white : Colors.grey.shade800),
      validator: Validators.validatePassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.lock_outline,
          color: AppColors.primaryCyan,
        ),
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.white.withOpacity(0.6) : Colors.grey.shade600,
        ),
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : Colors.grey.shade300,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: AppColors.primaryCyan),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.primaryCyan,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }

  Widget _buildSignInRow(bool isDark) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Already have an account? ',
        style: TextStyle(
          color: isDark
              ? Colors.white.withOpacity(0.65)
              : AppColors.lightTextSecondary,
        ),
      ),
      GestureDetector(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
        ),
        child: const Text(
          'Sign In',
          style: TextStyle(
            color: AppColors.primaryCyan,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    ],
  );
}
