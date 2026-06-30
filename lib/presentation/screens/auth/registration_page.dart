// presentation/screens/auth/registration_page.dart — v11
// Step-by-step multi-step registration with progress indicator
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/buttons.dart';
import 'email_verification_page.dart';
import 'sign_in_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage>
    with TickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  late final PageController _pageCtrl;
  late final AnimationController _stepCtrl;

  int  _step      = 0;
  bool _obsPass   = true;
  bool _obsConf   = true;
  bool _loading   = false;
  String? _error;
  DateTime? _dob;
  String _gender  = '';

  static const _steps = ['Account', 'Personal', 'Security'];

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
    _stepCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _pageCtrl.dispose(); _stepCtrl.dispose();
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _phoneCtrl.dispose(); _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < 2) {
      _pageCtrl.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      setState(() { _step++; _error = null; });
    } else {
      _register();
    }
  }

  void _back() {
    if (_step > 0) {
      _pageCtrl.previousPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      setState(() { _step--; _error = null; });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match');
      return;
    }
    setState(() { _loading = true; _error = null; });

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      _emailCtrl.text.trim(),
      _passCtrl.text,
      fullName:    _nameCtrl.text.trim(),
      phone:       _phoneCtrl.text.trim(),
      dateOfBirth: _dob != null
          ? '${_dob!.year}-${_dob!.month.toString().padLeft(2,'0')}-${_dob!.day.toString().padLeft(2,'0')}'
          : null,
      gender:      _gender.isNotEmpty ? _gender : null,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => EmailVerificationPage(
          email: _emailCtrl.text.trim())),
        (_) => false);
    } else {
      setState(() => _error = auth.error);
    }
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950), lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primaryCyan)),
        child: child!));
    if (picked != null) setState(() => _dob = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(children: [
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(children: [
                Row(children: [
                  GestureDetector(
                    onTap: _back,
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card(isDark),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border(isDark))),
                      child: Icon(Icons.arrow_back_ios_rounded,
                        color: AppColors.text(isDark), size: 16))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Create Account', style: TextStyle(
                      color: AppColors.text(isDark),
                      fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('Step ${_step + 1} of 3 · ${_steps[_step]}',
                      style: TextStyle(
                        color: AppColors.textMuted(isDark), fontSize: 12)),
                  ])),
                ]),
                const SizedBox(height: 16),
                // Step progress bar
                Row(children: List.generate(3, (i) => Expanded(child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= _step
                          ? AppColors.primaryCyan
                          : AppColors.border(isDark),
                      borderRadius: BorderRadius.circular(2))))))),
              ]),
            ),
            const SizedBox(height: 8),

            // ── Error banner ────────────────────────────────
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.danger.withOpacity(0.3))),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.danger, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_error!, style: const TextStyle(
                      color: AppColors.danger, fontSize: 12))),
                    GestureDetector(onTap: () => setState(() => _error = null),
                      child: const Icon(Icons.close,
                          color: AppColors.danger, size: 14)),
                  ]))),

            // ── Pages ───────────────────────────────────────
            Expanded(child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _StepAccount(nameCtrl: _nameCtrl, emailCtrl: _emailCtrl, isDark: isDark),
                _StepPersonal(phoneCtrl: _phoneCtrl, isDark: isDark,
                  dob: _dob, gender: _gender,
                  onPickDob: _pickDob,
                  onGender: (g) => setState(() => _gender = g)),
                _StepSecurity(passCtrl: _passCtrl, confirmCtrl: _confirmCtrl,
                  isDark: isDark, obsPass: _obsPass, obsConf: _obsConf,
                  onTogglePass: () => setState(() => _obsPass = !_obsPass),
                  onToggleConf: () => setState(() => _obsConf = !_obsConf)),
              ],
            )),

            // ── Bottom action ───────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(children: [
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCyan,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0),
                    child: _loading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.black))
                        : Text(_step < 2 ? 'Continue →' : 'Create Account 🚀',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)))),
                const SizedBox(height: 14),
                if (_step == 0)
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Already have an account? ', style: TextStyle(
                      color: AppColors.textMuted(isDark), fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const SignInPage())),
                      child: const Text('Sign In', style: TextStyle(
                        color: AppColors.primaryCyan,
                        fontWeight: FontWeight.bold, fontSize: 13))),
                  ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Step 1: Account ───────────────────────────────────────────────
class _StepAccount extends StatelessWidget {
  final TextEditingController nameCtrl, emailCtrl; final bool isDark;
  const _StepAccount({required this.nameCtrl, required this.emailCtrl,
    required this.isDark});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Your Identity', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text("Let's start with the basics",
        style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 13)),
      const SizedBox(height: 24),
      _RegField(ctrl: nameCtrl, label: 'Full Name', hint: 'Fahdil Moussa',
        icon: Icons.person_outline_rounded, isDark: isDark,
        validator: (v) => v == null || v.trim().length < 2 ? 'Enter your full name' : null),
      const SizedBox(height: 14),
      _RegField(ctrl: emailCtrl, label: 'Email Address', hint: 'you@example.com',
        icon: Icons.email_outlined, isDark: isDark,
        type: TextInputType.emailAddress,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Email required';
          if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
          return null;
        }),
    ]),
  );
}

