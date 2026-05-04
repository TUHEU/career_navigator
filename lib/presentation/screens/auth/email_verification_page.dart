import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/buttons.dart';
import 'profile_setup_page.dart';
import 'sign_in_page.dart';

class EmailVerificationPage extends StatefulWidget {
  final String email;
  const EmailVerificationPage({super.key, required this.email});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  String get _fullCode => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_fullCode.length < 6) {
      Helpers.showSnackBar(
        context,
        'Please enter the complete 6-digit code.',
        isError: true,
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyEmail(widget.email, _fullCode);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
      );
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.error ?? 'Invalid code',
        isError: true,
      );
    }
  }

  Future<void> _resend() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resendCode(widget.email);

    if (!mounted) return;

    if (success) {
      Helpers.showSnackBar(context, 'New verification code sent!');
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.error ?? 'Failed to resend code',
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
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              _buildHeader(isDark),
              const SizedBox(height: 32),
              _buildCodeInput(),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'VERIFY EMAIL',
                onPressed: authProvider.isLoading ? null : _verify,
                isLoading: authProvider.isLoading,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Didn't receive the code? ",
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.6)
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: _resend,
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        color: AppColors.primaryCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInPage()),
                ),
                child: Text(
                  '← Back to Sign In',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
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
                Icons.mark_email_read,
                color: AppColors.primaryCyan,
                size: 40,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Verify Your Email',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppColors.lightText,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'We sent a 6-digit verification code to',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: isDark
              ? Colors.white.withOpacity(0.65)
              : AppColors.lightTextSecondary,
          fontSize: 14,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        widget.email,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.primaryCyan,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _buildCodeInput() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(6, (i) {
      return Container(
        width: 50,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: TextFormField(
          controller: _controllers[i],
          focusNode: _focusNodes[i],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryCyan,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.white.withOpacity(0.07),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryCyan,
                width: 2,
              ),
            ),
          ),
          onChanged: (val) {
            if (val.isNotEmpty && i < 5)
              FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
            else if (val.isEmpty && i > 0)
              FocusScope.of(context).requestFocus(_focusNodes[i - 1]);
            if (_fullCode.length == 6) _verify();
          },
        ),
      );
    }),
  );
}
