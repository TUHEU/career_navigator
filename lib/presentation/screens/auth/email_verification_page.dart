import 'dart:async';
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
  bool _autoTriggered = false;
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        if (_countdown > 0)
          _countdown--;
        else
          t.cancel();
      });
    });
  }

  String get _fullCode => _controllers.map((c) => c.text).join();

  void _clearAll() {
    for (final c in _controllers) c.clear();
    _autoTriggered = false;
    if (mounted) {
      setState(() {});
      _focusNodes[0].requestFocus();
    }
  }

  Future<void> _verify() async {
    if (_isVerifying) return;
    final code = _fullCode;
    if (code.length < 6) {
      Helpers.showSnackBar(
        context,
        'Please enter all 6 digits.',
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
        auth.error ?? 'Invalid code. Please try again.',
        isError: true,
      );
      _clearAll();
    }
  }

  Future<void> _resend() async {
    if (_isResending || _countdown > 0) return;
    setState(() => _isResending = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.resendCode(widget.email);
    if (!mounted) return;
    setState(() => _isResending = false);
    if (success) {
      Helpers.showSnackBar(context, 'New code sent to ${widget.email}!');
      _clearAll();
      _startCountdown();
    } else {
      Helpers.showSnackBar(
        context,
        auth.error ?? 'Failed to resend code.',
        isError: true,
      );
    }
  }

  void _onChanged(int index, String value) {
    // Handle paste — distribute digits across all boxes
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < 6 && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      final next = (digits.length - 1).clamp(0, 5);
      _focusNodes[next].requestFocus();
    } else if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }

    setState(() {});

    if (_fullCode.length == 6 && !_autoTriggered && !_isVerifying) {
      _autoTriggered = true;
      Future.delayed(const Duration(milliseconds: 250), _verify);
    } else if (_fullCode.length < 6) {
      _autoTriggered = false;
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isLoading = _isVerifying;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryCyan.withOpacity(0.35),
                        blurRadius: 24,
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
                ),
                const SizedBox(height: 28),

                // Email icon
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryCyan.withOpacity(0.1),
                    border: Border.all(
                      color: AppColors.primaryCyan.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    color: AppColors.primaryCyan,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'We sent a 6-digit code to',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white.withOpacity(0.6)
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryCyan,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // OTP boxes
                _buildOtpRow(isDark),
                const SizedBox(height: 10),

                // Helper text
                Text(
                  'Tip: you can paste the full code directly',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white.withOpacity(0.3)
                        : AppColors.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 28),

                // Verify button
                PrimaryButton(
                  text: 'VERIFY EMAIL',
                  onPressed: isLoading ? null : _verify,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 24),

                // Resend
                _buildResendRow(isDark),
                const SizedBox(height: 16),

                // Back
                TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInPage()),
                  ),
                  child: Text(
                    '← Back to Sign In',
                    style: TextStyle(
                      fontSize: 13,
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
      ),
    );
  }

  Widget _buildOtpRow(bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const count = 6;
        const gap = 8.0;
        final box = ((constraints.maxWidth - gap * (count - 1)) / count).clamp(
          40.0,
          54.0,
        );

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(count, (i) {
            final filled = _controllers[i].text.isNotEmpty;
            return Container(
              width: box,
              height: box + 8,
              margin: EdgeInsets.only(right: i < count - 1 ? gap : 0),
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (e) => _onKeyEvent(i, e),
                child: TextFormField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 6, // allow paste of full code
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: TextStyle(
                    fontSize: box * 0.46,
                    fontWeight: FontWeight.bold,
                    color: filled
                        ? AppColors.primaryCyan
                        : (isDark ? Colors.white : AppColors.lightText),
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: filled
                        ? AppColors.primaryCyan.withOpacity(
                            isDark ? 0.12 : 0.08,
                          )
                        : (isDark
                              ? Colors.white.withOpacity(0.06)
                              : AppColors.lightInputFill),
                    contentPadding: EdgeInsets.zero,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: filled
                            ? AppColors.primaryCyan.withOpacity(0.6)
                            : (isDark
                                  ? Colors.white.withOpacity(0.18)
                                  : AppColors.lightBorder),
                        width: filled ? 2 : 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: AppColors.primaryCyan,
                        width: 2.5,
                      ),
                    ),
                  ),
                  onChanged: (v) => _onChanged(i, v),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildResendRow(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Didn't receive the code? ",
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? Colors.white.withOpacity(0.55)
                : AppColors.lightTextSecondary,
          ),
        ),
        if (_isResending)
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primaryCyan,
            ),
          )
        else if (_countdown > 0)
          Text(
            'Resend in ${_countdown}s',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withOpacity(0.35)
                  : AppColors.lightTextMuted,
            ),
          )
        else
          GestureDetector(
            onTap: _resend,
            child: const Text(
              'Resend',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryCyan,
              ),
            ),
          ),
      ],
    );
  }
}
