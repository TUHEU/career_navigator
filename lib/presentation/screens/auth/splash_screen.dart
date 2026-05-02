import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/auth_provider.dart';
import 'sign_in_page.dart';
import '../dashboard/job_seeker_dashboard.dart';
import '../dashboard/mentor_dashboard.dart';
import '../dashboard/admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  late Animation<Offset> _textSlideAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _navigate();
  }

  void _initAnimations() {
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
    _logoCtrl.forward();
  }

  Future<void> _navigate() async {
    FlutterNativeSplash.remove();
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final isAuthenticated = await authProvider.isAuthenticated;

    if (isAuthenticated) {
      await authProvider.loadUserProfile();
      if (!mounted) return;

      final user = authProvider.currentUser;
      if (user?.role == 'admin') {
        _navigateTo(const AdminDashboard());
      } else if (user?.role == 'mentor') {
        _navigateTo(const MentorDashboard());
      } else {
        _navigateTo(const JobSeekerDashboard());
      }
    } else {
      _navigateTo(const SignInPage());
    }
  }

  void _navigateTo(Widget page) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          image: DecorationImage(
            image: AssetImage(
              isDark
                  ? 'assets/background/bg8.png'
                  : 'assets/background/bg6.png',
            ),
            fit: BoxFit.cover,
            opacity: 0.35,
          ),
        ),
        child: Center(
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
              Column(
                children: [
                  Text(
                    'CAREER NAVIGATOR',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.lightText,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Your path to success starts here',
                    style: TextStyle(
                      color: AppColors.primaryCyan,
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
