// presentation/screens/questionnaire/questionnaire_screen.dart
// FIX 1: Removed ValueKey on ScrollView — was crashing on Step 2 Next tap
// FIX 2: All text/input colors are theme-aware (visible in both dark + light mode)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/user_provider.dart';
import '../dashboard/job_seeker_dashboard.dart';
import 'questionnaire_service.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});
  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _step1Key = GlobalKey<FormState>();
  int  _step      = 0;
  bool _loading   = false;

  // Step 1
  String _eduLevel = "Bachelor's";
  final _fieldCtrl = TextEditingController();
  // Step 2
  final List<String> _allInterests = [
    'Software Engineering','Data Science','Finance','Healthcare',
    'Marketing','Education','Design','Business','DevOps','Mobile Development',
  ];
  final List<String> _selectedInterests = [];
  // Step 3
  final _skillCtrl = TextEditingController();
  final List<String> _skills = [];
  // Step 4
  String _jobType  = 'full_time';
  String _workMode = 'onsite';
  final _locCtrl   = TextEditingController();

  static const _titles = ['Education','Interests','Skills','Preferences'];

  @override
  void dispose() {
    _fieldCtrl.dispose(); _skillCtrl.dispose(); _locCtrl.dispose();
    super.dispose();
  }

  void _addSkill() {
    final s = _skillCtrl.text.trim();
    if (s.isNotEmpty && !_skills.contains(s)) {
      setState(() { _skills.add(s); _skillCtrl.clear(); });
    }
  }

  void _onNext() {
    if (_step == 0) {
      if (_step1Key.currentState?.validate() ?? false) setState(() => _step++);
    } else if (_step < 3) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  Future<void> _submit() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final up = context.read<UserProvider>();
      final f  = <String, dynamic>{'availability': _workMode};
      if (_selectedInterests.isNotEmpty) {
        f['desired_job_title'] = _selectedInterests.first;
        f['interests']         = _selectedInterests;
      }
      if (_skills.isNotEmpty)           f['skills']   = _skills;
      if (_locCtrl.text.trim().isNotEmpty) f['location'] = _locCtrl.text.trim();
      try { await up.updateJobSeekerProfile(f); } catch (_) {}
      await QuestionnaireService.markCompleted();
      if (mounted) Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => const JobSeekerDashboard()), (_) => false);
    } catch (_) {
      await QuestionnaireService.markCompleted();
      if (mounted) Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => const JobSeekerDashboard()), (_) => false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _label(String t, bool d)    => Padding(padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.text(d))));
  Widget _subtitle(String t, bool d) => Padding(padding: const EdgeInsets.only(bottom: 14),
    child: Text(t, style: TextStyle(fontSize: 13, color: AppColors.textMuted(d))));

  InputDecoration _dec(String h, bool d) => InputDecoration(
    hintText: h, hintStyle: TextStyle(color: AppColors.textMuted(d), fontSize: 13),
    filled: true, fillColor: AppColors.inputFill(d),
    border:             OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border(d))),
    focusedBorder:      OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primaryCyan, width: 1.5)),
    errorBorder:        OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDC2626))),
    focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );

  Widget _buildStep1(bool d) => Form(key: _step1Key, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label('Education Level', d),
    DropdownButtonFormField<String>(
      value: _eduLevel, dropdownColor: AppColors.surface(d),
      style: TextStyle(color: AppColors.text(d), fontSize: 14),
      items: ["High School","Diploma","Bachelor's","Master's","PhD"]
          .map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: AppColors.text(d)))))
          .toList(),
      onChanged: (v) => setState(() => _eduLevel = v!),
      decoration: _dec('', d),
    ),
    const SizedBox(height: 20),
    _label('Field of Study', d),
    TextFormField(
      controller: _fieldCtrl, style: TextStyle(color: AppColors.text(d), fontSize: 14),
      decoration: _dec('e.g. Computer Science', d),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Field of study is required' : null,
    ),
  ]));

  // FIX: No ValueKey on parent — that was causing the Step 2 crash.
  // FIX: Explicit chip colors for light mode visibility.
  Widget _buildStep2(bool d) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label('Select your career interests', d),
    _subtitle('Choose as many as you like', d),
    Wrap(spacing: 8, runSpacing: 10, children: _allInterests.map((interest) {
      final sel = _selectedInterests.contains(interest);
      return FilterChip(
        label: Text(interest, style: TextStyle(
          color: sel ? AppColors.primaryCyan : AppColors.text(d),
          fontWeight: sel ? FontWeight.w600 : FontWeight.normal, fontSize: 13,
        )),
        selected: sel,
        selectedColor: AppColors.primaryCyan.withOpacity(0.15),
        backgroundColor: AppColors.inputFill(d),
        checkmarkColor: AppColors.primaryCyan,
        side: BorderSide(color: sel ? AppColors.primaryCyan : AppColors.border(d), width: sel ? 1.5 : 1),
        onSelected: (v) => setState(() {
          if (v) _selectedInterests.add(interest); else _selectedInterests.remove(interest);
        }),
      );
    }).toList()),
  ]);

  Widget _buildStep3(bool d) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label('Add your skills', d),
    _subtitle('Type a skill and tap Add', d),
    Row(children: [
      Expanded(child: TextField(
        controller: _skillCtrl, style: TextStyle(color: AppColors.text(d), fontSize: 14),
        decoration: _dec('e.g. Python, Flutter, SQL…', d),
        onSubmitted: (_) => _addSkill(),
      )),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: _addSkill,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCyan, foregroundColor: Colors.black,
          minimumSize: const Size(0, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    ]),
    const SizedBox(height: 14),
    if (_skills.isEmpty)
      Text('No skills added yet', style: TextStyle(fontSize: 13, color: AppColors.textMuted(d), fontStyle: FontStyle.italic))
    else
      Wrap(spacing: 8, runSpacing: 8, children: _skills.map((s) => Chip(
        label: Text(s, style: TextStyle(color: AppColors.text(d), fontSize: 13)),
        backgroundColor: AppColors.inputFill(d),
        side: BorderSide(color: AppColors.border(d)),
        deleteIconColor: AppColors.primaryCyan,
        onDeleted: () => setState(() => _skills.remove(s)),
      )).toList()),
  ]);

  Widget _buildStep4(bool d) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _label('Job Type', d),
    DropdownButtonFormField<String>(
      value: _jobType, dropdownColor: AppColors.surface(d),
      style: TextStyle(color: AppColors.text(d), fontSize: 14),
      items: const [
        DropdownMenuItem(value: 'full_time',  child: Text('Full-time')),
        DropdownMenuItem(value: 'part_time',  child: Text('Part-time')),
        DropdownMenuItem(value: 'internship', child: Text('Internship')),
        DropdownMenuItem(value: 'contract',   child: Text('Contract')),
        DropdownMenuItem(value: 'freelance',  child: Text('Freelance')),
      ],
      onChanged: (v) => setState(() => _jobType = v!),
      decoration: _dec('', d),
    ),
    const SizedBox(height: 20),
    _label('Work Mode', d),
    DropdownButtonFormField<String>(
      value: _workMode, dropdownColor: AppColors.surface(d),
      style: TextStyle(color: AppColors.text(d), fontSize: 14),
      items: const [
        DropdownMenuItem(value: 'onsite', child: Text('Onsite')),
        DropdownMenuItem(value: 'remote', child: Text('Remote')),
        DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
      ],
      onChanged: (v) => setState(() => _workMode = v!),
      decoration: _dec('', d),
    ),
    const SizedBox(height: 20),
    _label('Preferred Location', d),
    TextField(
      controller: _locCtrl, style: TextStyle(color: AppColors.text(d), fontSize: 14),
      decoration: _dec('e.g. Yaoundé, Cameroon', d),
    ),
  ]);

  Widget _currentStep(bool d) {
    switch (_step) {
      case 0:  return _buildStep1(d);
      case 1:  return _buildStep2(d);
      case 2:  return _buildStep3(d);
      default: return _buildStep4(d);
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.background(d),
      appBar: AppBar(
        title: Text('Tell Us About You', style: TextStyle(color: AppColors.text(d), fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false, backgroundColor: AppColors.surface(d), elevation: 0,
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(children: List.generate(4, (i) => Expanded(child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 3), height: 6,
            decoration: BoxDecoration(
              color: i <= _step ? AppColors.primaryCyan : AppColors.border(d),
              borderRadius: BorderRadius.circular(3),
            ),
          )))),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(alignment: Alignment.centerLeft, child: Text(
            'Step ${_step + 1} of 4 — ${_titles[_step]}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text(d)),
          )),
        ),
        const SizedBox(height: 4),
        // FIX: NO ValueKey here — it was causing rebuild-during-gesture crash on Step 2
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: _currentStep(d),
        )),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          decoration: BoxDecoration(
            color: AppColors.surface(d),
            border: Border(top: BorderSide(color: AppColors.border(d))),
          ),
          child: Row(children: [
            if (_step > 0) ...[
              Expanded(child: OutlinedButton(
                onPressed: _loading ? null : () => setState(() => _step--),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.text(d),
                  side: BorderSide(color: AppColors.border(d)),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back', style: TextStyle(fontSize: 15)),
              )),
              const SizedBox(width: 12),
            ],
            Expanded(child: ElevatedButton(
              onPressed: _loading ? null : _onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCyan, foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text(_step < 3 ? 'Next →' : 'Get Started',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            )),
          ]),
        ),
      ]),
    );
  }
}
