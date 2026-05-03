import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/theme_provider.dart';

class HelpFaqPage extends StatefulWidget {
  const HelpFaqPage({super.key});

  @override
  State<HelpFaqPage> createState() => _HelpFaqPageState();
}

class _HelpFaqPageState extends State<HelpFaqPage> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'question': 'What is Career Navigator?',
      'answer':
          'Career Navigator is a mobile app designed to help you discover career paths, track your professional goals, and get personalized guidance based on your skills and interests.',
    },
    {
      'question': 'How do I create an account?',
      'answer':
          'Tap "Sign Up" on the welcome screen, enter your name, email address, and a secure password. You will receive a verification email — confirm it to activate your account.',
    },
    {
      'question': 'How do I update my profile information?',
      'answer':
          'Go to Settings → Edit Profile. From there you can update your name, profile photo, bio, skills, and career preferences at any time.',
    },
    {
      'question': 'How do I change my password?',
      'answer':
          'Go to Settings → Change Password. Enter your email to receive a 6-digit reset code, then use that code to set a new password.',
    },
    {
      'question': 'Is my data safe?',
      'answer':
          'Yes. We encrypt all data in transit using TLS and at rest using AES-256. We never sell your personal data. See our Privacy Policy for full details.',
    },
    {
      'question': 'Can I delete my account?',
      'answer':
          'Yes. Go to Settings → Delete Account. This will permanently remove your account and all associated data within 30 days. This action cannot be undone.',
    },
    {
      'question': 'How do I change the app theme?',
      'answer':
          'Go to Settings → Appearance. You can toggle between Dark Mode and Light Mode.',
    },
    {
      'question': 'How do I contact support?',
      'answer':
          'You can reach us via Settings → Send Feedback. Our team typically responds within 5 business days.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Help & FAQ')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
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
                const Icon(
                  Icons.help_outline,
                  color: AppColors.primaryCyan,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Find answers to the most common questions about Career Navigator.',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.65)
                          : AppColors.lightTextSecondary,
                      fontSize: 13,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ...List.generate(_faqs.length, (index) {
            final isExpanded = _expandedIndex == index;
            final faq = _faqs[index];
            return GestureDetector(
              onTap: () =>
                  setState(() => _expandedIndex = isExpanded ? null : index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isExpanded
                      ? AppColors.primaryCyan.withOpacity(0.06)
                      : (isDark
                            ? Colors.white.withOpacity(0.04)
                            : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isExpanded
                        ? AppColors.primaryCyan.withOpacity(0.3)
                        : (isDark
                              ? Colors.white.withOpacity(0.07)
                              : Colors.grey.shade300),
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
                              faq['question']!,
                              style: TextStyle(
                                color: isExpanded
                                    ? AppColors.primaryCyan
                                    : (isDark
                                          ? Colors.white
                                          : AppColors.lightText),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: isExpanded
                                ? AppColors.primaryCyan
                                : (isDark
                                      ? Colors.white.withOpacity(0.5)
                                      : Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    if (isExpanded) ...[
                      Divider(
                        color: AppColors.primaryCyan.withOpacity(0.2),
                        height: 1,
                        indent: 18,
                        endIndent: 18,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
                        child: Text(
                          faq['answer']!,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.55)
                                : AppColors.lightTextSecondary,
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
            child: Row(
              children: [
                Icon(
                  Icons.support_agent_outlined,
                  color: isDark
                      ? Colors.white.withOpacity(0.35)
                      : Colors.grey.shade500,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Still have questions? Use Send Feedback in Settings to reach our team.',
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.4)
                          : AppColors.lightTextSecondary,
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
