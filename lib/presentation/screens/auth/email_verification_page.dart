// presentation/screens/auth/email_verification_page.dart
// FIX: OTP boxes visible in both dark AND light mode
// FIX: Language support (EN/FR)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../l10n/language_provider.dart';
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

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _fullCode => _controllers.map((c) => c.text).join();

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
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyEmail(widget.email, code);
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
        auth.error ?? 'Invalid code',
        isError: true,
      );
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      _autoVerifyTriggered = false;
    }
  }

  Future<void> _resend() async {
    if (_isResending) return;
    setState(() => _isResending = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.resendCode(widget.email);
    if (!mounted) return;
    setState(() => _isResending = false);
    if (success) {
      Helpers.showSnackBar(context, 'New verification code sent!');
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
      _autoVerifyTriggered = false;
    } else {
      Helpers.showSnackBar(
        context,
        auth.error ?? 'Failed to resend',
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

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final lang = context.watch<LanguageProvider>();
    final isLoading = _isVerifying || context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryCyan.withValues(alpha: 0.35),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: AppColors.primaryCyan.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.school_outlined,
                          color: AppColors.primaryCyan,
                          size: 40,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Email icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryCyan.withValues(alpha: 0.12),
                    border: Border.all(
                      color: AppColors.primaryCyan.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.primaryCyan,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  lang.t('verifyEmail'),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text(isDark),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  lang.t('verifyEmailSub'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                // ── OTP BOXES FIX ─────────────────────────────────
                LayoutBuilder(
                  builder: (context, constraints) {
                    const boxCount = 6;
                    const marginTotal = 8.0 * boxCount;
                    const padTotal = 32.0;
                    final boxSize =
                        ((constraints.maxWidth - marginTotal - padTotal) /
                                boxCount)
                            .clamp(40.0, 54.0);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(boxCount, (i) {
                          return Container(
                            width: boxSize,
                            height: boxSize + 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              // FIX: solid background visible in light mode
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : AppColors.lightInputFill,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.border(isDark),
                                width: 1.5,
                              ),
                            ),
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
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryCyan,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (v) => _onCodeChanged(i, v),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  text: lang.t('verifyBtn'),
                  onPressed: isLoading ? null : _verify,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 20),
                // Resend row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${lang.t('didntReceive')} ',
                      style: TextStyle(color: AppColors.textSecondary(isDark)),
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
                          : Text(
                              lang.t('resendCode'),
                              style: const TextStyle(
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
                    lang.t('backToSignIn'),
                    style: TextStyle(color: AppColors.textMuted(isDark)),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
