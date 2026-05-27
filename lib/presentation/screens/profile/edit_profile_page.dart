// presentation/screens/profile/edit_profile_page.dart
// v8: Fixed — properly loads profile, saves picture locally AND to Cloudinary
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/local/profile_picture_store.dart';
import '../../../data/datasources/local/token_store.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/user_provider.dart';
import '../../widgets/shared/buttons.dart';
import '../../widgets/shared/inputs.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _headlineCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _currentJobCtrl = TextEditingController();
  final _desiredJobCtrl = TextEditingController();
  final _yearsCtrl = TextEditingController();

  File? _imageFile;
  String? _remoteUrl;
  bool _isLoading = true;
  bool _isSaving = false;
  String _role = 'job_seeker';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _headlineCtrl.dispose();
    _bioCtrl.dispose();
    _currentJobCtrl.dispose();
    _desiredJobCtrl.dispose();
    _yearsCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    await auth.loadUserProfile();
    if (!mounted) return;
    final user = auth.currentUser;
    if (user != null) {
      _role = user.role;
      _nameCtrl.text = user.fullName ?? '';
      _remoteUrl = user.profilePictureUrl;
      _phoneCtrl.text = user.phone ?? '';
      _locationCtrl.text = user.location ?? '';
      _headlineCtrl.text = user.headline ?? '';
      _bioCtrl.text = user.bio ?? '';
      _currentJobCtrl.text = user.currentJobTitle ?? '';
      _desiredJobCtrl.text = user.desiredJobTitle ?? '';
      _yearsCtrl.text = user.yearsOfExperience?.toString() ?? '';
    }
    setState(() => _isLoading = false);
  }

  bool _picking = false;

  Future<void> _pickImage() async {
    if (_picking) return; // prevent double-tap crash
    setState(() => _picking = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
      );
      if (picked != null && mounted) {
        final file = File(picked.path);
        await ProfilePictureStore.saveFile(file);
        setState(() => _imageFile = file);
      }
    } catch (e) {
      // already_active — silently ignore
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);

    try {
      final token = await TokenStore().getAccess();
      if (token == null) throw Exception('Not authenticated');

      // Upload picture to Cloudinary if changed
      if (_imageFile != null) {
        final mf = await http.MultipartFile.fromPath('file', _imageFile!.path);
        final res = await ApiService().uploadPicture(token, mf);
        if (res['success'] == true) {
          _remoteUrl = (res['data'] as Map?)?['url'] as String? ?? _remoteUrl;
        }
      }

      final fields = <String, dynamic>{
        if (_nameCtrl.text.trim().isNotEmpty)
          'full_name': _nameCtrl.text.trim(),
        if (_phoneCtrl.text.trim().isNotEmpty) 'phone': _phoneCtrl.text.trim(),
        if (_locationCtrl.text.trim().isNotEmpty)
          'location': _locationCtrl.text.trim(),
        if (_headlineCtrl.text.trim().isNotEmpty)
          'headline': _headlineCtrl.text.trim(),
        if (_bioCtrl.text.trim().isNotEmpty) 'bio': _bioCtrl.text.trim(),
        if (_currentJobCtrl.text.trim().isNotEmpty)
          'current_job_title': _currentJobCtrl.text.trim(),
        if (_desiredJobCtrl.text.trim().isNotEmpty)
          'desired_job_title': _desiredJobCtrl.text.trim(),
        if (_yearsCtrl.text.trim().isNotEmpty)
          'years_of_experience': int.tryParse(_yearsCtrl.text.trim()) ?? 0,
      };

      final up = context.read<UserProvider>();
      if (_role == 'mentor') {
        await up.updateMentorProfile(fields);
      } else {
        await up.updateJobSeekerProfile(fields);
      }

      // Reload auth profile so dashboard avatar updates
      await context.read<AuthProvider>().loadUserProfile();

      if (mounted) {
        Helpers.showSnackBar(context, 'Profile updated successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          e.toString().replaceFirst('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: Text(
          lang.t(S.myProfile),
          style: TextStyle(
            color: AppColors.text(isDark),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(isDark)),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.primaryCyan),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // ── Avatar ───────────────────────────────
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            // Shows local OR remote OR initials
                            _imageFile != null
                                ? CircleAvatar(
                                  radius: 58,
                                  backgroundImage: FileImage(_imageFile!),
                                  backgroundColor: AppColors.primaryCyan
                                      .withOpacity(0.2),
                                )
                                : ProfilePictureStore.avatar(
                                  remoteUrl: _remoteUrl,
                                  name: _nameCtrl.text,
                                  radius: 58,
                                  bgColor: AppColors.primaryCyan,
                                ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryCyan,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.black,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lang.t(S.changePhoto),
                        style: TextStyle(
                          color: AppColors.primaryCyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Fields ───────────────────────────────
                      _field(
                        lang.t(S.fullName),
                        _nameCtrl,
                        Icons.person_outline,
                        isDark,
                      ),
                      _field('Phone', _phoneCtrl, Icons.phone_outlined, isDark),
                      _field(
                        lang.t(S.location),
                        _locationCtrl,
                        Icons.location_on_outlined,
                        isDark,
                      ),
                      _field(
                        'Headline',
                        _headlineCtrl,
                        Icons.text_fields_outlined,
                        isDark,
                      ),
                      _field(
                        lang.t(S.bio),
                        _bioCtrl,
                        Icons.info_outline,
                        isDark,
                        maxLines: 3,
                      ),

                      if (_role != 'mentor') ...[
                        _field(
                          'Current Job Title',
                          _currentJobCtrl,
                          Icons.work_outline,
                          isDark,
                        ),
                        _field(
                          'Desired Job Title',
                          _desiredJobCtrl,
                          Icons.trending_up_outlined,
                          isDark,
                        ),
                      ],
                      _field(
                        'Years of Experience',
                        _yearsCtrl,
                        Icons.timeline_outlined,
                        isDark,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 28),

                      // Save button
                      _SaveButton(
                        label: lang.t(S.save),
                        onTap: _save,
                        isLoading: _isSaving,
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    IconData icon,
    bool isDark, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: AppColors.text(isDark)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textSecondary(isDark)),
          prefixIcon: Icon(icon, color: AppColors.primaryCyan, size: 20),
          filled: true,
          fillColor: AppColors.inputFill(isDark),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.border(isDark)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: AppColors.primaryCyan,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  const _SaveButton({
    required this.label,
    required this.onTap,
    required this.isLoading,
  });
  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _s = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) {
      if (!widget.isLoading) _c.forward();
    },
    onTapUp: (_) {
      _c.reverse();
      if (!widget.isLoading) widget.onTap();
    },
    onTapCancel: () => _c.reverse(),
    child: ScaleTransition(
      scale: _s,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryCyan, Color(0xFF0097A7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryCyan.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Center(
          child:
              widget.isLoading
                  ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.black,
                    ),
                  )
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.save_outlined,
                        color: Colors.black,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.label.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    ),
  );
}
