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

  bool _isVerifying = false;
  bool _isResending = false;
  bool _autoVerifyTriggered = false;

  // ── lifecycle ───────────────────────────────────────────
  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  // ── helpers ─────────────────────────────────────────────
  String get _fullCode => _controllers.map((c) => c.text).join();

  // ── actions ─────────────────────────────────────────────
  Future<void> _verify() async {
    if (_isVerifying) return;

    final code = _fullCode;
    if (code.length < 6) {
      Helpers.showSnackBar(
        context,
        'Please enter the complete 6-digit code.',
        isError: true,
      );
      return;
    }

    setState(() => _isVerifying = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyEmail(widget.email, code);

    if (!mounted) return;
    setState(() => _isVerifying = false);

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
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      _autoVerifyTriggered = false;
    }
  }

  Future<void> _resend() async {
    if (_isResending) return;

    setState(() => _isResending = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resendCode(widget.email);

    if (!mounted) return;
    setState(() => _isResending = false);

    if (success) {
      Helpers.showSnackBar(context, 'New verification code sent!');
      for (var controller in _controllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
      _autoVerifyTriggered = false;
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.error ?? 'Failed to resend code',
        isError: true,
      );
    }
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    if (_fullCode.length == 6 && !_autoVerifyTriggered && !_isVerifying) {
      _autoVerifyTriggered = true;
      _verify();
    } else if (_fullCode.length != 6) {
      _autoVerifyTriggered = false;
    }
  }

  // ── build ────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = themeProvider.isDarkMode;
    final isLoading = _isVerifying || authProvider.isLoading;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _buildLogo(),
                const SizedBox(height: 24),
                _buildEmailIcon(),
                const SizedBox(height: 24),
                _buildTitle(),
                const SizedBox(height: 12),
                _buildSubtitle(isDark),
                const SizedBox(height: 6),
                _buildEmailLabel(),
                const SizedBox(height: 32),
                _buildCodeInput(),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: 'VERIFY EMAIL',
                  onPressed: isLoading ? null : _verify,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 20),
                _buildResendRow(isDark),
                const SizedBox(height: 16),
                _buildBackButton(isDark),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── sub-widgets ──────────────────────────────────────────

  Widget _buildLogo() {
    return Container(
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
              Icons.school_outlined,
              color: AppColors.primaryCyan,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailIcon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryCyan.withOpacity(0.12),
        border: Border.all(
          color: AppColors.primaryCyan.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.mark_email_read_outlined,
        color: AppColors.primaryCyan,
        size: 48,
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Verify Your Email',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle(bool isDark) {
    return Text(
      'We sent a 6-digit verification code to',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: isDark
            ? Colors.white.withOpacity(0.65)
            : AppColors.lightTextSecondary,
        fontSize: 14,
      ),
    );
  }

  Widget _buildEmailLabel() {
    return Text(
      widget.email,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: AppColors.primaryCyan,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  /// Responsive OTP input — boxes scale to screen width
  Widget _buildCodeInput() {
    final screenWidth = MediaQuery.of(context).size.width;
    // Total horizontal padding = 24 * 2 = 48
    // Total gap between boxes = 8px * 2 sides * 6 boxes = 96
    // But we use margin: symmetric(horizontal: 4) so 8px per box total
    // Available width for boxes = screenWidth - 48 - (8 * 6) = screenWidth - 96
    final boxSize = ((screenWidth - 96) / 6).clamp(40.0, 54.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(6, (i) {
          return Container(
            width: boxSize,
            height: boxSize + 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: TextFormField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: TextStyle(
                fontSize: boxSize * 0.44,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryCyan,
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white.withOpacity(0.07),
                contentPadding: EdgeInsets.zero,
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
              onChanged: (value) => _onCodeChanged(i, value),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildResendRow(bool isDark) {
    return Row(
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
          onTap: _isResending ? null : _resend,
          child: _isResending
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primaryCyan,
                  ),
                )
              : const Text(
                  'Resend',
                  style: TextStyle(
                    color: AppColors.primaryCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildBackButton(bool isDark) {
    return TextButton(
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
    );
  }
}
