import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_store.dart';
import '../theme/app_theme.dart';

class EducationFormPage extends StatefulWidget {
  final Map<String, dynamic>? existing;

  const EducationFormPage({super.key, this.existing});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _institutionCtrl = TextEditingController();
  final _degreeCtrl = TextEditingController();
  final _fieldCtrl = TextEditingController();
  final _startCtrl = TextEditingController();
  final _endCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isCurrent = false;
  bool _loading = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _institutionCtrl.text = e['institution'] ?? '';
      _degreeCtrl.text = e['degree'] ?? '';
      _fieldCtrl.text = e['field_of_study'] ?? '';
      _startCtrl.text = '${e['start_year'] ?? ''}';
      _endCtrl.text = '${e['end_year'] ?? ''}';
      _descCtrl.text = e['description'] ?? '';
      _isCurrent = e['is_current'] == 1 || e['is_current'] == true;
    }
  }

  @override
  void dispose() {
    _institutionCtrl.dispose();
    _degreeCtrl.dispose();
    _fieldCtrl.dispose();
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
        'institution': _institutionCtrl.text.trim(),
        'degree': _degreeCtrl.text.trim(),
        'field_of_study': _fieldCtrl.text.trim(),
        'start_year': int.tryParse(_startCtrl.text.trim()),
        'end_year': _isCurrent ? null : int.tryParse(_endCtrl.text.trim()),
        'is_current': _isCurrent ? 1 : 0,
        'description': _descCtrl.text.trim(),
      };

      if (_isEdit) {
        await ApiService.updateEducation(
          token: token,
          id: widget.existing!['id'] as int,
          data: data,
        );
      } else {
        await ApiService.addEducation(token: token, data: data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save. Try again.')),
        );
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
        title: Text(
          _isEdit ? 'Edit Education' : 'Add Education',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field(
                _institutionCtrl,
                Icons.account_balance_outlined,
                'Institution / University',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _field(
                _degreeCtrl,
                Icons.military_tech_outlined,
                'Degree (e.g. BSc, MBA)',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              _field(
                _fieldCtrl,
                Icons.book_outlined,
                'Field of Study',
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _field(
                      _startCtrl,
                      Icons.calendar_today_outlined,
                      'Start Year',
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(
                      _endCtrl,
                      Icons.calendar_month_outlined,
                      _isCurrent ? 'End Year (Present)' : 'End Year',
                      keyboardType: TextInputType.number,
                      enabled: !_isCurrent,
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
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Currently studying here',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
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
              _field(
                _descCtrl,
                Icons.notes_outlined,
                'Description (optional)',
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _loading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryCyan,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.black,
                        ),
                      )
                    : Text(
                        _isEdit ? 'UPDATE' : 'ADD EDUCATION',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
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
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool enabled = true,
  }) => TextFormField(
    controller: ctrl,
    keyboardType: keyboardType,
    validator: validator,
    maxLines: maxLines,
    enabled: enabled,
    style: const TextStyle(color: Colors.white),
    decoration: buildInputDecoration(icon: icon, label: label),
  );
}
