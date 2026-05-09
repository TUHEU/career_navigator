import 'package:flutter/material.dart';

enum UserRole { jobSeeker, mentor }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ── Controllers ──────────────────────────────────────────────
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _resetEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  // ── State ─────────────────────────────────────────────────────
  UserRole _selectedRole = UserRole.jobSeeker;
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _showForgotPassword = false;
  bool _resetEmailSent = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ── Theme colours ─────────────────────────────────────────────
  static const Color _navy = Color(0xFF0A0F1E);
  static const Color _skyBlue = Color(0xFF38BDF8);
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _white = Colors.white;
  static const Color _whiteMuted = Color(0x73FFFFFF);
  static const Color _cardBg = Color(0x0AFFFFFF);
  static const Color _borderColor = Color(0x1AFFFFFF);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _resetEmailController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────
  void _switchView(bool showForgot) {
    setState(() {
      _showForgotPassword = showForgot;
      _resetEmailSent = false;
    });
    _animController
      ..reset()
      ..forward();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: replace with your Firebase / API auth call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Signed in as ${_selectedRole == UserRole.jobSeeker ? "Job Seeker" : "Mentor"}',
        ),
        backgroundColor: _skyBlue,
      ),
    );
    // TODO: Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _handleResetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // TODO: replace with your Firebase password-reset call
    await Future.delayed(const Duration(seconds: 1500));

    setState(() {
      _isLoading = false;
      _resetEmailSent = true;
    });
  }

  // ── Validators ────────────────────────────────────────────────
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0F1E), Color(0xFF0D1A35), Color(0xFF091428)],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: _buildCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _cardBg,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLogo(),
          const SizedBox(height: 24),
          _showForgotPassword ? _buildForgotPanel() : _buildLoginPanel(),
        ],
      ),
    );
  }

  // ── Logo ──────────────────────────────────────────────────────
  Widget _buildLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_skyBlue, _indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(19),
              ),
              child: const Icon(Icons.explore, color: _white, size: 20),
            ),
            const SizedBox(width: 10),
            RichText(
              text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _white,
                ),
                children: [
                  TextSpan(text: 'Career'),
                  TextSpan(
                    text: 'Compass',
                    style: TextStyle(color: _skyBlue),
                  ),
                  TextSpan(text: ' AI'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Your Personal Career Navigator',
          style: TextStyle(
            fontSize: 12,
            color: _whiteMuted,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  // ── Login Panel ───────────────────────────────────────────────
  Widget _buildLoginPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _selectedRole == UserRole.jobSeeker
              ? 'Sign in to continue your journey'
              : 'Sign in to guide the next generation',
          style: const TextStyle(fontSize: 13, color: _whiteMuted),
        ),
        const SizedBox(height: 20),

        // Role Toggle
        _buildRoleToggle(),
        const SizedBox(height: 16),

        // Role Badge
        _buildRoleBadge(),
        const SizedBox(height: 16),

        // Form
        Form(
          key: _formKey,
          child: Column(
            children: [
              _buildEmailField(_emailController),
              const SizedBox(height: 14),
              _buildPasswordField(),
              const SizedBox(height: 12),
              _buildRememberForgotRow(),
              const SizedBox(height: 20),
              _buildLoginButton(),
            ],
          ),
        ),

        const SizedBox(height: 20),
        _buildDivider(),
        const SizedBox(height: 16),
        _buildGoogleButton(),
        const SizedBox(height: 20),
        _buildSignUpRow(),
      ],
    );
  }

  // ── Role Toggle ───────────────────────────────────────────────
  Widget _buildRoleToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          _roleTab(
            label: 'Job Seeker',
            icon: Icons.work_outline,
            role: UserRole.jobSeeker,
          ),
          _roleTab(
            label: 'Mentor',
            icon: Icons.people_outline,
            role: UserRole.mentor,
          ),
        ],
      ),
    );
  }

  Widget _roleTab({
    required String label,
    required IconData icon,
    required UserRole role,
  }) {
    final isActive = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(colors: [_skyBlue, _indigo])
                : null,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _skyBlue.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? _white : _whiteMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isActive ? _white : _whiteMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Role Badge ────────────────────────────────────────────────
  Widget _buildRoleBadge() {
    final isSeeker = _selectedRole == UserRole.jobSeeker;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSeeker
            ? const Color(0x1F38BDF8)
            : const Color(0x1F6366F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSeeker
              ? const Color(0x4038BDF8)
              : const Color(0x406366F1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSeeker ? Icons.work_outline : Icons.people_outline,
            size: 12,
            color: isSeeker ? _skyBlue : const Color(0xFF818CF8),
          ),
          const SizedBox(width: 5),
          Text(
            isSeeker ? 'Signing in as Job Seeker' : 'Signing in as Mentor',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isSeeker ? _skyBlue : const Color(0xFF818CF8),
            ),
          ),
        ],
      ),
    );
  }

  // ── Email Field ───────────────────────────────────────────────
  Widget _buildEmailField(TextEditingController controller) {
    return _inputWrapper(
      label: 'Email Address',
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: _white, fontSize: 14),
        validator: _validateEmail,
        decoration: _inputDecoration(
          hint: 'you@example.com',
          prefixIcon: Icons.mail_outline,
        ),
      ),
    );
  }

  // ── Password Field ────────────────────────────────────────────
  Widget _buildPasswordField() {
    return _inputWrapper(
      label: 'Password',
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: _white, fontSize: 14),
        validator: _validatePassword,
        decoration: _inputDecoration(
          hint: 'Enter your password',
          prefixIcon: Icons.lock_outline,
          suffix: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: _whiteMuted,
              size: 18,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
      ),
    );
  }

  // ── Remember / Forgot Row ─────────────────────────────────────
  Widget _buildRememberForgotRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (v) => setState(() => _rememberMe = v ?? false),
                checkColor: _navy,
                activeColor: _skyBlue,
                side: const BorderSide(color: _whiteMuted),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() => _rememberMe = !_rememberMe),
              child: const Text(
                'Remember me',
                style: TextStyle(fontSize: 12, color: _whiteMuted),
              ),
            ),
          ],
        ),
        TextButton(
          onPressed: () => _switchView(true),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Forgot password?',
            style: TextStyle(fontSize: 12, color: _skyBlue),
          ),
        ),
      ],
    );
  }

  // ── Login Button ──────────────────────────────────────────────
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_skyBlue, _indigo]),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _skyBlue.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: _white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Sign In',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _white,
                  ),
                ),
        ),
      ),
    );
  }

  // ── Divider ───────────────────────────────────────────────────
  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0x1AFFFFFF))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: TextStyle(fontSize: 11, color: _whiteMuted),
          ),
        ),
        const Expanded(child: Divider(color: Color(0x1AFFFFFF))),
      ],
    );
  }

  // ── Google Button ─────────────────────────────────────────────
  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: () {
          // TODO: implement Google Sign-In
        },
        icon: Image.network(
          'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
          width: 18,
          height: 18,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.g_mobiledata, color: _white, size: 20),
        ),
        label: const Text(
          'Continue with Google',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _whiteMuted,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: const Color(0x0DFFFFFF),
        ),
      ),
    );
  }

  // ── Sign Up Row ───────────────────────────────────────────────
  Widget _buildSignUpRow() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Don't have an account?",
            style: TextStyle(fontSize: 13, color: _whiteMuted),
          ),
          TextButton(
            onPressed: () {
              // TODO: Navigator.pushNamed(context, '/register');
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.only(left: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Create one',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _skyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Forgot Password Panel ─────────────────────────────────────
  Widget _buildForgotPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Back button
        TextButton.icon(
          onPressed: () => _switchView(false),
          icon: const Icon(Icons.arrow_back, size: 16, color: _whiteMuted),
          label: const Text(
            'Back to login',
            style: TextStyle(fontSize: 13, color: _whiteMuted),
          ),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Reset Password',
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _white,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          "Enter your email and we'll send you a link to reset your password.",
          style: TextStyle(fontSize: 13, color: _whiteMuted),
        ),
        const SizedBox(height: 24),

        Form(
          key: _resetFormKey,
          child: Column(
            children: [
              _buildEmailField(_resetEmailController),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_skyBlue, _indigo],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: _white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Send Reset Link',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Success message
        if (_resetEmailSent) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0x1438BDF8),
              border: Border.all(color: const Color(0x4038BDF8)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: _skyBlue, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Reset link sent! Check your inbox and follow the instructions.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF7DD3FC)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Shared Input Helpers ──────────────────────────────────────
  Widget _inputWrapper({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: _whiteMuted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0x40FFFFFF), fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: _whiteMuted, size: 18),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0x0FFFFFFF),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0x8038BDF8)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0x80F87171)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xBFF87171)),
      ),
      errorStyle: const TextStyle(
        fontSize: 11,
        color: Color(0xFFF87171),
      ),
    );
  }
}
