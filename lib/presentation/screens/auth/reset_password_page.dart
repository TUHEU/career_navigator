import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/buttons.dart';
import 'sign_in_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // OTP boxes
  final List<TextEditingController> _codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _isResending = false;
  bool _autoSubmitTriggered = false;

  String get _fullCode => _codeControllers.map((c) => c.text).join();

  @override
  void dispose() {
    for (final c in _codeControllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _onCodeChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }
    if (_fullCode.length != 6) _autoSubmitTriggered = false;
  }

  Future<void> _resend() async {
    if (_isResending) return;
    setState(() => _isResending = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.forgotPassword(widget.email);

    if (!mounted) return;
    setState(() => _isResending = false);

    if (success) {
      Helpers.showSnackBar(context, 'New code sent to ${widget.email}!');
      for (final c in _codeControllers) c.clear();
      _focusNodes[0].requestFocus();
      _autoSubmitTriggered = false;
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.error ?? 'Failed to resend code',
        isError: true,
      );
    }
  }

  Future<void> _submit() async {
    final code = _fullCode;
    if (code.length < 6) {
      Helpers.showSnackBar(
        context,
        'Please enter the complete 6-digit code',
        isError: true,
      );
      return;
    }
    if (_newPassController.text.isEmpty) {
      Helpers.showSnackBar(
        context,
        'Please enter a new password',
        isError: true,
      );
      return;
    }
    if (_newPassController.text.length < 6) {
      Helpers.showSnackBar(
        context,
        'Password must be at least 6 characters',
        isError: true,
      );
      return;
    }
    if (_newPassController.text != _confirmPassController.text) {
      Helpers.showSnackBar(context, 'Passwords do not match', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.resetPassword(
      widget.email,
      code,
      _newPassController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Helpers.showSnackBar(
        context,
        'Password reset successfully! Please sign in.',
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (_) => false,
      );
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.error ?? 'Invalid or expired code',
        isError: true,
      );
      // Clear code boxes on failure
      for (final c in _codeControllers) c.clear();
      _focusNodes[0].requestFocus();
      _autoSubmitTriggered = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Reset Password'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            // Icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryCyan.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.primaryCyan.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.lock_reset_outlined,
                color: AppColors.primaryCyan,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Enter Reset Code',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a 6-digit code to',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.6)
                    : AppColors.lightTextSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.email,
              style: const TextStyle(
                color: AppColors.primaryCyan,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),

            // OTP boxes
            LayoutBuilder(
              builder: (context, constraints) {
                const boxCount = 6;
                const marginPerBox = 8.0;
                const innerPadding = 16.0;
                final available =
                    constraints.maxWidth -
                    (marginPerBox * boxCount) -
                    (innerPadding * 2);
                final boxSize = (available / boxCount).clamp(36.0, 52.0);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(boxCount, (i) {
                      return Container(
                        width: boxSize,
                        height: boxSize + 6,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: TextFormField(
                          controller: _codeControllers[i],
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
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.07),
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey.shade300,
                              ),
                            ),
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

            // New Password
            _buildPasswordField(
              controller: _newPassController,
              label: 'New Password',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
              isDark: isDark,
            ),
            const SizedBox(height: 16),

            // Confirm Password
            _buildPasswordField(
              controller: _confirmPassController,
              label: 'Confirm New Password',
              obscure: _obscureConfirm,
              onToggle: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              isDark: isDark,
            ),
            const SizedBox(height: 32),

            // Submit button
            PrimaryButton(
              text: 'RESET PASSWORD',
              onPressed: _submit,
              isLoading: _isLoading,
            ),
            const SizedBox(height: 20),

            // Resend row
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
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: TextStyle(color: isDark ? Colors.white : AppColors.lightText),
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
          borderSide: const BorderSide(
            color: AppColors.primaryCyan,
            width: 1.5,
          ),
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
}
