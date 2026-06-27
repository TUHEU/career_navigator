// presentation/screens/profile/edit_profile_page.dart
// v9 — Full redesign: tabbed sections (Basic, Career, Skills, Social),
//       XP display, animated save, skill chips add/remove
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/local/profile_picture_store.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/buttons.dart';
import '../../widgets/shared/loading_widgets.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>
    with SingleTickerProviderStateMixin {
  final _formKey        = GlobalKey<FormState>();
  final _nameCtrl       = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _locationCtrl   = TextEditingController();
  final _headlineCtrl   = TextEditingController();
  final _bioCtrl        = TextEditingController();
  final _currentJobCtrl = TextEditingController();
  final _desiredJobCtrl = TextEditingController();
  final _yearsCtrl      = TextEditingController();
  final _skillCtrl      = TextEditingController();

  late TabController _tab;
  File?   _imageFile;
  String? _remoteUrl;
  bool    _loading = true;
  bool    _saving  = false;
  bool    _picking = false;
  String  _role    = 'job_seeker';
  List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    for (final c in [_nameCtrl,_phoneCtrl,_locationCtrl,_headlineCtrl,
      _bioCtrl,_currentJobCtrl,_desiredJobCtrl,_yearsCtrl,_skillCtrl]) c.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    await auth.loadUserProfile();
    if (!mounted) return;
    final u = auth.currentUser;
    if (u != null) {
      _role              = u.role;
      _nameCtrl.text     = u.fullName ?? '';
      _remoteUrl         = u.profilePictureUrl;
      _phoneCtrl.text    = u.phone ?? '';
      _locationCtrl.text = u.location ?? '';
      _headlineCtrl.text = u.headline ?? '';
      _bioCtrl.text      = u.bio ?? '';
      _currentJobCtrl.text = u.currentJobTitle ?? '';
      _desiredJobCtrl.text = u.desiredJobTitle ?? '';
      _yearsCtrl.text    = u.yearsOfExperience?.toString() ?? '';
      // User model uses expertiseAreas for mentors; for seekers skills are in the extended profile
      if (u.expertiseAreas != null) {
        _skills = List<String>.from(u.expertiseAreas!);
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery, imageQuality: 80);
      if (picked != null && mounted) {
        final f = File(picked.path);
        await ProfilePictureStore.saveFile(f);
        setState(() => _imageFile = f);
      }
    } catch (_) {}
    finally { if (mounted) setState(() => _picking = false); }
  }

  void _addSkill() {
    final s = _skillCtrl.text.trim();
    if (s.isEmpty || _skills.contains(s)) return;
    setState(() { _skills.add(s); _skillCtrl.clear(); });
  }

  void _removeSkill(String s) => setState(() => _skills.remove(s));

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final auth  = context.read<AuthProvider>();
    final token = await auth.getAccessToken();
    if (token == null) {
      setState(() => _saving = false);
      return;
    }

    final api = ApiService();
    String? picUrl;

    if (_imageFile != null) {
      try {
        final multipartFile = await http.MultipartFile.fromPath(
          'profile_picture', _imageFile!.path);
        final r = await api.uploadPicture(token, multipartFile);
        if (r['success'] == true) picUrl = r['data']?['profile_picture_url'];
      } catch (_) {}
    }

    final body = <String, dynamic>{
      'full_name':          _nameCtrl.text.trim(),
      'phone':              _phoneCtrl.text.trim(),
      'location':           _locationCtrl.text.trim(),
      'headline':           _headlineCtrl.text.trim(),
      'bio':                _bioCtrl.text.trim(),
      'current_job_title':  _currentJobCtrl.text.trim(),
      'desired_job_title':  _desiredJobCtrl.text.trim(),
      'years_of_experience':int.tryParse(_yearsCtrl.text) ?? 0,
      'skills':             _skills,
      if (picUrl != null) 'profile_picture_url': picUrl,
    };

    final res = _role == 'mentor'
        ? await api.updateMentorProfile(token: token, fields: body)
        : await api.updateJobSeekerProfile(token: token, fields: body);

    if (!mounted) return;
    setState(() => _saving = false);

    if (res['success'] == true) {
      await auth.loadUserProfile();
      Helpers.showSnackBar(context, '✅ Profile saved!');
      Navigator.pop(context);
    } else {
      Helpers.showSnackBar(context,
          res['message'] ?? 'Save failed', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final lang   = context.watch<LanguageProvider>();
    final user   = context.watch<AuthProvider>().currentUser;

    if (_loading) return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: const LoadingIndicator(message: 'Loading profile...'));

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: Text(lang.t(S.editProfile), style: TextStyle(
          color: AppColors.text(isDark), fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background(isDark), elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(isDark)),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primaryCyan))
                : const Icon(Icons.check, color: AppColors.primaryCyan, size: 20),
            label: Text(_saving ? 'Saving...' : 'Save',
              style: const TextStyle(color: AppColors.primaryCyan,
                  fontWeight: FontWeight.bold)),
          ),
        ],
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primaryCyan,
          unselectedLabelColor: AppColors.textMuted(isDark),
          indicatorColor: AppColors.primaryCyan, indicatorWeight: 2,
          dividerColor: AppColors.border(isDark),
          tabs: const [
            Tab(text: 'Basic'),
            Tab(text: 'Career'),
            Tab(text: 'Skills'),
          ],
        ),
      ),
      body: Form(key: _formKey, child: TabBarView(controller: _tab, children: [
        // ── TAB 1: BASIC ──────────────────────────────────────────
        _buildBasicTab(isDark, user),
        // ── TAB 2: CAREER ─────────────────────────────────────────
        _buildCareerTab(isDark),
        // ── TAB 3: SKILLS ─────────────────────────────────────────
        _buildSkillsTab(isDark),
      ])),
    );
  }

  Widget _buildBasicTab(bool isDark, dynamic user) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Avatar
      Center(child: GestureDetector(
        onTap: _pickImage,
        child: Stack(children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryCyan.withOpacity(0.5), width: 2),
              boxShadow: [BoxShadow(
                color: AppColors.primaryCyan.withOpacity(0.2), blurRadius: 20)]),
            child: _imageFile != null
                ? ClipOval(child: Image.file(_imageFile!, fit: BoxFit.cover))
                : _remoteUrl != null
                  ? ClipOval(child: Image.network(_remoteUrl!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _initials(user)))
                  : _initials(user),
          ),
          Positioned(bottom: 4, right: 4, child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.primaryCyan, shape: BoxShape.circle),
            child: const Icon(Icons.camera_alt, color: Colors.black, size: 14))),
        ]),
      )),
      const SizedBox(height: 8),
      const Center(child: Text('Tap to change photo',
        style: TextStyle(color: AppColors.primaryCyan, fontSize: 12))),
      const SizedBox(height: 24),
      _field('Full Name', _nameCtrl, Icons.person_outline, isDark,
        validator: (v) => v!.isEmpty ? 'Required' : null),
      _field('Phone Number', _phoneCtrl, Icons.phone_outlined, isDark,
        type: TextInputType.phone),
      _field('Location (City, Country)', _locationCtrl, Icons.location_on_outlined, isDark),
      _field('Professional Headline', _headlineCtrl, Icons.title_rounded, isDark,
        hint: 'e.g. Senior Flutter Developer'),
      _multilineField('Bio', _bioCtrl, isDark,
        hint: 'Write a short professional summary...'),
    ]),
  );

  Widget _buildCareerTab(bool isDark) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('Current Position', isDark),
      _field('Current Job Title', _currentJobCtrl, Icons.work_outline, isDark),
      const SizedBox(height: 8),
      _label('Career Goals', isDark),
      _field('Desired Job Title', _desiredJobCtrl, Icons.star_outline, isDark),
      _field('Years of Experience', _yearsCtrl, Icons.access_time_outlined, isDark,
        type: TextInputType.number),
      const SizedBox(height: 16),
      Text('Account Role', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 14, fontWeight: FontWeight.w600)),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _RoleChip(
          label: 'Job Seeker', icon: Icons.search_rounded,
          selected: _role == 'job_seeker', color: AppColors.primaryCyan, isDark: isDark,
          onTap: () => setState(() => _role = 'job_seeker'))),
        const SizedBox(width: 12),
        Expanded(child: _RoleChip(
          label: 'Mentor', icon: Icons.school_outlined,
          selected: _role == 'mentor', color: const Color(0xFF7C3AED), isDark: isDark,
          onTap: () => setState(() => _role = 'mentor'))),
      ]),
    ]),
  );

  Widget _buildSkillsTab(bool isDark) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('My Skills', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text('Add skills that showcase your expertise', style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 13)),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: TextField(
          controller: _skillCtrl,
          style: TextStyle(color: AppColors.text(isDark)),
          onSubmitted: (_) => _addSkill(),
          decoration: InputDecoration(
            hintText: 'e.g. Flutter, Python, SQL...',
            hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
            filled: true, fillColor: AppColors.card(isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primaryCyan)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        )),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _addSkill,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.primaryCyan, shape: BoxShape.circle),
            child: const Icon(Icons.add, color: Colors.black, size: 20))),
      ]),
      const SizedBox(height: 20),
      if (_skills.isEmpty)
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card(isDark), borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(isDark))),
          child: Center(child: Text('No skills added yet', style: TextStyle(
            color: AppColors.textMuted(isDark)))))
      else
        Wrap(spacing: 8, runSpacing: 8, children: _skills.map((s) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.primaryCyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(s, style: const TextStyle(
              color: AppColors.primaryCyan, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _removeSkill(s),
              child: const Icon(Icons.close, color: AppColors.primaryCyan, size: 14)),
          ]),
        )).toList()),
    ]),
  );

  Widget _initials(dynamic user) {
    final n = user?.fullName ?? 'U';
    return CircleAvatar(
      backgroundColor: AppColors.primaryCyan.withOpacity(0.15),
      child: Text(n.isNotEmpty ? n[0].toUpperCase() : '?',
        style: const TextStyle(
          color: AppColors.primaryCyan, fontSize: 32, fontWeight: FontWeight.bold)));
  }

  Widget _label(String text, bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text.toUpperCase(), style: const TextStyle(
      color: AppColors.primaryCyan, fontSize: 11,
      fontWeight: FontWeight.bold, letterSpacing: 1.5)));

  Widget _field(String label, TextEditingController ctrl,
      IconData icon, bool isDark, {
    TextInputType type = TextInputType.text,
    String? Function(String?)? validator,
    String? hint,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: ctrl, keyboardType: type, validator: validator,
      style: TextStyle(color: AppColors.text(isDark)),
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        hintStyle: TextStyle(color: AppColors.textMuted(isDark), fontSize: 12),
        labelStyle: TextStyle(color: AppColors.textMuted(isDark)),
        prefixIcon: Icon(icon, color: AppColors.primaryCyan, size: 20),
        filled: true, fillColor: AppColors.card(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border(isDark))),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryCyan)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger))),
    ));

  Widget _multilineField(String label, TextEditingController ctrl,
      bool isDark, {String? hint}) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: ctrl, maxLines: 4,
      style: TextStyle(color: AppColors.text(isDark)),
      decoration: InputDecoration(
        labelText: label, hintText: hint,
        hintStyle: TextStyle(color: AppColors.textMuted(isDark), fontSize: 12),
        labelStyle: TextStyle(color: AppColors.textMuted(isDark)),
        filled: true, fillColor: AppColors.card(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.border(isDark))),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryCyan))),
    ));
}

class _RoleChip extends StatelessWidget {
  final String label; final IconData icon;
  final bool selected, isDark; final Color color; final VoidCallback onTap;
  const _RoleChip({required this.label, required this.icon,
    required this.selected, required this.isDark,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: selected ? color.withOpacity(0.12) : AppColors.card(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? color : AppColors.border(isDark),
          width: selected ? 2 : 1)),
      child: Column(children: [
        Icon(icon, color: selected ? color : AppColors.textMuted(isDark), size: 24),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(
          color: selected ? color : AppColors.textMuted(isDark),
          fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    ));
}
