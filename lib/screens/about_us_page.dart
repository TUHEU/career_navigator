import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────
// Developer data model
// ─────────────────────────────────────────────────────────
class Developer {
  final String name;
  final String role;
  final String github;
  final String linkedin;
  final String imagePath; // asset path e.g. assets/team/dev1.jpg
  final String description;

  const Developer({
    required this.name,
    required this.role,
    required this.github,
    required this.linkedin,
    required this.imagePath,
    required this.description,
  });
}

// ── Fill in your real team details here ──────────────────
const List<Developer> kDevelopers = [
  Developer(
    name: 'Developer 1',
    role: 'Lead Backend Developer',
    github: 'github_username_1',
    linkedin: 'https://linkedin.com/in/developer1',
    imagePath: 'assets/team/dev1.jpg',
    description:
        'Designed and implemented the Flask API, database schema, and authentication system.',
  ),
  Developer(
    name: 'Developer 2',
    role: 'Flutter Developer',
    github: 'github_username_2',
    linkedin: 'https://linkedin.com/in/developer2',
    imagePath: 'assets/team/dev2.jpg',
    description:
        'Built the mobile UI, dashboard screens, and navigation system.',
  ),
  Developer(
    name: 'Developer 3',
    role: 'UI/UX Designer & Flutter Developer',
    github: 'github_username_3',
    linkedin: 'https://linkedin.com/in/developer3',
    imagePath: 'assets/team/dev3.jpg',
    description:
        'Created the design system, theming engine, and all screen layouts.',
  ),
  Developer(
    name: 'Developer 4',
    role: 'Database Architect',
    github: 'github_username_4',
    linkedin: 'https://linkedin.com/in/developer4',
    imagePath: 'assets/team/dev4.jpg',
    description:
        'Designed the MySQL schema, indexing strategy, and chat/notification tables.',
  ),
  Developer(
    name: 'Developer 5',
    role: 'DevOps & Systems Engineer',
    github: 'github_username_5',
    linkedin: 'https://linkedin.com/in/developer5',
    imagePath: 'assets/team/dev5.jpg',
    description:
        'Deployed the backend on Contabo VPS, configured PM2, and managed server security.',
  ),
];

// ─────────────────────────────────────────────────────────
// About Us Page
// ─────────────────────────────────────────────────────────
class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('About Us', style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // App intro card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryCyan.withOpacity(0.15),
                  AppColors.darkCard.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryCyan.withOpacity(0.25),
              ),
            ),
            child: Column(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/logo/logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.primaryCyan.withOpacity(0.2),
                      child: const Icon(
                        Icons.school,
                        color: AppColors.primaryCyan,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Career Navigator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Version 2.0',
                  style: TextStyle(color: AppColors.primaryCyan, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Text(
                  'Career Navigator connects ambitious job seekers with experienced mentors. '
                  'Our platform enables personalized career guidance, skill development, '
                  'and professional networking — all in one place.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Meet the Team',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'The developers behind Career Navigator',
            style: TextStyle(
              color: Colors.white.withOpacity(0.45),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          ...kDevelopers.map((dev) => _DeveloperCard(dev: dev)),

          const SizedBox(height: 32),

          // Tech stack
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tech Stack',
                  style: TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
                            (t) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryCyan.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.primaryCyan.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                t,
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
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// Developer Card Widget
// ─────────────────────────────────────────────────────────
class _DeveloperCard extends StatelessWidget {
  final Developer dev;
  const _DeveloperCard({required this.dev});

  Future<void> _launch(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
            backgroundImage: AssetImage(dev.imagePath),
            onBackgroundImageError: (_, __) {},
            child: Text(
              dev.name.isNotEmpty ? dev.name[0] : '?',
              style: const TextStyle(
                color: AppColors.primaryCyan,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dev.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dev.role,
                  style: const TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dev.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // GitHub
                    GestureDetector(
                      onTap: () => _launch('https://github.com/${dev.github}'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.12),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.code,
                              color: Colors.white.withOpacity(0.7),
                              size: 14,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              dev.github,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // LinkedIn
                    GestureDetector(
                      onTap: () => _launch(dev.linkedin),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0077B5).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF0077B5).withOpacity(0.4),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.link,
                              color: Color(0xFF0077B5),
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'LinkedIn',
                              style: TextStyle(
                                color: Color(0xFF0077B5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
