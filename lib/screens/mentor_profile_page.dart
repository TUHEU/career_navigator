import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_store.dart';
import '../theme/app_theme.dart';

class MentorProfilePage extends StatefulWidget {
  final Map<String, dynamic> profile;
  const MentorProfilePage({super.key, required this.profile});

  @override
  State<MentorProfilePage> createState() => _MentorProfilePageState();
}

class _MentorProfilePageState extends State<MentorProfilePage> {
  final _formKey        = GlobalKey<FormState>();
  final _headlineCtrl   = TextEditingController();
  final _bioCtrl        = TextEditingController();
  final _phoneCtrl      = TextEditingController();
  final _locationCtrl   = TextEditingController();
  final _yearsCtrl      = TextEditingController();
  final _companyCtrl    = TextEditingController();
  final _jobTitleCtrl   = TextEditingController();
  final _expertiseCtrl  = TextEditingController(); // comma separated
  final _styleCtrl      = TextEditingController();
  final _priceCtrl      = TextEditingController();
  final _linkedinCtrl   = TextEditingController();
  final _githubCtrl     = TextEditingController();
  final _websiteCtrl    = TextEditingController();
  bool _accepting = true;
  bool _loading   = false;

  @override
  void initState() {
    super.initState();
    final mp = widget.profile['mentor_profile'] as Map<String, dynamic>? ?? {};
    _headlineCtrl.text  = mp['headline']         ?? '';
    _bioCtrl.text       = mp['bio']              ?? '';
    _phoneCtrl.text     = mp['phone']            ?? '';
    _locationCtrl.text  = mp['location']         ?? '';
    _yearsCtrl.text     = '${mp['years_of_experience'] ?? ''}';
    _companyCtrl.text   = mp['current_company']  ?? '';
    _jobTitleCtrl.text  = mp['current_job_title']?? '';
    _styleCtrl.text     = mp['mentoring_style']  ?? '';
    _priceCtrl.text     = '${mp['session_price'] ?? '0'}';
    _linkedinCtrl.text  = mp['linkedin_url']     ?? '';
    _githubCtrl.text    = mp['github_url']       ?? '';
    _websiteCtrl.text   = mp['website_url']      ?? '';
    _accepting = mp['is_accepting_mentees'] != 0;

    // expertise_areas is a JSON array — join to comma string for display
    final exp = mp['expertise_areas'];
    if (exp is List) {
      _expertiseCtrl.text = exp.join(', ');
    } else if (exp is String) {
      _expertiseCtrl.text = exp;
    }
  }

  @override
  void dispose() {
    for (final c in [
      _headlineCtrl, _bioCtrl, _phoneCtrl, _locationCtrl, _yearsCtrl,
      _companyCtrl, _jobTitleCtrl, _expertiseCtrl, _styleCtrl, _priceCtrl,
      _linkedinCtrl, _githubCtrl, _websiteCtrl,
    ]) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final token = await TokenStore.getAccess();
      if (token == null) return;

      // Convert comma list to JSON array
      final expertiseList = _expertiseCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await ApiService.updateMentorProfile(
        token: token,
        fields: {
          'headline':             _headlineCtrl.text.trim(),
          'bio':                  _bioCtrl.text.trim(),
          'phone':                _phoneCtrl.text.trim(),
          'location':             _locationCtrl.text.trim(),
          'years_of_experience':  int.tryParse(_yearsCtrl.text.trim()) ?? 0,
          'current_company':      _companyCtrl.text.trim(),
          'current_job_title':    _jobTitleCtrl.text.trim(),
          'expertise_areas':      expertiseList,
          'mentoring_style':      _styleCtrl.text.trim(),
          'session_price':        double.tryParse(_priceCtrl.text.trim()) ?? 0,
          'is_accepting_mentees': _accepting ? 1 : 0,
          'linkedin_url':         _linkedinCtrl.text.trim(),
          'github_url':           _githubCtrl.text.trim(),
          'website_url':          _websiteCtrl.text.trim(),
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mentor profile updated!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to save. Try again.')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Mentor Profile', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Professional Info'),
              _field(_headlineCtrl, Icons.title, 'Headline (e.g. Senior Engineer @ Google)'),
              const SizedBox(height: 14),
              _field(_bioCtrl, Icons.notes_outlined, 'Bio / About Me', maxLines: 4),
              const SizedBox(height: 14),
              _field(_companyCtrl, Icons.business_outlined, 'Current Company'),
              const SizedBox(height: 14),
              _field(_jobTitleCtrl, Icons.badge_outlined, 'Current Job Title'),
              const SizedBox(height: 14),
              _field(_yearsCtrl, Icons.signal_cellular_alt, 'Years of Experience',
                  keyboardType: TextInputType.number),

              const SizedBox(height: 22),
              _sectionLabel('Expertise'),
              _field(_expertiseCtrl, Icons.lightbulb_outline,
                  'Expertise Areas (comma separated)'),
              const SizedBox(height: 14),
              _field(_styleCtrl, Icons.psychology_outlined, 'Mentoring Style'),
              const SizedBox(height: 14),
              _field(_priceCtrl, Icons.attach_money, 'Session Price (0 = Free)',
                  keyboardType: TextInputType.number),

              const SizedBox(height: 22),
              _sectionLabel('Contact & Links'),
              _field(_phoneCtrl, Icons.phone_outlined, 'Phone (optional)'),
              const SizedBox(height: 14),
              _field(_locationCtrl, Icons.location_on_outlined, 'Location'),
              const SizedBox(height: 14),
              _field(_linkedinCtrl, Icons.link, 'LinkedIn URL'),
              const SizedBox(height: 14),
              _field(_githubCtrl, Icons.code, 'GitHub URL'),
              const SizedBox(height: 14),
              _field(_websiteCtrl, Icons.language, 'Website / Portfolio URL'),

              const SizedBox(height: 22),
              _sectionLabel('Availability'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Currently accepting mentees',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.75), fontSize: 14)),
                    Switch(
                      value: _accepting,
                      activeColor: AppColors.primaryCyan,
                      onChanged: (v) => setState(() => _accepting = v),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCyan,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.black))
                    : const Text('SAVE MENTOR PROFILE',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(label,
        style: const TextStyle(
            color: AppColors.primaryCyan,
            fontSize: 13,
            fontWeight: FontWeight.bold,
            letterSpacing: 1)),
  );

  Widget _field(
    TextEditingController ctrl,
    IconData icon,
    String label, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        validator: validator,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: buildInputDecoration(icon: icon, label: label),
      );
}
