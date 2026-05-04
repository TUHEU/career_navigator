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

class EducationFormPage extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const EducationFormPage({super.key, this.existing});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _institutionController = TextEditingController();
  final _degreeController = TextEditingController();
  final _fieldController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isCurrent = false;
  bool _isLoading = false;
  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _institutionController.text = existing['institution'] ?? '';
      _degreeController.text = existing['degree'] ?? '';
      _fieldController.text = existing['field_of_study'] ?? '';
      _startController.text = '${existing['start_year'] ?? ''}';
      _endController.text = '${existing['end_year'] ?? ''}';
      _descriptionController.text = existing['description'] ?? '';
      _isCurrent =
          existing['is_current'] == 1 || existing['is_current'] == true;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final userRepo = authProvider.userRepository; // FIXED: using public getter

    try {
      final education = Education(
        id: _isEdit ? widget.existing!['id'] as int : null,
        institution: _institutionController.text.trim(),
        degree: _degreeController.text.trim(),
        fieldOfStudy: _fieldController.text.trim(),
        startYear: int.parse(_startController.text.trim()),
        endYear: _isCurrent ? null : int.tryParse(_endController.text.trim()),
        isCurrent: _isCurrent,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (_isEdit) {
        await userRepo.updateEducation(education.id!, education);
      } else {
        await userRepo.addEducation(education);
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
    _institutionController.dispose();
    _degreeController.dispose();
    _fieldController.dispose();
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
      appBar: AppBar(title: Text(_isEdit ? 'Edit Education' : 'Add Education')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _institutionController,
                icon: Icons.account_balance_outlined,
                label: 'Institution / University',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _degreeController,
                icon: Icons.military_tech_outlined,
                label: 'Degree',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _fieldController,
                icon: Icons.book_outlined,
                label: 'Field of Study',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _startController,
                      icon: Icons.calendar_today_outlined,
                      label: 'Start Year',
                      keyboardType: TextInputType.number,
                      validator: Validators.validateYear,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _endController,
                      icon: Icons.calendar_month_outlined,
                      label: _isCurrent ? 'End Year (Present)' : 'End Year',
                      keyboardType: TextInputType.number,
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
                      'Currently studying here',
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
                text: _isEdit ? 'UPDATE' : 'ADD EDUCATION',
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
