import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/theme_provider.dart';

class Developer {
  final String name;
  final String role;
  final String github;
  final String? email;
  final String linkedin;
  final String imagePath;
  final String description;

  const Developer({
    required this.name,
    required this.role,
    required this.github,
    this.email,
    required this.linkedin,
    required this.imagePath,
    required this.description,
  });
}

const List<Developer> kDevelopers = [
  Developer(
    name: 'Tuheu Tchoubi Pempeme Moussa Fahdil',
    role: 'Lead Backend Developer & Database Architect',
    github: 'TUHEU',
    email: 'tuheu.moussa@ictuniversity.edu.cm',
    linkedin: 'https://www.linkedin.com/in/fahdil-tuheu/',
    imagePath: 'assets/team/dev1.png',
    description:
        'Designed and implemented the Flask API, database schema, authentication system, and job listing module.',
  ),
  Developer(
    name: 'Sarah Johnson',
    role: 'Lead Flutter Developer',
    github: 'sarah_dev',
    email: 'sarah.johnson@careernavigator.com',
    linkedin: 'https://linkedin.com/in/sarah-johnson',
    imagePath: 'assets/team/dev2.png',
    description:
        'Built the mobile UI, dashboard screens, navigation system, and chat integration.',
  ),
  Developer(
    name: 'Michael Chen',
    role: 'UI/UX Designer & Frontend Developer',
    github: 'mike_chen',
    email: 'michael.chen@careernavigator.com',
    linkedin: 'https://linkedin.com/in/michael-chen',
    imagePath: 'assets/team/dev3.png',
    description:
        'Created the design system, theming engine, and all screen layouts with responsive design.',
  ),
  Developer(
    name: 'David Okonkwo',
    role: 'DevOps & Security Engineer',
    github: 'david_okonkwo',
    email: 'david.okonkwo@careernavigator.com',
    linkedin: 'https://linkedin.com/in/david-okonkwo',
    imagePath: 'assets/team/dev4.png',
    description:
        'Deployed the backend on Contabo VPS, configured PM2, managed server security, and CI/CD pipelines.',
  ),
  Developer(
    name: 'Emma Rodriguez',
    role: 'Quality Assurance & Product Manager',
    github: 'emma_qa',
    email: 'emma.rodriguez@careernavigator.com',
    linkedin: 'https://linkedin.com/in/emma-rodriguez',
    imagePath: 'assets/team/dev5.png',
    description:
        'Manages testing, user acceptance, and coordinates feature releases across the team.',
  ),
];

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
      appBar: AppBar(title: const Text('About Us'), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAppIntroCard(isDark),
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
                    : AppColors.lightTextSecondary.withOpacity(0.7),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...kDevelopers.map(
              (dev) => _DeveloperCard(dev: dev, isDark: isDark),
            ),
            const SizedBox(height: 32),
            _buildTechStackCard(isDark),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '© 2025 Career Navigator. All rights reserved.',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.25)
                      : AppColors.lightTextSecondary.withOpacity(0.5),
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIntroCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryCyan.withOpacity(0.15),
            isDark ? AppColors.darkCard.withOpacity(0.8) : Colors.grey.shade100,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                width: 90,
                height: 90,
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
              color: isDark ? Colors.white : AppColors.lightText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
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
            'Career Navigator connects ambitious job seekers with experienced mentors. '
            'Our platform enables personalized career guidance, skill development, '
            'and professional networking — all in one place.',
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

  Widget _buildTechStackCard(bool isDark) {
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
            children: [
              _buildTechChip('Flutter', Icons.mobile_friendly, isDark),
              _buildTechChip('Dart', Icons.code, isDark),
              _buildTechChip('Python', Icons.terminal, isDark),
              _buildTechChip('Flask', Icons.science, isDark),
              _buildTechChip('MySQL', Icons.storage, isDark),
              _buildTechChip('JWT', Icons.security, isDark),
              _buildTechChip('Brevo', Icons.email, isDark),
              _buildTechChip('PM2', Icons.settings, isDark),
              _buildTechChip('Contabo VPS', Icons.cloud, isDark),
            ],
          ),
          const SizedBox(height: 16),
          Divider(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              Text(
                'Fully open source | Continuous updates',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.4)
                      : AppColors.lightTextSecondary.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechChip(String label, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primaryCyan, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryCyan,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeveloperCard extends StatelessWidget {
  final Developer dev;
  final bool isDark;

  const _DeveloperCard({required this.dev, required this.isDark});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse('mailto:$email?subject=Career%20Navigator%20Inquiry');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
              backgroundImage: AssetImage(dev.imagePath),
              onBackgroundImageError: (_, __) {},
              child: dev.imagePath.isEmpty
                  ? Text(
                      dev.name.isNotEmpty ? dev.name[0] : '?',
                      style: const TextStyle(
                        color: AppColors.primaryCyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dev.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                    dev.role,
                    style: const TextStyle(
                      color: AppColors.primaryCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dev.description,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.55)
                        : AppColors.lightTextSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildSocialButton(
                      icon: Icons.code,
                      label: 'GitHub',
                      color: isDark ? Colors.white : AppColors.lightText,
                      onTap: () =>
                          _launchUrl('https://github.com/${dev.github}'),
                      isDark: isDark,
                    ),
                    if (dev.email != null)
                      _buildSocialButton(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        color: Colors.redAccent,
                        onTap: () => _sendEmail(dev.email!),
                        isDark: isDark,
                      ),
                    _buildSocialButton(
                      icon: Icons.link,
                      label: 'LinkedIn',
                      color: const Color(0xFF0077B5),
                      onTap: () => _launchUrl(dev.linkedin),
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
