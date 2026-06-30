// presentation/screens/auth/splash_screen.dart — v11
// Animated splash with logo pulse, gradient background, version
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guest_provider.dart';
import '../dashboard/job_seeker_dashboard.dart';
import '../dashboard/admin_dashboard.dart';
import '../dashboard/mentor_dashboard.dart';
import 'sign_in_page.dart';
import '../onboarding/onboarding_screen.dart';
import '../../../data/datasources/local/token_store.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double>   _logoScale;
  late Animation<double>   _logoOpacity;
  late Animation<double>   _taglineFade;
  late Animation<Offset>   _taglineSlide;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));

    _logoScale = CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut)
        .drive(Tween(begin: 0.4, end: 1.0));
    _logoOpacity = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
    _taglineFade  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn)
        .drive(Tween(begin: 0.0, end: 1.0));
    _taglineSlide = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut)
        .drive(Tween(begin: const Offset(0, 0.5), end: Offset.zero));

    _logoCtrl.forward().then((_) => _fadeCtrl.forward());

    Future.delayed(const Duration(milliseconds: 2500), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;
    final store  = TokenStore();
    final token  = await store.getAccess();
    final isFirst = await store.isFirstLaunch();

    if (isFirst) {
      await store.setFirstLaunchDone();
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      }
      return;
    }

    if (token == null) {
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const SignInPage()));
      }
      return;
    }

    final auth = context.read<AuthProvider>();
    await auth.loadUserProfile();
    if (!mounted) return;

    final role = auth.currentUser?.role;
    Widget dest;
    if (role == 'admin') {
      dest = const AdminDashboard();
    } else if (role == 'mentor') {
      dest = const MentorDashboard();
    } else {
      dest = const JobSeekerDashboard();
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => dest));
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF060912), Color(0xFF0B1222), Color(0xFF060912)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
        ),
        child: Stack(children: [
          // Glow orbs
          Positioned(top: -100, left: -100, child: _Orb(360, AppColors.primaryCyan, 0.06)),
          Positioned(bottom: -150, right: -80, child: _Orb(400, const Color(0xFF7C3AED), 0.05)),

          // Main content
          Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Logo
            AnimatedBuilder(
              animation: _logoCtrl,
              builder: (_, __) => Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryCyan.withOpacity(0.1),
                      border: Border.all(
                          color: AppColors.primaryCyan.withOpacity(0.35), width: 2),
                      boxShadow: [BoxShadow(
                        color: AppColors.primaryCyan.withOpacity(0.25),
                        blurRadius: 40, spreadRadius: 8)]),
                    child: ClipOval(child: Image.asset(
                      'assets/logo/logo.png', fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.compass_calibration_outlined,
                        color: AppColors.primaryCyan, size: 52))),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // App name
            FadeTransition(
              opacity: _taglineFade,
              child: SlideTransition(
                position: _taglineSlide,
                child: Column(children: [
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(
                      colors: [AppColors.primaryCyan, Color(0xFF7C3AED)],
                    ).createShader(b),
                    blendMode: BlendMode.srcIn,
                    child: const Text('Career Navigator',
                      style: TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w900,
                        color: Colors.white, letterSpacing: 0.5)),
                  ),
                  const SizedBox(height: 8),
                  Text('Your Future Starts Here',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 13, letterSpacing: 1.5)),
                ]),
              ),
            ),
          ])),

          // Bottom version
          Positioned(
            bottom: 40, left: 0, right: 0,
            child: FadeTransition(
              opacity: _taglineFade,
              child: Column(children: [
                const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primaryCyan)),
                const SizedBox(height: 16),
                Text('v10.0 · ICT University',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.25),
                    fontSize: 11, letterSpacing: 1)),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  final double size; final Color color; final double opacity;
  const _Orb(this.size, this.color, this.opacity);
  @override
  Widget build(BuildContext context) => Container(
    width: size, height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: color.withOpacity(opacity)),
  );
}
