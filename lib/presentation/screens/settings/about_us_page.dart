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
  // FIX: added networkImageUrl so photos can be loaded from the internet
  // when the local asset is missing. Set to '' to use initials only.
  final String networkImageUrl;
  final String imagePath; // kept for backwards compat (local asset)
  final String description;

  const Developer({
    required this.name,
    required this.role,
    required this.github,
    this.email,
    required this.linkedin,
    required this.imagePath,
    this.networkImageUrl = '',
    required this.description,
  });
}

const List<Developer> kDevelopers = [
  Developer(
    name: 'Tuheu Tchoubi Pempeme Moussa Fahdil',
    role: 'Lead Backend Developer & Database Architect',
    github: 'TUHEU',
    email: 'tuheu.moussa@ictuniversity.edu.cm',
    linkedin: 'https://www.linkedin.com/in/nadal-junior-63b5933a3/',
    imagePath: 'assets/team/dev1.png',
    // Replace with your actual LinkedIn/GitHub avatar URL:
    networkImageUrl: 'https://avatars.githubusercontent.com/TUHEU',
    description:
        'Designed and implemented the Flask API, database schema, authentication system, and job listing module.',
  ),
  Developer(
    name: 'Yuyar Lea-Barbara',
    role: 'Lead Flutter Developer',
    github: 'techgirl911',
    email: 'yuyarbongkem@gmail.com',
    linkedin: 'https://www.linkedin.com/in/yuyar-bongkem-71bb10345/',
    imagePath: 'assets/team/dev2.png',
    networkImageUrl: 'https://avatars.githubusercontent.com/techgirl911',
    description:
        'Built the mobile UI, dashboard screens, navigation system, and chat integration.',
  ),
  Developer(
    name: 'NDZEKA GETRUDE BERINYUY',
    role: 'UI/UX Designer & Frontend Developer',
    github: 'getrudepink9-design',
    email: 'getrudepink@gmail.com',
    linkedin: 'https://www.linkedin.com/in/getrude-pink-b51747339',
    imagePath: 'assets/team/dev3.png',
    networkImageUrl:
        'https://avatars.githubusercontent.com/getrudepink9-design',
    description:
        'Created the design system, theming engine, and all screen layouts with responsive design.',
  ),
  Developer(
    name: 'Ayukeyong Dohbila Nyamndi Benjunior',
    role: 'DevOps & Security Engineer',
    github: 'AyuknyamndiICTU',
    email: 'david.okonkwo@careernavigator.com',
    linkedin:
        'https://www.linkedin.com/in/ayukeyong-nyamndi-a74176227/?utm_source=share_via&utm_content=profile&utm_medium=member_android',
    imagePath: 'assets/team/dev4.png',
    networkImageUrl: 'https://avatars.githubusercontent.com/AyuknyamndiICTU',
    description:
        'Deployed the backend on Contabo VPS, configured PM2, managed server security, and CI/CD pipelines.',
  ),
  Developer(
    name: 'MBOCK LOWE Gloria Laetitia',
    role: 'Quality Assurance & Product Manager',
    github: 'Laetitia-ml',
    email: 'bnyamndi@gmail.com',
    linkedin:
        'https://www.linkedin.com/in/gloria-laetitia-b3b3b0378/?skipRedirect=true',
    imagePath: 'assets/team/dev5.png',
    networkImageUrl: 'https://avatars.githubusercontent.com/Laetitia-ml',
    description:
        'Manages testing, user acceptance, and coordinates feature releases across the team.',
  ),
];

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final fullUrl = url.startsWith('http') ? url : 'https://$url';
    final uri = Uri.tryParse(fullUrl);
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open: $fullUrl')));
    }
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    final uri = Uri.parse('mailto:$email?subject=Career%20Navigator%20Inquiry');
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open email app for: $email')),
      );
    }
  }

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
                    ? Colors.white.withValues(alpha: 0.45)
                    : AppColors.lightTextSecondary,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ...kDevelopers.map(
              (dev) => _DeveloperCard(
                dev: dev,
                isDark: isDark,
                onLaunchUrl: (url) => _launchUrl(context, url),
                onSendEmail: (email) => _sendEmail(context, email),
              ),
            ),
            const SizedBox(height: 32),
            _buildTechStackCard(isDark),
            const SizedBox(height: 24),
            Text(
              '© 2026 Career Navigator. All rights reserved.',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.lightTextSecondary.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 16),
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
            AppColors.primaryCyan.withValues(alpha: 0.15),
            isDark ? AppColors.darkCard.withValues(alpha: 0.8) : Colors.grey.shade100,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primaryCyan.withValues(alpha: 0.25)),
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
                  color: AppColors.primaryCyan.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/logo/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: AppColors.primaryCyan.withValues(alpha: 0.2),
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
              color: AppColors.primaryCyan.withValues(alpha: 0.15),
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
                  ? Colors.white.withValues(alpha: 0.65)
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
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade300,
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
                  color: AppColors.primaryCyan.withValues(alpha: 0.1),
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
                      'Cloudinary',
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
                          color: AppColors.primaryCyan.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.primaryCyan.withValues(alpha: 0.25),
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
                ? Colors.white.withValues(alpha: 0.08)
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
                  color: isDark ? Colors.white70 : AppColors.lightTextSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Developer Card
// ─────────────────────────────────────────────────────────────────────────────

class _DeveloperCard extends StatelessWidget {
  final Developer dev;
  final bool isDark;
  final Function(String) onLaunchUrl;
  final Function(String) onSendEmail;

  const _DeveloperCard({
    required this.dev,
    required this.isDark,
    required this.onLaunchUrl,
    required this.onSendEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dev.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
                    color: AppColors.primaryCyan.withValues(alpha: 0.12),
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
                        ? Colors.white.withValues(alpha: 0.55)
                        : AppColors.lightTextSecondary,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    _buildSocialButton(
                      icon: Icons.code,
                      label: 'GitHub',
                      color: isDark ? Colors.white : AppColors.lightText,
                      onTap: () =>
                          onLaunchUrl('https://github.com/${dev.github}'),
                    ),
                    if (dev.email != null)
                      _buildSocialButton(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        color: Colors.redAccent,
                        onTap: () => onSendEmail(dev.email!),
                      ),
                    _buildSocialButton(
                      icon: Icons.link,
                      label: 'LinkedIn',
                      color: const Color(0xFF0077B5),
                      onTap: () => onLaunchUrl(dev.linkedin),
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

  /// FIX: tries network URL first, then local asset, then initials fallback
  Widget _buildAvatar() {
    // Priority 1: network image URL (GitHub avatar or custom URL)
    if (dev.networkImageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          dev.networkImageUrl,
          width: 70,
          height: 70,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _initialsCircle();
          },
          errorBuilder: (_, _, _) => _localAssetOrInitials(),
        ),
      );
    }
    // Priority 2: local asset image
    return _localAssetOrInitials();
  }

  Widget _localAssetOrInitials() {
    return ClipOval(
      child: Image.asset(
        dev.imagePath,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _initialsCircle(),
      ),
    );
  }

  Widget _initialsCircle() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryCyan.withValues(alpha: 0.2),
      ),
      alignment: Alignment.center,
      child: Text(
        Helpers.getInitials(dev.name),
        style: const TextStyle(
          color: AppColors.primaryCyan,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
