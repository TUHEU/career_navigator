import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/theme_provider.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(title: const Text('About Us')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 32),
            Text(
              'Meet the Team',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'The passionate developers behind Career Navigator',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.45)
                    : AppColors.lightTextSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildDeveloperCard(
              'Tuheu Tchoubi Pempeme Moussa Fahdil',
              'Lead Backend Developer & Database Architect',
              'assets/team/dev1.png',
              'Designed Flask API, database schema, authentication, and job module.',
              isDark,
            ),
            _buildDeveloperCard(
              'Sarah Johnson',
              'Lead Flutter Developer',
              'assets/team/dev2.png',
              'Built mobile UI, dashboard screens, navigation, and chat integration.',
              isDark,
            ),
            _buildDeveloperCard(
              'Michael Chen',
              'UI/UX Designer & Frontend Developer',
              'assets/team/dev3.png',
              'Created design system, theming engine, and responsive layouts.',
              isDark,
            ),
            _buildDeveloperCard(
              'David Okonkwo',
              'DevOps & Security Engineer',
              'assets/team/dev4.png',
              'Deployed backend on VPS, configured PM2, managed security and CI/CD.',
              isDark,
            ),
            _buildDeveloperCard(
              'Emma Rodriguez',
              'Quality Assurance & Product Manager',
              'assets/team/dev5.png',
              'Manages testing, user acceptance, and coordinates feature releases.',
              isDark,
            ),
            const SizedBox(height: 32),
            _buildTechStack(isDark),
            const SizedBox(height: 24),
            Text(
              '© 2025 Career Navigator. All rights reserved.',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.25)
                    : Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryCyan.withOpacity(0.15),
            isDark ? AppColors.darkCard.withOpacity(0.8) : Colors.grey.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCyan.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 4,
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
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Career Navigator',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.lightText,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Version 2.0.0',
              style: TextStyle(
                color: AppColors.primaryCyan,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Career Navigator connects ambitious job seekers with experienced mentors. Our platform enables personalized career guidance, skill development, and professional networking — all in one place.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.65)
                  : AppColors.lightTextSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeveloperCard(
    String name,
    String role,
    String imagePath,
    String description,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
            backgroundImage: AssetImage(imagePath),
            onBackgroundImageError: (_, __) {},
            child: Text(
              Helpers.getInitials(name),
              style: const TextStyle(
                color: AppColors.primaryCyan,
                fontWeight: FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    role,
                    style: const TextStyle(
                      color: AppColors.primaryCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.55)
                        : AppColors.lightTextSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStack(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.code,
                  color: AppColors.primaryCyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Tech Stack',
                style: TextStyle(
                  color: AppColors.primaryCyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children:
                [
                      'Flutter',
                      'Dart',
                      'Python',
                      'Flask',
                      'MySQL',
                      'JWT',
                      'Brevo',
                      'PM2',
                      'Contabo VPS',
                    ]
                    .map(
                      (tech) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryCyan.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.primaryCyan.withOpacity(0.25),
                          ),
                        ),
                        child: Text(
                          tech,
                          style: const TextStyle(
                            color: AppColors.primaryCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 16),
          Divider(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Icon(Icons.star, color: Colors.amber, size: 16),
              SizedBox(width: 8),
              Text(
                'Fully open source | Continuous updates',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
