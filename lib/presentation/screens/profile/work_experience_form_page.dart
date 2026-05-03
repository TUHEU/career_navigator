import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/buttons.dart';
import '../../widgets/shared/inputs.dart';

class WorkExperienceFormPage extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const WorkExperienceFormPage({super.key, this.existing});

  @override
  State<WorkExperienceFormPage> createState() => _WorkExperienceFormPageState();
}

class _WorkExperienceFormPageState extends State<WorkExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isCurrent = false;
  bool _isLoading = false;
  String _employmentType = 'full_time';
  final List<String> _employmentTypes = [
    'full_time',
    'part_time',
    'contract',
    'internship',
    'freelance',
    'volunteer',
  ];
  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _companyController.text = existing['company'] ?? '';
      _titleController.text = existing['job_title'] ?? '';
      _locationController.text = existing['location'] ?? '';
      _startController.text = existing['start_date']?.toString() ?? '';
      _endController.text = existing['end_date']?.toString() ?? '';
      _descriptionController.text = existing['description'] ?? '';
      _isCurrent =
          existing['is_current'] == 1 || existing['is_current'] == true;
      _employmentType = existing['employment_type'] ?? 'full_time';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final userRepo = authProvider._userRepository;

    try {
      final work = WorkExperience(
        id: _isEdit ? widget.existing!['id'] as int : null,
        company: _companyController.text.trim(),
        jobTitle: _titleController.text.trim(),
        employmentType: _employmentType,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        startDate: _startController.text.trim(),
        endDate: _isCurrent
            ? null
            : (_endController.text.trim().isEmpty
                  ? null
                  : _endController.text.trim()),
        isCurrent: _isCurrent,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (_isEdit) {
        await userRepo.updateWorkExperience(work.id!, work);
      } else {
        await userRepo.addWorkExperience(work);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        Helpers.showSnackBar(context, 'Failed to save: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    _startController.dispose();
    _endController.dispose();
    _descriptionController.dispose();
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
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Experience' : 'Add Experience'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _companyController,
                icon: Icons.business_outlined,
                label: 'Company / Organization',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _titleController,
                icon: Icons.badge_outlined,
                label: 'Job Title',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _locationController,
                icon: Icons.location_on_outlined,
                label: 'Location (optional)',
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _employmentType,
                dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.lightText,
                ),
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.work_outline,
                    color: AppColors.primaryCyan,
                  ),
                  labelText: 'Employment Type',
                  labelStyle: TextStyle(
                    color: isDark
                        ? Colors.white.withOpacity(0.6)
                        : Colors.grey.shade600,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.15)
                          : Colors.grey.shade300,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: const BorderSide(color: AppColors.primaryCyan),
                  ),
                ),
                items: _employmentTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(
                          type.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _employmentType = value!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _startController,
                      icon: Icons.calendar_today_outlined,
                      label: 'Start Date (YYYY-MM-DD)',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _endController,
                      icon: Icons.calendar_month_outlined,
                      label: _isCurrent ? 'End Date (Present)' : 'End Date',
                      enabled: !_isCurrent,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
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
                      'I currently work here',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.75)
                            : AppColors.lightText,
                        fontSize: 14,
                      ),
                    ),
                    Switch(
                      value: _isCurrent,
                      activeColor: AppColors.primaryCyan,
                      onChanged: (v) => setState(() => _isCurrent = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                icon: Icons.notes_outlined,
                label: 'Description (optional)',
                maxLines: 3,
                isDark: isDark,
              ),
              const SizedBox(height: 30),
              PrimaryButton(
                text: _isEdit ? 'UPDATE' : 'ADD EXPERIENCE',
                onPressed: _save,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
