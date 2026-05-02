import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/buttons.dart';
import '../dashboard/job_seeker_dashboard.dart';
import '../dashboard/mentor_dashboard.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  DateTime? _selectedDate;
  String _selectedRole = 'job_seeker';
  final TextEditingController _nameController = TextEditingController();

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _finish() async {
    if (_nameController.text.trim().isEmpty) {
      Helpers.showSnackBar(
        context,
        'Please enter your full name.',
        isError: true,
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final dob = _selectedDate != null
        ? '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}'
        : '';

    final success = await authProvider.setupProfile(
      fullName: _nameController.text.trim(),
      dob: dob,
      role: _selectedRole,
    );

    if (!mounted) return;

    if (success) {
      if (_selectedRole == 'mentor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MentorDashboard()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const JobSeekerDashboard()),
        );
      }
    } else {
      Helpers.showSnackBar(
        context,
        authProvider.error ?? 'Failed to save profile',
        isError: true,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Profile Setup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete Your Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 62,
                      backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
                      backgroundImage: _image != null
                          ? FileImage(_image!)
                          : null,
                      child: _image == null
                          ? const Icon(
                              Icons.person,
                              color: AppColors.primaryCyan,
                              size: 50,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryCyan,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.black,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap to upload profile picture',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              controller: _nameController,
              icon: Icons.person_outline,
              label: 'Full Name',
              isDark: isDark,
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: AppColors.primaryCyan,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedDate != null
                          ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : 'Date of Birth',
                      style: TextStyle(
                        color: _selectedDate != null
                            ? (isDark ? Colors.white : AppColors.lightText)
                            : (isDark
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.grey.shade500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'I am a...',
              style: TextStyle(
                color: isDark
                    ? Colors.white.withOpacity(0.75)
                    : AppColors.lightText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _RoleCard(
                    icon: Icons.search_rounded,
                    title: 'Job Seeker',
                    subtitle: 'Looking for opportunities',
                    selected: _selectedRole == 'job_seeker',
                    onTap: () => setState(() => _selectedRole = 'job_seeker'),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _RoleCard(
                    icon: Icons.school_outlined,
                    title: 'Mentor',
                    subtitle: 'Guide others in their career',
                    selected: _selectedRole == 'mentor',
                    onTap: () => setState(() => _selectedRole = 'mentor'),
                    isDark: isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            PrimaryButton(
              text: 'FINISH REGISTRATION',
              onPressed: _finish,
              isLoading: authProvider.isLoading,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primaryCyan.withOpacity(0.12)
            : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? AppColors.primaryCyan
              : (isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.grey.shade300),
          width: selected ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: selected
                ? AppColors.primaryCyan
                : (isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.grey.shade500),
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: selected
                  ? (isDark ? Colors.white : AppColors.lightText)
                  : (isDark
                        ? Colors.white.withOpacity(0.65)
                        : AppColors.lightTextSecondary),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark
                  ? Colors.white.withOpacity(0.4)
                  : Colors.grey.shade500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ),
  );
}
