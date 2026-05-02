import 'package:flutter/material.dart';

import '../core/themes/app_theme.dart';

class HelpFaqPage extends StatefulWidget {
  const HelpFaqPage({super.key});

  @override
  State<HelpFaqPage> createState() => _HelpFaqPageState();
}

class _HelpFaqPageState extends State<HelpFaqPage> {
  final List<_FaqItem> _faqs = [
    _FaqItem(
      question: 'What is Career Navigator?',
      answer:
          'Career Navigator is a mobile app designed to help you discover career paths, '
          'track your professional goals, and get personalized guidance based on your skills and interests.',
    ),
    _FaqItem(
      question: 'How do I create an account?',
      answer:
          'Tap "Sign Up" on the welcome screen, enter your name, email address, and a secure password. '
          'You will receive a verification email — confirm it to activate your account.',
    ),
    _FaqItem(
      question: 'How do I update my profile information?',
      answer:
          'Go to Settings → Edit Profile. From there you can update your name, profile photo, '
          'bio, skills, and career preferences at any time.',
    ),
    _FaqItem(
      question: 'How do I change my password?',
      answer:
          'Go to Settings → Change Password. Enter your email to receive a 6-digit reset code, '
          'then use that code to set a new password.',
    ),
    _FaqItem(
      question: 'Is my data safe?',
      answer:
          'Yes. We encrypt all data in transit using TLS and at rest using AES-256. '
          'We never sell your personal data. See our Privacy Policy for full details.',
    ),
    _FaqItem(
      question: 'Can I delete my account?',
      answer:
          'Yes. Go to Settings → Delete Account. This will permanently remove your account '
          'and all associated data within 30 days. This action cannot be undone.',
    ),
    _FaqItem(
      question: 'How do I change the app theme?',
      answer:
          'Go to Settings → App Theme. You can choose from the available background themes '
          'and the change will apply immediately across the app.',
    ),
    _FaqItem(
      question: 'What should I do if the app crashes?',
      answer:
          'Try force-closing and reopening the app. If the issue persists, uninstall and reinstall it. '
          'You can also send us a report via Settings → Send Feedback so we can investigate.',
    ),
    _FaqItem(
      question: 'How do I contact support?',
      answer:
          'You can reach us via Settings → Send Feedback. Our team typically responds '
          'within 5 business days.',
    ),
  ];

  int? _openIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Help & FAQ',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          // ── Header ──────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryCyan.withOpacity(0.25),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: AppColors.primaryCyan,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Find answers to the most common questions about Career Navigator.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── FAQ items ────────────────────────────────────
          ...List.generate(_faqs.length, (i) {
            final faq = _faqs[i];
            final isOpen = _openIndex == i;

            return GestureDetector(
              onTap: () => setState(() => _openIndex = isOpen ? null : i),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isOpen
                      ? AppColors.primaryCyan.withOpacity(0.06)
                      : Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isOpen
                        ? AppColors.primaryCyan.withOpacity(0.3)
                        : Colors.white.withOpacity(0.07),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 15,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              faq.question,
                              style: TextStyle(
                                color: isOpen
                                    ? AppColors.primaryCyan
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          AnimatedRotation(
                            turns: isOpen ? 0.25 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              Icons.chevron_right,
                              color: isOpen
                                  ? AppColors.primaryCyan
                                  : Colors.white.withOpacity(0.25),
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isOpen) ...[
                      Divider(
                        color: AppColors.primaryCyan.withOpacity(0.2),
                        height: 1,
                        indent: 18,
                        endIndent: 18,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                        child: Text(
                          faq.answer,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 13,
                            height: 1.7,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 10),

          // ── Still need help ──────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.07)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.support_agent_outlined,
                  color: Colors.white.withOpacity(0.35),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Still have questions? Use Send Feedback in Settings to reach our team.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 12.5,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});
}
