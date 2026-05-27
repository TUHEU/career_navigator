// presentation/screens/auth/splash_screen.dart
// v8: Animated splash → Onboarding (first time) OR dashboard (returning)
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/auth_provider.dart';
import 'sign_in_page.dart';
import '../dashboard/job_seeker_dashboard.dart';
import '../dashboard/mentor_dashboard.dart';
import '../dashboard/admin_dashboard.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late AnimationController _enterCtrl;
  late Animation<double>   _fade;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();

    _ringCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 12))..repeat();

    _enterCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));

    _fade  = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.65, end: 1.0).animate(
        CurvedAnimation(parent: _enterCtrl, curve: Curves.elasticOut));

    Future.delayed(const Duration(milliseconds: 200),
        () { if (mounted) _enterCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 2800),
        () { if (mounted) _navigate(); });
  }

  @override
  void dispose() {
    _ringCtrl.dispose(); _enterCtrl.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    final prefs  = await SharedPreferences.getInstance();
    final onboarded = prefs.getBool('onboarding_done') ?? false;

    if (!onboarded) {
      _go(const OnboardingScreen());
      return;
    }

    final auth = context.read<AuthProvider>();
    final token = await auth.getAccessToken();
    if (token != null) {
      final ok = await auth.loadUserProfile();
      if (ok && mounted) {
        final role = auth.currentUser?.role;
        if (role == 'admin')  { _go(const AdminDashboard());     return; }
        if (role == 'mentor') { _go(const MentorDashboard());    return; }
        _go(const JobSeekerDashboard()); return;
      }
      await auth.logout();
    }
    _go(const SignInPage());
  }

  void _go(Widget page) {
    if (!mounted) return;
    Navigator.pushReplacement(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: a, child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A12),
      body: Stack(children: [
        // Background
        Positioned.fill(child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.3), radius: 0.9,
              colors: [Color(0xFF0D1825), Color(0xFF080A12)],
            ),
          ),
        )),

        // Rotating rings (inspired by ApexSpeech)
        Center(child: AnimatedBuilder(
          animation: _ringCtrl,
          builder: (_, __) => Stack(
            alignment: Alignment.center,
            children: List.generate(5, (i) {
              final sz  = 80.0 + i * 72;
              final op  = 0.025 + i * 0.01;
              final dir = i.isEven ? 1.0 : -1.0;
              return Transform.rotate(
                angle: _ringCtrl.value * 2 * pi * dir * (0.4 + i * 0.1),
                child: Container(
                  width: sz, height: sz,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryCyan.withOpacity(op), width: 1),
                  ),
                ),
              );
            }),
          ),
        )),

        // Logo + name
        Center(child: FadeTransition(
          opacity: _fade,
          child: ScaleTransition(
            scale: _scale,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              // Logo with glow
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryCyan.withOpacity(0.08),
                  border: Border.all(
                    color: AppColors.primaryCyan.withOpacity(0.4), width: 1.5),
                  boxShadow: [BoxShadow(
                    color: AppColors.primaryCyan.withOpacity(0.3),
                    blurRadius: 50, spreadRadius: 10,
                  )],
                ),
                child: ClipOval(child: Image.asset(
                  'assets/logo/logo.png', fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.compass_calibration_outlined,
                    color: AppColors.primaryCyan, size: 46),
                )),
              ),
              const SizedBox(height: 28),
              // Gradient text
              ShaderMask(
                shaderCallback: (b) => LinearGradient(
                  colors: [AppColors.primaryCyan,
                           AppColors.primaryCyan.withOpacity(0.6)],
                ).createShader(b),
                blendMode: BlendMode.srcIn,
                child: const Text('CAREER NAVIGATOR', style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: 4,
                )),
              ),
              const SizedBox(height: 8),
              Text('YOUR FUTURE STARTS HERE', style: TextStyle(
                fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.3),
              )),
              const SizedBox(height: 60),
              _PulsingDots(),
            ]),
          ),
        )),
      ]),
    );
  }
}

class _PulsingDots extends StatefulWidget {
  @override State<_PulsingDots> createState() => _PulsingDotsState();
}
class _PulsingDotsState extends State<_PulsingDots>
    with TickerProviderStateMixin {
  final List<AnimationController> _cs = [];
  final List<Animation<double>>   _as = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 3; i++) {
      final c = AnimationController(vsync: this,
          duration: const Duration(milliseconds: 700));
      final a = Tween<double>(begin: 0.2, end: 1.0)
          .animate(CurvedAnimation(parent: c, curve: Curves.easeInOut));
      _cs.add(c); _as.add(a);
      Future.delayed(Duration(milliseconds: i * 200),
          () { if (mounted) c.repeat(reverse: true); });
    }
  }

  @override void dispose() { for (final c in _cs) c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(3, (i) => AnimatedBuilder(
      animation: _as[i],
      builder: (_, __) => Container(
        width: 6, height: 6,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryCyan.withOpacity(_as[i].value),
        ),
      ),
    )),
  );
}
