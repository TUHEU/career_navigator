import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/buttons.dart';

class SendFeedbackPage extends StatefulWidget {
  const SendFeedbackPage({super.key});

  @override
  State<SendFeedbackPage> createState() => _SendFeedbackPageState();
}

class _SendFeedbackPageState extends State<SendFeedbackPage> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final ApiService _apiService = ApiService();

  String _selectedCategory = 'General';
  int _rating = 0;
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  final List<String> _categories = [
    'General',
    'Bug Report',
    'Feature Request',
    'Account Issue',
    'Other',
  ];

  Future<void> _submitFeedback() async {
    if (_subjectController.text.trim().isEmpty) {
      Helpers.showSnackBar(context, 'Please enter a subject', isError: true);
      return;
    }
    if (_messageController.text.trim().isEmpty) {
      Helpers.showSnackBar(context, 'Please enter a message', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) {
      Helpers.showSnackBar(
        context,
        'Please login to submit feedback',
        isError: true,
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final response = await _apiService.submitFeedback(
      token: token,
      subject: _subjectController.text.trim(),
      message: _messageController.text.trim(),
      category: _selectedCategory,
      rating: _rating > 0 ? _rating : null,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (response['success'] == true) {
        setState(() => _isSubmitted = true);
      } else {
        Helpers.showSnackBar(
          context,
          response['message'] ?? 'Failed to submit feedback',
          isError: true,
        );
      }
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
      appBar: AppBar(title: const Text('Send Feedback')),
      body: _isSubmitted ? _buildSuccessScreen(isDark) : _buildForm(isDark),
    );
  }

  Widget _buildSuccessScreen(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryCyan.withOpacity(0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryCyan.withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.primaryCyan,
                size: 36,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Thank you!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your feedback has been received. Our team will review it and get back to you within 5 business days if needed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.5)
                    : AppColors.lightTextSecondary,
                fontSize: 14,
                height: 1.65,
              ),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              text: 'Back to Settings',
              onPressed: () => Navigator.pop(context),
              isFullWidth: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primaryCyan.withOpacity(0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.feedback_outlined,
                  color: AppColors.primaryCyan,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We read every message. Your feedback helps us build a better Career Navigator.',
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
          const SizedBox(height: 24),
          Text(
            'How would you rate your experience?',
            style: const TextStyle(
              color: AppColors.primaryCyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _rating = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    i < _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: i < _rating
                        ? AppColors.primaryCyan
                        : (isDark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.shade400),
                    size: 34,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Category',
            style: const TextStyle(
              color: AppColors.primaryCyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryCyan.withOpacity(0.15)
                        : (isDark
                              ? Colors.white.withOpacity(0.04)
                              : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryCyan.withOpacity(0.5)
                          : (isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.grey.shade300),
                    ),
                  ),
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primaryCyan
                          : (isDark
                                ? Colors.white.withOpacity(0.55)
                                : Colors.grey.shade600),
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text(
            'Subject',
            style: const TextStyle(
              color: AppColors.primaryCyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _subjectController,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.lightText,
              fontSize: 14,
            ),
            decoration: _inputDecoration('e.g. App suggestion...', isDark),
          ),
          const SizedBox(height: 20),
          Text(
            'Message',
            style: const TextStyle(
              color: AppColors.primaryCyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.lightText,
              fontSize: 14,
            ),
            maxLines: 6,
            decoration: _inputDecoration(
              'Describe your experience in detail...',
              isDark,
            ),
          ),
          const SizedBox(height: 32),
          PrimaryButton(
            text: 'SUBMIT FEEDBACK',
            onPressed: _submitFeedback,
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, bool isDark) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      color: isDark ? Colors.white.withOpacity(0.25) : Colors.grey.shade500,
      fontSize: 13,
    ),
    filled: true,
    fillColor: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade300,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.primaryCyan, width: 1.5),
    ),
  );
}
