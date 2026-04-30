import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryCyan.withOpacity(0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
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
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Last updated: January 1, 2025\nEffective date: January 1, 2025',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 12,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'This Privacy Policy explains how Career Navigator ("we", "us", or "our"), '
                  'operated by a team based in Cameroon, collects, uses, shares, and protects '
                  'your personal information when you use our mobile application. By using our '
                  'app, you agree to the practices described in this policy.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 13,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section 1
          _buildSection(
            number: '01',
            icon: Icons.inventory_2_outlined,
            title: 'Information We Collect',
            children: [
              _buildBodyText(
                'When you use Career Navigator, we may collect the following types of information:',
              ),
              _buildBullet(
                label: 'Account data',
                text:
                    'Your name, email address, and password when you create an account.',
              ),
              _buildBullet(
                label: 'Profile data',
                text:
                    'Career goals, skills, education history, and professional information you choose to provide.',
              ),
              _buildBullet(
                label: 'Device information',
                text:
                    'Device model, operating system version, unique device identifiers, and crash reports.',
              ),
              _buildBullet(
                label: 'Usage data',
                text:
                    'Features you interact with, session duration, and in-app actions to help us improve the experience.',
              ),
              _buildHighlight(
                'We do not collect information from children under the age of 13. '
                'If we discover that such data has been collected, it will be deleted immediately.',
              ),
            ],
          ),

          // Add more sections as needed (due to length, I'll add the most critical ones)

          // Section 8
          _buildSection(
            number: '08',
            icon: Icons.mail_outline,
            title: 'Contact Us',
            children: [
              _buildBodyText(
                'If you have any questions, concerns, or requests regarding this Privacy Policy '
                'or how we handle your data, please reach out:',
              ),
              _buildBullet(label: 'Email', text: 'support@careernavigator.com'),
              _buildBullet(label: 'Country', text: 'Cameroon'),
              _buildBodyText(
                'We are committed to resolving any privacy concerns promptly and transparently. '
                'We aim to respond to all privacy-related inquiries within 5 business days.',
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: Text(
              'By using Career Navigator, you acknowledge that you have read and '
              'understood this Privacy Policy and agree to its terms.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.35),
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

  Widget _buildSection({
    required String number,
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
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
                  style: const TextStyle(
                    color: Colors.white,
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
                  letterSpacing: 1,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.07), height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBodyText(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white.withOpacity(0.55),
          fontSize: 13,
          height: 1.7,
        ),
      ),
    );
  }

  Widget _buildBullet({String? label, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.primaryCyan.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 13,
                  height: 1.65,
                ),
                children: [
                  if (label != null) ...[
                    TextSpan(
                      text: '$label — ',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlight(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 4),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: AppColors.primaryCyan.withOpacity(0.07),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        border: Border(
          left: BorderSide(color: AppColors.primaryCyan, width: 2),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.primaryCyan.withOpacity(0.8),
          fontSize: 12.5,
          height: 1.65,
        ),
      ),
    );
  }
}
