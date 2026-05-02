import 'package:flutter/material.dart';

import '../../core/themes/app_theme.dart';

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
          // ── Header card ──────────────────────────────────────
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
                  'Last updated: June 1, 2025\nEffective date: June 1, 2025',
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

          // ── Sections ─────────────────────────────────────────
          _Section(
            number: '01',
            icon: Icons.inventory_2_outlined,
            title: 'Information We Collect',
            children: [
              _Body(
                'When you use Career Navigator, we may collect the following types of information:',
              ),
              _Bullet(
                label: 'Account data',
                text:
                    'Your name, email address, and password when you create an account.',
              ),
              _Bullet(
                label: 'Profile data',
                text:
                    'Career goals, skills, education history, and professional information you choose to provide.',
              ),
              _Bullet(
                label: 'Device information',
                text:
                    'Device model, operating system version, unique device identifiers, and crash reports.',
              ),
              _Bullet(
                label: 'Usage data',
                text:
                    'Features you interact with, session duration, and in-app actions to help us improve the experience.',
              ),
              _Bullet(
                label: 'Location data',
                text:
                    'Approximate location data, only when you explicitly grant permission.',
              ),
              _Highlight(
                'We do not collect information from children under the age of 13. '
                'If we discover that such data has been collected, it will be deleted immediately.',
              ),
            ],
          ),

          _Section(
            number: '02',
            icon: Icons.settings_outlined,
            title: 'How We Use Your Data',
            children: [
              _Body(
                'We use your data solely to operate and improve Career Navigator. Specifically, we use it to:',
              ),
              _Bullet(
                text:
                    'Authenticate your identity and manage your account securely.',
              ),
              _Bullet(
                text:
                    'Personalize career recommendations, job matches, and in-app content.',
              ),
              _Bullet(
                text:
                    'Send transactional notifications, security alerts, and important product updates.',
              ),
              _Bullet(
                text:
                    'Analyze usage patterns to improve app performance, stability, and features.',
              ),
              _Bullet(
                text:
                    'Detect, investigate, and prevent fraudulent or unauthorized activity.',
              ),
              _Bullet(text: 'Comply with applicable legal obligations.'),
              _Body(
                'We do not use your data for advertising purposes without your explicit, '
                'informed consent. You can withdraw consent at any time from app settings.',
              ),
            ],
          ),

          _Section(
            number: '03',
            icon: Icons.link_outlined,
            title: 'Data Sharing & Disclosure',
            children: [
              _Body(
                'We do not sell, trade, or rent your personal data. We may share it only in the following limited circumstances:',
              ),
              _Bullet(
                label: 'Service providers',
                text:
                    'Trusted third-party vendors who assist us in operating the app (e.g. cloud hosting, analytics). '
                    'All are bound by confidentiality agreements and may not use your data for their own purposes.',
              ),
              _Bullet(
                label: 'Legal requirements',
                text:
                    'When required by applicable Cameroonian law, regulation, or enforceable governmental request.',
              ),
              _Bullet(
                label: 'Safety & protection',
                text:
                    'When disclosure is necessary to protect the rights, property, or safety of our team, users, or the public.',
              ),
              _Bullet(
                label: 'Business transfers',
                text:
                    'In the event of a merger or acquisition, your data may be transferred. '
                    'We will notify you before your data becomes subject to a different privacy policy.',
              ),
              _Highlight(
                'Our source code and project are maintained openly on GitHub. No personal user data is '
                'ever committed or exposed in our public repositories.',
              ),
            ],
          ),

          _Section(
            number: '04',
            icon: Icons.lock_outline,
            title: 'Data Retention & Security',
            children: [
              _Body(
                'We retain your personal data for as long as your account is active or as needed to deliver our services. '
                'When you delete your account, we will delete or anonymize your data within 30 days, '
                'unless we are legally required to retain certain records.',
              ),
              _Body(
                'We implement industry-standard security measures including:',
              ),
              _Bullet(
                text:
                    'Encryption of data in transit (TLS) and at rest (AES-256).',
              ),
              _Bullet(
                text:
                    'Secure authentication, token management, and session expiry controls.',
              ),
              _Bullet(
                text:
                    'Regular security reviews and access controls — only authorized personnel can access personal data.',
              ),
              _Body(
                'No method of electronic transmission is 100% secure. While we take every reasonable precaution, '
                'we encourage you to use a strong, unique password for your account.',
              ),
            ],
          ),

          _Section(
            number: '05',
            icon: Icons.tune_outlined,
            title: 'Your Rights',
            children: [
              _Body(
                'In accordance with applicable law, including Cameroonian data protection regulations, '
                'you have the following rights regarding your personal data:',
              ),
              _Bullet(
                label: 'Access',
                text: 'Request a copy of the personal data we hold about you.',
              ),
              _Bullet(
                label: 'Correction',
                text: 'Request correction of inaccurate or incomplete data.',
              ),
              _Bullet(
                label: 'Deletion',
                text:
                    'Request deletion of your personal data ("right to be forgotten"), subject to legal exceptions.',
              ),
              _Bullet(
                label: 'Portability',
                text:
                    'Request your data in a structured, machine-readable format.',
              ),
              _Bullet(
                label: 'Objection',
                text:
                    'Object to processing of your data for certain purposes such as marketing.',
              ),
              _Bullet(
                label: 'Withdraw consent',
                text:
                    'Where processing is based on your consent, you may withdraw it at any time without affecting prior processing.',
              ),
              _Body(
                'To exercise any of these rights, contact us using the details in section 08. '
                'We will respond to all verified requests within 30 days.',
              ),
            ],
          ),

          _Section(
            number: '06',
            icon: Icons.cookie_outlined,
            title: 'Cookies & Tracking',
            children: [
              _Body(
                'Our app may use local storage and similar technologies to maintain sessions, '
                'remember your preferences, and gather analytics. These fall into three categories:',
              ),
              _Bullet(
                label: 'Essential',
                text:
                    'Required for the app to function correctly. Cannot be disabled.',
              ),
              _Bullet(
                label: 'Analytics',
                text:
                    'Help us understand how users interact with the app. You can opt out in settings.',
              ),
              _Bullet(
                label: 'Preferences',
                text:
                    'Store your theme and customization choices across sessions.',
              ),
              _Body(
                'You can manage or clear tracking data at any time through your device settings or the app\'s privacy settings menu.',
              ),
            ],
          ),

          _Section(
            number: '07',
            icon: Icons.sync_alt_outlined,
            title: 'Changes to This Policy',
            children: [
              _Body(
                'We may update this Privacy Policy from time to time to reflect changes in our practices, '
                'technology, or legal requirements. When we make significant changes, we will notify you via:',
              ),
              _Bullet(
                text:
                    'An in-app notification or banner when you next open the app.',
              ),
              _Bullet(
                text: 'An email to the address associated with your account.',
              ),
              _Body(
                'The "Last updated" date at the top of this page reflects the most recent revision. '
                'Your continued use of the app after changes constitutes acceptance of the updated policy.',
              ),
            ],
          ),

          _Section(
            number: '08',
            icon: Icons.mail_outline,
            title: 'Contact Us',
            children: [
              _Body(
                'If you have any questions, concerns, or requests regarding this Privacy Policy '
                'or how we handle your data, please reach out:',
              ),
              _Bullet(label: 'GitHub', text: 'github.com/career-navigator'),
              _Bullet(label: 'Country', text: 'Cameroon'),
              _Body(
                'We are committed to resolving any privacy concerns promptly and transparently. '
                'We aim to respond to all privacy-related inquiries within 5 business days.',
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Footer ───────────────────────────────────────────
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
}

// ─────────────────────────────────────────────────────────
// Section card widget
// ─────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _Section({
    required this.number,
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
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
}

// ─────────────────────────────────────────────────────────
// Body text
// ─────────────────────────────────────────────────────────
class _Body extends StatelessWidget {
  final String text;
  const _Body(this.text);

  @override
  Widget build(BuildContext context) {
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
}

// ─────────────────────────────────────────────────────────
// Bullet point
// ─────────────────────────────────────────────────────────
class _Bullet extends StatelessWidget {
  final String? label;
  final String text;
  const _Bullet({this.label, required this.text});

  @override
  Widget build(BuildContext context) {
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
}

// ─────────────────────────────────────────────────────────
// Highlight / callout box
// ─────────────────────────────────────────────────────────
class _Highlight extends StatelessWidget {
  final String text;
  const _Highlight(this.text);

  @override
  Widget build(BuildContext context) {
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
