import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import 'sign_in_page.dart';
import '../dashboard/job_seeker_dashboard.dart';
import '../dashboard/mentor_dashboard.dart';
import '../dashboard/admin_dashboard.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    FlutterNativeSplash.remove();
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final hasToken = await authProvider.getAccessToken() != null;

    if (hasToken) {
      await authProvider.loadUserProfile();
      if (!mounted) return;

      final user = authProvider.currentUser;
      if (user?.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else if (user?.role == 'mentor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MentorDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const JobSeekerDashboard()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
      );
    }
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
            image: AssetImage(themeProvider.backgroundPath),
            fit: BoxFit.cover,
            opacity: 0.35,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
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
              const SizedBox(height: 32),
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
        ),
      ),
    );
  }
}
