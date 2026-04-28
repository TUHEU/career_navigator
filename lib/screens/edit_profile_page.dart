import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../services/token_store.dart';
import '../theme/app_theme.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _headlineCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _picker = ImagePicker();

  bool _loading = false;
  bool _saving = false;
  String? _pictureUrl;
  String _role = 'job_seeker';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final token = await TokenStore.getAccess();
      if (token == null) return;
      final res = await ApiService.getProfile(token);
      if (res['success'] == true && mounted) {
        final p = res['data'] as Map<String, dynamic>;
        final mp = (p['mentor_profile'] as Map<String, dynamic>?) ?? {};
        setState(() {
          _nameCtrl.text = p['full_name'] ?? '';
          _role = p['role'] ?? 'job_seeker';
          _pictureUrl = p['profile_picture_url'] as String?;
          _phoneCtrl.text = p['phone'] ?? mp['phone'] ?? '';
          _locationCtrl.text = p['location'] ?? mp['location'] ?? '';
          _headlineCtrl.text = p['headline'] ?? mp['headline'] ?? '';
          _bioCtrl.text = p['bio'] ?? mp['bio'] ?? '';
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUploadPicture() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    // For demo: store local path as URL
    // In production you'd upload to S3/Cloudinary and store the returned URL
    final file = File(picked.path);
    _snack('Profile picture selected (upload to server in production)');
    setState(() => _pictureUrl = file.path);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      _snack('Name required');
      return;
    }
    setState(() => _saving = true);

    try {
      final token = await TokenStore.getAccess();
      if (token == null) return;

      await ApiService.setupProfile(
        token: token,
        fullName: name,
        dob: '',
        role: _role,
      );

      final fields = {
        'phone': _phoneCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'headline': _headlineCtrl.text.trim(),
        'bio': _bioCtrl.text.trim(),
      };

      if (_role == 'mentor') {
        await ApiService.updateMentorProfile(token: token, fields: fields);
      } else {
        await ApiService.updateJobSeekerProfile(token: token, fields: fields);
      }

      if (mounted) {
        _snack('Profile updated!');
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) _snack('Failed to save. Try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _headlineCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
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
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryCyan),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadPicture,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 58,
                          backgroundColor: AppColors.primaryCyan.withOpacity(
                            0.2,
                          ),
                          backgroundImage: _pictureUrl != null
                              ? (_pictureUrl!.startsWith('http')
                                    ? NetworkImage(_pictureUrl!)
                                          as ImageProvider
                                    : FileImage(File(_pictureUrl!)))
                              : null,
                          child: _pictureUrl == null
                              ? const Icon(
                                  Icons.person,
                                  color: AppColors.primaryCyan,
                                  size: 46,
                                )
                              : null,
                        ),
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
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to change photo',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _field(_nameCtrl, Icons.person_outline, 'Full Name'),
                  const SizedBox(height: 16),
                  _field(_phoneCtrl, Icons.phone_outlined, 'Phone'),
                  const SizedBox(height: 16),
                  _field(_locationCtrl, Icons.location_on_outlined, 'Location'),
                  const SizedBox(height: 16),
                  _field(_headlineCtrl, Icons.title, 'Headline'),
                  const SizedBox(height: 16),
                  _field(_bioCtrl, Icons.notes_outlined, 'Bio', maxLines: 4),
                  const SizedBox(height: 36),
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCyan,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'SAVE CHANGES',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    IconData icon,
    String label, {
    int maxLines = 1,
  }) => TextFormField(
    controller: ctrl,
    maxLines: maxLines,
    style: const TextStyle(color: Colors.white),
    decoration: buildInputDecoration(icon: icon, label: label),
  );
}
