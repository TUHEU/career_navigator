import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/user_provider.dart';
import '../dashboard/job_seeker_dashboard.dart';
import 'questionnaire_service.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  // Each step has its OWN form key so validate() only touches that step
  final _step1Key = GlobalKey<FormState>(); // Education — has validators
  // Steps 2, 3, 4 have NO required validators — no form key needed

  int _currentStep = 0;
  bool _isLoading = false;

  // ── Step 1 — Education ────────────────────────────────────
  String _educationLevel = "Bachelor's";
  final _fieldController = TextEditingController();

  // ── Step 2 — Interests ────────────────────────────────────
  final List<String> _allInterests = [
    'Software Engineering',
    'Data Science',
    'Finance',
    'Healthcare',
    'Marketing',
    'Education',
    'Design',
    'Business',
    'DevOps',
    'Mobile Development',
  ];
  final List<String> _selectedInterests = [];

  // ── Step 3 — Skills ───────────────────────────────────────
  final _skillController = TextEditingController();
  final List<String> _skills = [];

  // ── Step 4 — Preferences ──────────────────────────────────
  String _jobType = 'full_time';
  String _workMode = 'onsite';
  final _locationController = TextEditingController();

  // ── Dispose ───────────────────────────────────────────────
  @override
  void dispose() {
    _fieldController.dispose();
    _skillController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // ── Add skill chip ────────────────────────────────────────
  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  // ── Next button logic ─────────────────────────────────────
  // FIX: only validate on step 1 which actually has validators.
  // Steps 2, 3, 4 just increment the step directly — no validate() call.
  void _onNext() {
    if (_currentStep == 0) {
      // Step 1 — Education: validate the form
      if (_step1Key.currentState?.validate() ?? false) {
        setState(() => _currentStep++);
      }
    } else if (_currentStep < 3) {
      // Steps 2 & 3 — no validation needed, just advance
      setState(() => _currentStep++);
    } else {
      // Step 4 — final step, submit
      _submit();
    }
  }

  // ── Submit ────────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final userProvider = context.read<UserProvider>();
      final fields = <String, dynamic>{
        'desired_job_title': _selectedInterests.isNotEmpty
            ? _selectedInterests.first
            : '',
        'availability': _workMode,
      };
      if (_skills.isNotEmpty) fields['skills'] = _skills;
      if (_selectedInterests.isNotEmpty) {
        fields['interests'] = _selectedInterests;
      }
      if (_locationController.text.trim().isNotEmpty) {
        fields['location'] = _locationController.text.trim();
      }

      await userProvider.updateJobSeekerProfile(fields);
      await QuestionnaireService.markCompleted();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const JobSeekerDashboard()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Something went wrong: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Step widgets ──────────────────────────────────────────

  // Step 1 — wrapped in its own Form so validate() is scoped to it only
  Widget _educationStep() => Form(
    key: _step1Key,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Education Level',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _educationLevel,
          items: [
            "High School",
            "Diploma",
            "Bachelor's",
            "Master's",
            "PhD",
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _educationLevel = v!),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        const SizedBox(height: 16),
        const Text(
          'Field of Study',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _fieldController,
          decoration: const InputDecoration(
            hintText: 'e.g. Computer Science',
            border: OutlineInputBorder(),
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Field of study is required'
              : null,
        ),
      ],
    ),
  );

  // Step 2 — plain widget, NO Form, NO validators
  Widget _interestsStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Select your career interests',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(
        'Choose as many as you like',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
      ),
      const SizedBox(height: 16),
      Wrap(
        spacing: 8,
        runSpacing: 10,
        children: _allInterests.map((interest) {
          final selected = _selectedInterests.contains(interest);
          return FilterChip(
            label: Text(interest),
            selected: selected,
            selectedColor: AppColors.primaryCyan.withOpacity(0.2),
            checkmarkColor: AppColors.primaryCyan,
            side: BorderSide(
              color: selected ? AppColors.primaryCyan : Colors.grey.shade300,
              width: selected ? 1.5 : 1,
            ),
            onSelected: (val) => setState(
              () => val
                  ? _selectedInterests.add(interest)
                  : _selectedInterests.remove(interest),
            ),
          );
        }).toList(),
      ),
    ],
  );

  // Step 3 — plain widget, NO Form, NO validators
  Widget _skillsStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Add your skills',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(
        'Type a skill and tap Add',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: _skillController,
              decoration: const InputDecoration(
                hintText: 'e.g. Python, Flutter, SQL…',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addSkill(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: _addSkill, child: const Text('Add')),
        ],
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _skills
            .map(
              (s) => Chip(
                label: Text(s),
                deleteIconColor: AppColors.primaryCyan,
                onDeleted: () => setState(() => _skills.remove(s)),
              ),
            )
            .toList(),
      ),
    ],
  );

  // Step 4 — plain widget, NO Form, NO validators
  Widget _preferencesStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Job Type', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _jobType,
        items: const [
          DropdownMenuItem(value: 'full_time', child: Text('Full-time')),
          DropdownMenuItem(value: 'part_time', child: Text('Part-time')),
          DropdownMenuItem(value: 'internship', child: Text('Internship')),
          DropdownMenuItem(value: 'contract', child: Text('Contract')),
          DropdownMenuItem(value: 'freelance', child: Text('Freelance')),
        ],
        onChanged: (v) => setState(() => _jobType = v!),
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      const SizedBox(height: 16),
      const Text('Work Mode', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _workMode,
        items: const [
          DropdownMenuItem(value: 'onsite', child: Text('Onsite')),
          DropdownMenuItem(value: 'remote', child: Text('Remote')),
          DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
        ],
        onChanged: (v) => setState(() => _workMode = v!),
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      const SizedBox(height: 16),
      const Text(
        'Preferred Location',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: _locationController,
        decoration: const InputDecoration(
          hintText: 'e.g. Yaoundé, Cameroon',
          border: OutlineInputBorder(),
        ),
      ),
    ],
  );

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final steps = [
      _educationStep(),
      _interestsStep(),
      _skillsStep(),
      _preferencesStep(),
    ];
    final titles = ['Education', 'Interests', 'Skills', 'Preferences'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tell Us About You'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // ── Progress bar ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: List.generate(
                steps.length,
                (i) => Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    decoration: BoxDecoration(
                      color: i <= _currentStep
                          ? AppColors.primaryCyan
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Step ${_currentStep + 1} of ${steps.length}: '
                '${titles[_currentStep]}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ── Step content ──────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: steps[_currentStep],
            ),
          ),

          // ── Navigation buttons ────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Row(
              children: [
                if (_currentStep > 0) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _currentStep--),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCyan,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            _currentStep < steps.length - 1
                                ? 'Next'
                                : 'Get Started',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
