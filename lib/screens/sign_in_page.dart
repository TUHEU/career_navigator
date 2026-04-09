import 'dart:ui';
import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_store.dart';
import '../theme/app_theme.dart';
import 'registration_page.dart';
import 'dashboard_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final res = await ApiService.login(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!mounted) return;
      if (res['success'] == true) {
        final data = res['data'] as Map<String, dynamic>;
        await TokenStore.save(data['access_token'], data['refresh_token']);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        _showSnack(res['message'] ?? 'Login failed');
      }
    } catch (e) {
      _showSnack('Network error. Check your connection.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/bg2.png'),
                fit: BoxFit.cover,
                opacity: 0.45,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.45)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 36),
                    _buildGlassCard(),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 20),
                    _buildSocialButtons(),
                    const SizedBox(height: 28),
                    _buildSignUpRow(),
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

  Widget _buildHeader() => Column(
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
          child: Image.asset('assets/logo/logo.png', fit: BoxFit.cover),
        ),
      ),
      const SizedBox(height: 16),
      const Text(
        'Welcome Back',
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'Sign in to continue your journey',
        style: TextStyle(color: Colors.white.withOpacity(0.65), fontSize: 14),
      ),
    ],
  );

  Widget _buildGlassCard() => ClipRRect(
    borderRadius: BorderRadius.circular(28),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Enter a valid email' : null,
                decoration: buildInputDecoration(
                  icon: Icons.email_outlined,
                  label: 'Email Address',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscurePassword,
                style: const TextStyle(color: Colors.white),
                validator: (v) =>
                    v == null || v.length < 6 ? 'Min 6 characters' : null,
                decoration: buildInputDecoration(
                  icon: Icons.lock_outline,
                  label: 'Password',
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.primaryCyan,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Transform.scale(
                        scale: 0.85,
                        child: Switch(
                          value: _rememberMe,
                          activeColor: AppColors.primaryCyan,
                          onChanged: (v) => setState(() => _rememberMe = v),
                        ),
                      ),
                      Text(
                        'Remember me',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showForgotPasswordSheet(context),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.primaryCyan,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCyan,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 6,
                  shadowColor: AppColors.primaryCyan.withOpacity(0.5),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'SIGN IN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildDivider() => Row(
    children: [
      Expanded(child: Divider(color: Colors.white.withOpacity(0.25))),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          'or continue with',
          style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13),
        ),
      ),
      Expanded(child: Divider(color: Colors.white.withOpacity(0.25))),
    ],
  );

  Widget _buildSocialButtons() => Column(
    children: [
      _buildSocialButton(
        onTap: () => _showSnack('Google Sign-In coming soon'),
        icon: Icons.g_mobiledata,
        iconColor: Colors.redAccent,
        label: 'Continue with Google',
      ),
      const SizedBox(height: 12),
      _buildSocialButton(
        onTap: () => _showSnack('Apple Sign-In coming soon'),
        icon: Icons.apple,
        iconColor: Colors.white,
        label: 'Continue with Apple',
      ),
    ],
  );

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color iconColor,
    required String label,
  }) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSignUpRow() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Don't have an account? ",
        style: TextStyle(color: Colors.white.withOpacity(0.65)),
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

  void _showSnack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _showForgotPasswordSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0D2137),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
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
            const Text(
              'Reset Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Enter your email and we'll send a reset link.",
              style: TextStyle(color: Colors.white.withOpacity(0.6)),
            ),
            const SizedBox(height: 20),
            TextField(
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: buildInputDecoration(
                icon: Icons.email_outlined,
                label: 'Email Address',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _showSnack('Reset link sent!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCyan,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'SEND RESET LINK',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
