import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import '../services/token_store.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'sign_in_page.dart';
import 'job_seeker_dashboard.dart';
import 'mentor_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _progressCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<double> _textFadeAnim;
  late Animation<Offset> _textSlideAnim;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));

    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _textFadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeIn));
    _textSlideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
    _progressAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut));

    _logoCtrl.forward().then((_) {
      _textCtrl.forward();
      _progressCtrl.forward();
    });

    Future.delayed(const Duration(seconds: 6), _navigate);
  }

  Future<void> _navigate() async {
    FlutterNativeSplash.remove();
    if (!mounted) return;

    final token = await TokenStore.getAccess();
    if (!mounted) return;

    if (token == null) {
      _go(const SignInPage());
      return;
    }

    try {
      final res = await ApiService.getProfile(token);
      if (!mounted) return;
      if (res['success'] == true) {
        final role = (res['data']['role'] as String?) ?? 'job_seeker';
        if (role == 'mentor') {
          _go(const MentorDashboard());
        } else {
          _go(const JobSeekerDashboard());
        }
      } else {
        await TokenStore.clear();
        _go(const SignInPage());
      }
    } catch (_) {
      _go(const SignInPage());
    }
  }

  void _go(Widget page) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppThemeProvider>();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              image: DecorationImage(
                image: AssetImage(theme.backgroundPath),
                fit: BoxFit.cover,
                opacity: 0.50,
              ),
            ),
          ),
          Container(color: AppColors.darkBackground.withOpacity(0.62)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _fadeAnim,
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryCyan.withOpacity(0.45),
                            blurRadius: 40,
                            spreadRadius: 8,
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
                              Icons.school,
                              color: AppColors.primaryCyan,
                              size: 60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                FadeTransition(
                  opacity: _textFadeAnim,
                  child: SlideTransition(
                    position: _textSlideAnim,
                    child: const Column(
                      children: [
                        Text(
                          'CAREER NAVIGATOR',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Your path to success starts here',
                          style: TextStyle(
                            color: AppColors.primaryCyan,
                            fontSize: 15,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                FadeTransition(
                  opacity: _textFadeAnim,
                  child: SizedBox(
                    width: size.width * 0.55,
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _progressAnim,
                          builder: (_, __) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _progressAnim.value,
                              minHeight: 3,
                              backgroundColor: Colors.white.withOpacity(0.12),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.primaryCyan,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        AnimatedBuilder(
                          animation: _progressAnim,
                          builder: (_, __) => Text(
                            _label(_progressAnim.value),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.45),
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _label(double p) {
    if (p < 0.30) return 'Initializing...';
    if (p < 0.60) return 'Loading your profile...';
    if (p < 0.90) return 'Almost ready...';
    return 'Welcome!';
  }
}
