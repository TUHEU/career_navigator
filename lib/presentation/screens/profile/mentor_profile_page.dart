import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/buttons.dart';
import '../../widgets/shared/inputs.dart';

class MentorProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;

  const MentorProfilePage({super.key, required this.profile});

  @override
  State<MentorProfilePage> createState() => _MentorProfilePageState();
}

class _MentorProfilePageState extends State<MentorProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _headlineController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _yearsController = TextEditingController();
  final _companyController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _expertiseController = TextEditingController();
  final _industriesController = TextEditingController();
  final _styleController = TextEditingController();
  final _priceController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _githubController = TextEditingController();
  final _websiteController = TextEditingController();

  bool _accepting = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final mentorProfile =
        widget.profile['mentor_profile'] as Map<String, dynamic>? ?? {};

    _headlineController.text = mentorProfile['headline'] ?? '';
    _bioController.text = mentorProfile['bio'] ?? '';
    _phoneController.text = mentorProfile['phone'] ?? '';
    _locationController.text = mentorProfile['location'] ?? '';
    _yearsController.text = '${mentorProfile['years_of_experience'] ?? ''}';
    _companyController.text = mentorProfile['current_company'] ?? '';
    _jobTitleController.text = mentorProfile['current_job_title'] ?? '';
    _styleController.text = mentorProfile['mentoring_style'] ?? '';
    _priceController.text = '${mentorProfile['session_price'] ?? '0'}';
    _linkedinController.text = mentorProfile['linkedin_url'] ?? '';
    _githubController.text = mentorProfile['github_url'] ?? '';
    _websiteController.text = mentorProfile['website_url'] ?? '';
    _accepting = mentorProfile['is_accepting_mentees'] != 0;

    final expertise = mentorProfile['expertise_areas'];
    if (expertise is List) {
      _expertiseController.text = expertise.join(', ');
    } else if (expertise is String) {
      _expertiseController.text = expertise;
    }

    final industries = mentorProfile['industries'];
    if (industries is List) {
      _industriesController.text = industries.join(', ');
    } else if (industries is String) {
      _industriesController.text = industries;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    final userRepo = authProvider._userRepository;

    try {
      final expertiseList = _expertiseController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final industriesList = _industriesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await userRepo.updateMentorProfile({
        'headline': _headlineController.text.trim(),
        'bio': _bioController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
        'years_of_experience': int.tryParse(_yearsController.text.trim()) ?? 0,
        'current_company': _companyController.text.trim(),
        'current_job_title': _jobTitleController.text.trim(),
        'expertise_areas': expertiseList,
        'industries': industriesList,
        'mentoring_style': _styleController.text.trim(),
        'session_price': double.tryParse(_priceController.text.trim()) ?? 0,
        'is_accepting_mentees': _accepting ? 1 : 0,
        'linkedin_url': _linkedinController.text.trim(),
        'github_url': _githubController.text.trim(),
        'website_url': _websiteController.text.trim(),
      });

      if (mounted) {
        Helpers.showSnackBar(context, 'Mentor profile updated!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to save: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _headlineController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _yearsController.dispose();
    _companyController.dispose();
    _jobTitleController.dispose();
    _expertiseController.dispose();
    _industriesController.dispose();
    _styleController.dispose();
    _priceController.dispose();
    _linkedinController.dispose();
    _githubController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Mentor Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Professional Info', isDark),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _headlineController,
                icon: Icons.title,
                label: 'Headline (e.g. Senior Engineer @ Google)',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _bioController,
                icon: Icons.notes_outlined,
                label: 'Bio / About Me',
                maxLines: 4,
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _companyController,
                icon: Icons.business_outlined,
                label: 'Current Company',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _jobTitleController,
                icon: Icons.badge_outlined,
                label: 'Current Job Title',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _yearsController,
                icon: Icons.signal_cellular_alt,
                label: 'Years of Experience',
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
              const SizedBox(height: 22),
              _sectionLabel('Expertise', isDark),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _expertiseController,
                icon: Icons.lightbulb_outline,
                label: 'Expertise Areas (comma separated)',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _industriesController,
                icon: Icons.factory_outlined,
                label: 'Industries (comma separated)',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _styleController,
                icon: Icons.psychology_outlined,
                label: 'Mentoring Style',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _priceController,
                icon: Icons.attach_money,
                label: 'Session Price (0 = Free)',
                keyboardType: TextInputType.number,
                isDark: isDark,
              ),
              const SizedBox(height: 22),
              _sectionLabel('Contact & Links', isDark),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _phoneController,
                icon: Icons.phone_outlined,
                label: 'Phone (optional)',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _locationController,
                icon: Icons.location_on_outlined,
                label: 'Location',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _linkedinController,
                icon: Icons.link,
                label: 'LinkedIn URL',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _githubController,
                icon: Icons.code,
                label: 'GitHub URL',
                isDark: isDark,
              ),
              const SizedBox(height: 14),
              CustomTextField(
                controller: _websiteController,
                icon: Icons.language,
                label: 'Website / Portfolio URL',
                isDark: isDark,
              ),
              const SizedBox(height: 22),
              _sectionLabel('Availability', isDark),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Currently accepting mentees',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.75)
                            : AppColors.lightText,
                        fontSize: 14,
                      ),
                    ),
                    Switch(
                      value: _accepting,
                      activeColor: AppColors.primaryCyan,
                      onChanged: (v) => setState(() => _accepting = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'SAVE MENTOR PROFILE',
                onPressed: _save,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, bool isDark) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.primaryCyan,
        fontSize: 13,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }
}