// ── Step 2: Personal ──────────────────────────────────────────────
class _StepPersonal extends StatelessWidget {
  final TextEditingController phoneCtrl;
  final bool isDark;
  final DateTime? dob;
  final String gender;
  final VoidCallback onPickDob;
  final Function(String) onGender;
  const _StepPersonal({required this.phoneCtrl, required this.isDark,
    required this.dob, required this.gender,
    required this.onPickDob, required this.onGender});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('About You', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text('Help us personalise your experience',
        style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 13)),
      const SizedBox(height: 24),
      _RegField(ctrl: phoneCtrl, label: 'Phone Number (optional)',
        hint: '+237 6XX XXX XXX',
        icon: Icons.phone_outlined, isDark: isDark,
        type: TextInputType.phone),
      const SizedBox(height: 14),
      // Date of birth
      GestureDetector(
        onTap: onPickDob,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(isDark))),
          child: Row(children: [
            const Icon(Icons.cake_outlined, color: AppColors.primaryCyan, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(
              dob != null
                  ? '${dob!.day}/${dob!.month}/${dob!.year}'
                  : 'Date of Birth (optional)',
              style: TextStyle(
                color: dob != null
                    ? AppColors.text(isDark)
                    : AppColors.textMuted(isDark),
                fontSize: 14))),
            Icon(Icons.calendar_today_outlined,
                color: AppColors.textMuted(isDark), size: 16),
          ])),
      ),
      const SizedBox(height: 14),
      // Gender
      Text('Gender (optional)', style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 13)),
      const SizedBox(height: 8),
      Row(children: ['Male', 'Female', 'Other'].map((g) {
        final gKey = g.toLowerCase();
        final sel  = gender == gKey;
        return Expanded(child: GestureDetector(
          onTap: () => onGender(sel ? '' : gKey),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: EdgeInsets.only(right: g != 'Other' ? 8 : 0),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: sel
                  ? AppColors.primaryCyan.withOpacity(0.12)
                  : AppColors.card(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: sel
                  ? AppColors.primaryCyan : AppColors.border(isDark))),
            child: Text(g, textAlign: TextAlign.center,
              style: TextStyle(
                color: sel ? AppColors.primaryCyan : AppColors.textMuted(isDark),
                fontWeight: FontWeight.w600, fontSize: 13)))));
      }).toList()),
    ]),
  );
}

// ── Step 3: Security ──────────────────────────────────────────────
class _StepSecurity extends StatelessWidget {
  final TextEditingController passCtrl, confirmCtrl;
  final bool isDark, obsPass, obsConf;
  final VoidCallback onTogglePass, onToggleConf;
  const _StepSecurity({required this.passCtrl, required this.confirmCtrl,
    required this.isDark, required this.obsPass, required this.obsConf,
    required this.onTogglePass, required this.onToggleConf});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Secure Your Account', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 22, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text('Choose a strong password',
        style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 13)),
      const SizedBox(height: 24),
      _RegField(ctrl: passCtrl, label: 'Password', hint: '••••••••',
        icon: Icons.lock_outline_rounded, isDark: isDark,
        obscure: obsPass, suffix: IconButton(
          icon: Icon(obsPass
              ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.primaryCyan, size: 20),
          onPressed: onTogglePass),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Password required';
          if (v.length < 8) return 'At least 8 characters';
          if (!v.contains(RegExp(r'[A-Z]'))) return 'Include an uppercase letter';
          if (!v.contains(RegExp(r'[0-9]'))) return 'Include a number';
          return null;
        }),
      const SizedBox(height: 14),
      _RegField(ctrl: confirmCtrl, label: 'Confirm Password', hint: '••••••••',
        icon: Icons.lock_outline_rounded, isDark: isDark,
        obscure: obsConf, suffix: IconButton(
          icon: Icon(obsConf
              ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.primaryCyan, size: 20),
          onPressed: onToggleConf),
        validator: (v) => v == null || v.isEmpty ? 'Confirm your password' : null),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF059669).withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF059669).withOpacity(0.2))),
        child: Column(children: [
          '✓ At least 8 characters',
          '✓ One uppercase letter (A–Z)',
          '✓ One number (0–9)',
        ].map((t) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: Color(0xFF059669), size: 14),
            const SizedBox(width: 8),
            Text(t, style: const TextStyle(
              color: Color(0xFF059669), fontSize: 12)),
          ]))).toList()),
      ),
    ]),
  );
}

// ── Registration field ────────────────────────────────────────────
class _RegField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint; final IconData icon;
  final bool isDark, obscure;
  final TextInputType type;
  final Widget? suffix;
  final String? Function(String?)? validator;
  const _RegField({required this.ctrl, required this.label,
    required this.hint, required this.icon, required this.isDark,
    this.obscure = false, this.type = TextInputType.text,
    this.suffix, this.validator});
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl, obscureText: obscure,
    keyboardType: type, validator: validator,
    style: TextStyle(color: AppColors.text(isDark)),
    decoration: InputDecoration(
      labelText: label, hintText: hint,
      hintStyle: TextStyle(color: AppColors.textMuted(isDark), fontSize: 13),
      labelStyle: TextStyle(color: AppColors.textMuted(isDark)),
      prefixIcon: Icon(icon, color: AppColors.primaryCyan, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.04)
          : Colors.grey.withOpacity(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.border(isDark))),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryCyan, width: 1.5)),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.danger))),
  );
}
