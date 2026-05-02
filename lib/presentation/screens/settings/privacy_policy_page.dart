import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/theme_provider.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 20),
          _buildSection('01', Icons.inventory_2_outlined, 'Information We Collect', [
            'When you use Career Navigator, we may collect the following types of information:',
            '• Account data: Your name, email address, and password when you create an account.',
            '• Profile data: Career goals, skills, education history, and professional information you choose to provide.',
            '• Device information: Device model, operating system version, unique device identifiers, and crash reports.',
            '• Usage data: Features you interact with, session duration, and in-app actions.',
            '• Location data: Approximate location data, only when you explicitly grant permission.',
          ], isDark),
          _buildSection('02', Icons.settings_outlined, 'How We Use Your Data', [
            'We use your data solely to operate and improve Career Navigator:',
            '• Authenticate your identity and manage your account securely.',
            '• Personalize career recommendations, job matches, and in-app content.',
            '• Send transactional notifications, security alerts, and important product updates.',
            '• Analyze usage patterns to improve app performance and features.',
            '• Detect, investigate, and prevent fraudulent or unauthorized activity.',
          ], isDark),
          _buildSection('03', Icons.link_outlined, 'Data Sharing & Disclosure', [
            'We do not sell, trade, or rent your personal data. We may share it only in limited circumstances:',
            '• Service providers: Trusted third-party vendors who assist us in operating the app.',
            '• Legal requirements: When required by applicable law or enforceable governmental request.',
            '• Safety & protection: To protect the rights, property, or safety of our team, users, or the public.',
            '• Business transfers: In the event of a merger or acquisition, your data may be transferred.',
          ], isDark),
          _buildSection('04', Icons.lock_outline, 'Data Retention & Security', [
            'We retain your personal data for as long as your account is active. When you delete your account, we will delete or anonymize your data within 30 days.',
            'We implement industry-standard security measures including:',
            '• Encryption of data in transit (TLS) and at rest (AES-256).',
            '• Secure authentication, token management, and session expiry controls.',
            '• Regular security reviews and access controls.',
          ], isDark),
          _buildSection('05', Icons.tune_outlined, 'Your Rights', [
            'In accordance with applicable law, you have the following rights:',
            '• Access: Request a copy of the personal data we hold about you.',
            '• Correction: Request correction of inaccurate or incomplete data.',
            '• Deletion: Request deletion of your personal data ("right to be forgotten").',
            '• Portability: Request your data in a structured, machine-readable format.',
            '• Objection: Object to processing of your data for certain purposes.',
            '• Withdraw consent: Withdraw your consent at any time.',
          ], isDark),
          _buildSection('06', Icons.mail_outline, 'Contact Us', [
            'If you have any questions or concerns regarding this Privacy Policy, please reach out:',
            '• GitHub: github.com/career-navigator',
            '• Country: Cameroon',
          ], isDark),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              'By using Career Navigator, you acknowledge that you have read and understood this Privacy Policy and agree to its terms.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.35)
                    : AppColors.lightTextSecondary,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.primaryCyan,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Career Navigator',
                style: TextStyle(
                  color: AppColors.primaryCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Last updated: June 1, 2025\nEffective date: June 1, 2025',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.45)
                  : AppColors.lightTextSecondary,
              fontSize: 12,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'This Privacy Policy explains how Career Navigator collects, uses, shares, and protects your personal information when you use our mobile application.',
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.65)
                  : AppColors.lightTextSecondary,
              fontSize: 13,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String number,
    IconData icon,
    String title,
    List<String> content,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryCyan, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                number,
                style: TextStyle(
                  color: AppColors.primaryCyan.withOpacity(0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.grey.shade300,
            height: 1,
          ),
          const SizedBox(height: 12),
          ...content.map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                text,
                style: TextStyle(
                  color: isDark
                      ? (text.startsWith('•')
                            ? Colors.white.withOpacity(0.55)
                            : Colors.white.withOpacity(0.65))
                      : (text.startsWith('•')
                            ? AppColors.lightTextSecondary
                            : Colors.grey.shade700),
                  fontSize: 13,
                  height: 1.65,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
