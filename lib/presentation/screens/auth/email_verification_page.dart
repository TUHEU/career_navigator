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

class _EmailVerificationPageState extends State<EmailVerificationPage>
    with WidgetsBindingObserver {
  // ── Controllers ────────────────────────────────────────────
  final List<TextEditingController> _ctrl = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focus = List.generate(6, (_) => FocusNode());
  final _singleCtrl = TextEditingController(); // hidden single field

  // ── State ──────────────────────────────────────────────────
  bool _isVerifying = false;
  bool _isResending = false;
  bool _autoTriggered = false;
  bool _clipChecked = false; // only check clipboard once on open
  int _countdown = 60;
  Timer? _timer;

  // ── Lifecycle ──────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCountdown();
    // Auto-read clipboard after first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryReadClipboard();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    for (final c in _ctrl) c.dispose();
    for (final f in _focus) f.dispose();
    _singleCtrl.dispose();
    super.dispose();
  }

  /// Re-check clipboard when app comes back to foreground
  /// (user opens email app → copies code → returns)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isVerifying) {
      _tryReadClipboard();
    }
  }

  // ── Countdown ──────────────────────────────────────────────
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

  // ── Auto-read clipboard ────────────────────────────────────
  /// Reads the clipboard. If it contains exactly 6 digits it
  /// fills all boxes automatically and triggers verification.
  Future<void> _tryReadClipboard() async {
    if (_isVerifying) return;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = (data?.text ?? '').trim();
      final digits = text.replaceAll(RegExp(r'\D'), '');
      if (digits.length == 6) {
        _fillCode(digits);
        // Small delay so user sees the filled boxes before submission
        await Future.delayed(const Duration(milliseconds: 400));
        if (mounted && !_isVerifying) _verify();
      }
    } catch (_) {
      // Clipboard access denied — fail silently
    }
  }

  // ── Fill all 6 boxes ───────────────────────────────────────
  void _fillCode(String digits) {
    if (digits.length != 6) return;
    for (int i = 0; i < 6; i++) {
      _ctrl[i].text = digits[i];
    }
    setState(() {});
    _focus[5].requestFocus();
  }

  // ── Clear all boxes ────────────────────────────────────────
  void _clearAll() {
    for (final c in _ctrl) c.clear();
    _autoTriggered = false;
    _clipChecked = false;
    setState(() {});
    if (mounted) _focus[0].requestFocus();
  }

  // ── Full 6-digit string ────────────────────────────────────
  String get _fullCode => _ctrl.map((c) => c.text).join();

  // ── Verify ─────────────────────────────────────────────────
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
        auth.error ?? 'Invalid or expired code. Try again.',
        isError: true,
      );
      _clearAll();
    }
  }

  // ── Resend ─────────────────────────────────────────────────
  Future<void> _resend() async {
    if (_isResending || _countdown > 0) return;
    setState(() => _isResending = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.resendCode(widget.email);
    if (!mounted) return;
    setState(() => _isResending = false);

    if (success) {
      Helpers.showSnackBar(context, 'New code sent! Check your email.');
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

  // ── Handle digit change ────────────────────────────────────
  void _onChanged(int index, String value) {
    // ── Handle paste of full code ──
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 6) {
        _fillCode(digits.substring(0, 6));
        // trigger auto-verify
        if (!_autoTriggered && !_isVerifying) {
          _autoTriggered = true;
          Future.delayed(const Duration(milliseconds: 300), _verify);
        }
        return;
      }
      // partial paste — fill what we can
      for (int i = index; i < 6 && (i - index) < digits.length; i++) {
        _ctrl[i].text = digits[i - index];
      }
      final next = (index + digits.length).clamp(0, 5);
      _focus[next].requestFocus();
      setState(() {});
    } else if (value.isNotEmpty && index < 5) {
      _focus[index + 1].requestFocus();
    }

    setState(() {});

    // Auto-submit when all 6 filled
    if (_fullCode.length == 6 && !_autoTriggered && !_isVerifying) {
      _autoTriggered = true;
      Future.delayed(const Duration(milliseconds: 300), _verify);
    } else if (_fullCode.length < 6) {
      _autoTriggered = false;
    }
  }

  // ── Handle backspace ───────────────────────────────────────
  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrl[index].text.isEmpty &&
        index > 0) {
      _focus[index - 1].requestFocus();
    }
  }

  // ── Build ──────────────────────────────────────────────────
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
                // ── Logo ────────────────────────────────
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

                // ── Email icon ───────────────────────────
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

                // ── Title ────────────────────────────────
                Text(
                  'Check Your Email',
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
                const SizedBox(height: 10),

                // ── Auto-fill banner ─────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryCyan.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primaryCyan,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Open your email, copy the 6-digit code — '
                          'the app will fill it in automatically.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? Colors.white.withOpacity(0.7)
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── OTP boxes ────────────────────────────
                _buildOtpRow(isDark),
                const SizedBox(height: 12),

                // ── Paste button ─────────────────────────
                TextButton.icon(
                  onPressed: _tryReadClipboard,
                  icon: const Icon(
                    Icons.content_paste_rounded,
                    size: 16,
                    color: AppColors.primaryCyan,
                  ),
                  label: const Text(
                    'Paste code from clipboard',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primaryCyan,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Verify button ────────────────────────
                PrimaryButton(
                  text: 'VERIFY EMAIL',
                  onPressed: isLoading ? null : _verify,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 24),

                // ── Resend row ───────────────────────────
                _buildResendRow(isDark),
                const SizedBox(height: 16),

                // ── Back ─────────────────────────────────
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

  // ── OTP box row ────────────────────────────────────────────
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
            final filled = _ctrl[i].text.isNotEmpty;
            return Container(
              width: box,
              height: box + 10,
              margin: EdgeInsets.only(right: i < count - 1 ? gap : 0),
              child: KeyboardListener(
                focusNode: FocusNode(),
                onKeyEvent: (e) => _onKeyEvent(i, e),
                child: TextFormField(
                  controller: _ctrl[i],
                  focusNode: _focus[i],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 6, // allow paste of full code in one box
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
                        ? AppColors.primaryCyan.withOpacity(isDark ? 0.15 : 0.1)
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
                            ? AppColors.primaryCyan.withOpacity(0.7)
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

  // ── Resend row ─────────────────────────────────────────────
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
