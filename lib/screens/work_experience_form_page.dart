import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_store.dart';
import '../theme/app_theme.dart';

class WorkExperienceFormPage extends StatefulWidget {
  final Map<String, dynamic>? existing;
  const WorkExperienceFormPage({super.key, this.existing});

  @override
  State<WorkExperienceFormPage> createState() => _WorkExperienceFormPageState();
}

class _WorkExperienceFormPageState extends State<WorkExperienceFormPage> {
  final _formKey     = GlobalKey<FormState>();
  final _companyCtrl = TextEditingController();
  final _titleCtrl   = TextEditingController();
  final _locationCtrl= TextEditingController();
  final _startCtrl   = TextEditingController();
  final _endCtrl     = TextEditingController();
  final _descCtrl    = TextEditingController();
  bool   _isCurrent  = false;
  bool   _loading    = false;
  String _empType    = 'full_time';

  final List<String> _empTypes = [
    'full_time', 'part_time', 'contract', 'internship', 'freelance', 'volunteer'
  ];

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _companyCtrl.text  = e['company']   ?? '';
      _titleCtrl.text    = e['job_title'] ?? '';
      _locationCtrl.text = e['location']  ?? '';
      _startCtrl.text    = e['start_date']?.toString() ?? '';
      _endCtrl.text      = e['end_date']?.toString()   ?? '';
      _descCtrl.text     = e['description'] ?? '';
      _isCurrent = e['is_current'] == 1 || e['is_current'] == true;
      _empType   = e['employment_type'] ?? 'full_time';
    }
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final token = await TokenStore.getAccess();
      if (token == null) return;

      final data = {
        'company':         _companyCtrl.text.trim(),
        'job_title':       _titleCtrl.text.trim(),
        'employment_type': _empType,
        'location':        _locationCtrl.text.trim(),
        'start_date':      _startCtrl.text.trim(),
        'end_date':        _isCurrent ? null : _endCtrl.text.trim(),
        'is_current':      _isCurrent ? 1 : 0,
        'description':     _descCtrl.text.trim(),
      };

      if (_isEdit) {
        await ApiService.updateWorkExperience(
            token: token, id: widget.existing!['id'] as int, data: data);
      } else {
        await ApiService.addWorkExperience(token: token, data: data);
      }

      if (mounted) Navigator.pop(context);
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
        title: Text(_isEdit ? 'Edit Experience' : 'Add Experience',
            style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(_companyCtrl, Icons.business_outlined, 'Company / Organization',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              _field(_titleCtrl, Icons.badge_outlined, 'Job Title',
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null),
              const SizedBox(height: 16),
              _field(_locationCtrl, Icons.location_on_outlined, 'Location (optional)'),
              const SizedBox(height: 16),

              // Employment type dropdown
              DropdownButtonFormField<String>(
                value: _empType,
                dropdownColor: const Color(0xFF0D2137),
                style: const TextStyle(color: Colors.white),
                decoration: buildInputDecoration(
                    icon: Icons.work_outline, label: 'Employment Type'),
                items: _empTypes
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(fontSize: 13),
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _empType = v!),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _field(_startCtrl, Icons.calendar_today_outlined,
                        'Start Date (YYYY-MM-DD)',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(_endCtrl, Icons.calendar_month_outlined,
                        _isCurrent ? 'End (Present)' : 'End Date',
                        enabled: !_isCurrent),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('I currently work here',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.75), fontSize: 14)),
                    Switch(
                      value: _isCurrent,
                      activeColor: AppColors.primaryCyan,
                      onChanged: (v) => setState(() => _isCurrent = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _field(_descCtrl, Icons.notes_outlined, 'Description (optional)',
                  maxLines: 3),
              const SizedBox(height: 30),
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
                    : Text(_isEdit ? 'UPDATE' : 'ADD EXPERIENCE',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    IconData icon,
    String label, {
    String? Function(String?)? validator,
    int maxLines = 1,
    bool enabled = true,
  }) =>
      TextFormField(
        controller: ctrl,
        validator: validator,
        maxLines: maxLines,
        enabled: enabled,
        style: const TextStyle(color: Colors.white),
        decoration: buildInputDecoration(icon: icon, label: label),
      );
}
