import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/buttons.dart';
import '../../widgets/shared/inputs.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _headlineController = TextEditingController();
  final _bioController = TextEditingController();
  final _currentJobController = TextEditingController();
  final _desiredJobController = TextEditingController();
  final _yearsController = TextEditingController();
  final _availabilityController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  File? _image;
  String? _pictureUrl;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingPicture = false;
  String _role = 'job_seeker';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();
    await authProvider.loadUserProfile();

    if (mounted) {
      final user = authProvider.currentUser;
      if (user != null) {
        _role = user.role;
        _nameController.text = user.fullName ?? '';
        _pictureUrl = user.profilePictureUrl;
        _phoneController.text = user.phone ?? '';
        _locationController.text = user.location ?? '';
        _headlineController.text = user.headline ?? '';
        _bioController.text = user.bio ?? '';
        _currentJobController.text = user.currentJobTitle ?? '';
        _desiredJobController.text = user.desiredJobTitle ?? '';
        _yearsController.text = user.yearsOfExperience?.toString() ?? '';
        _availabilityController.text = user.availability ?? '';
      }
      setState(() => _isLoading = false);
    }
  }

  /// Pick image from gallery then immediately upload to Cloudinary via backend
  Future<void> _pickAndUploadImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    setState(() {
      _image = File(picked.path);
      _isUploadingPicture = true;
    });

    try {
      final token = await context.read<AuthProvider>().getAccessToken();
      if (token == null) throw Exception('Not authenticated');

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.updatePicture}'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', picked.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Reload profile to get the new picture URL
        await context.read<AuthProvider>().loadUserProfile();
        if (mounted) {
          final user = context.read<AuthProvider>().currentUser;
          setState(() {
            _pictureUrl = user?.profilePictureUrl;
            _image = null; // Clear local file — use remote URL now
          });
          Helpers.showSnackBar(context, 'Profile picture updated!');
        }
      } else {
        if (mounted) {
          Helpers.showSnackBar(
            context,
            'Failed to upload picture. Try again.',
            isError: true,
          );
          setState(() => _image = null);
        }
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Upload error: $e', isError: true);
        setState(() => _image = null);
      }
    } finally {
      if (mounted) setState(() => _isUploadingPicture = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final authProvider = context.read<AuthProvider>();
    final userRepo = authProvider.userRepository;

    try {
      final fields = <String, dynamic>{};
      if (_phoneController.text.trim().isNotEmpty) {
        fields['phone'] = _phoneController.text.trim();
      }
      if (_locationController.text.trim().isNotEmpty) {
        fields['location'] = _locationController.text.trim();
      }
      if (_headlineController.text.trim().isNotEmpty) {
        fields['headline'] = _headlineController.text.trim();
      }
      if (_bioController.text.trim().isNotEmpty) {
        fields['bio'] = _bioController.text.trim();
      }

      if (_role == 'job_seeker') {
        if (_currentJobController.text.trim().isNotEmpty) {
          fields['current_job_title'] = _currentJobController.text.trim();
        }
        if (_desiredJobController.text.trim().isNotEmpty) {
          fields['desired_job_title'] = _desiredJobController.text.trim();
        }
        if (_yearsController.text.trim().isNotEmpty) {
          fields['years_of_experience'] =
              int.tryParse(_yearsController.text.trim()) ?? 0;
        }
        if (_availabilityController.text.trim().isNotEmpty) {
          fields['availability'] = _availabilityController.text.trim();
        }
        if (fields.isNotEmpty) await userRepo.updateJobSeekerProfile(fields);
      } else if (_role == 'mentor') {
        if (_currentJobController.text.trim().isNotEmpty) {
          fields['current_job_title'] = _currentJobController.text.trim();
        }
        if (_yearsController.text.trim().isNotEmpty) {
          fields['years_of_experience'] =
              int.tryParse(_yearsController.text.trim()) ?? 0;
        }
        if (fields.isNotEmpty) await userRepo.updateMentorProfile(fields);
      }

      if (_nameController.text.trim().isNotEmpty) {
        await userRepo.setupProfile(
          fullName: _nameController.text.trim(),
          dob: '',
          role: _role,
        );
      }

      if (mounted) {
        Helpers.showSnackBar(context, 'Profile updated successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, 'Failed to update: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _headlineController.dispose();
    _bioController.dispose();
    _currentJobController.dispose();
    _desiredJobController.dispose();
    _yearsController.dispose();
    _availabilityController.dispose();
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
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryCyan,
                    ),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      color: AppColors.primaryCyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryCyan),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildProfileImage(isDark),
                    const SizedBox(height: 28),
                    CustomTextField(
                      controller: _nameController,
                      icon: Icons.person_outline,
                      label: 'Full Name',
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _phoneController,
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _locationController,
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _headlineController,
                      icon: Icons.title,
                      label: 'Headline',
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _bioController,
                      icon: Icons.notes_outlined,
                      label: 'Bio',
                      maxLines: 4,
                      isDark: isDark,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _currentJobController,
                      icon: Icons.work_outline,
                      label: 'Current Job Title',
                      isDark: isDark,
                    ),
                    if (_role == 'job_seeker') ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _desiredJobController,
                        icon: Icons.flag_outlined,
                        label: 'Desired Job Title',
                        isDark: isDark,
                      ),
                    ],
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _yearsController,
                      icon: Icons.signal_cellular_alt,
                      label: 'Years of Experience',
                      keyboardType: TextInputType.number,
                      isDark: isDark,
                    ),
                    if (_role == 'job_seeker') ...[
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _availabilityController,
                        icon: Icons.hourglass_top_outlined,
                        label: 'Availability',
                        isDark: isDark,
                      ),
                    ],
                    const SizedBox(height: 36),
                    PrimaryButton(
                      text: 'SAVE CHANGES',
                      onPressed: _save,
                      isLoading: _isSaving,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileImage(bool isDark) {
    return GestureDetector(
      onTap: _isUploadingPicture ? null : _pickAndUploadImage,
      child: Stack(
        children: [
          // ── Avatar ────────────────────────────────────────
          CircleAvatar(
            radius: 58,
            backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
            // Show local file while uploading, else show remote URL
            backgroundImage: _image != null
                ? FileImage(_image!) as ImageProvider
                : (_pictureUrl != null && _pictureUrl!.isNotEmpty
                      ? NetworkImage(_pictureUrl!)
                      : null),
            child:
                (_image == null &&
                    (_pictureUrl == null || _pictureUrl!.isEmpty))
                ? const Icon(
                    Icons.person,
                    color: AppColors.primaryCyan,
                    size: 46,
                  )
                : null,
          ),
          // ── Upload spinner overlay ─────────────────────────
          if (_isUploadingPicture)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.45),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryCyan,
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          // ── Camera icon badge ──────────────────────────────
          if (!_isUploadingPicture)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(7),
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
    );
  }
}
