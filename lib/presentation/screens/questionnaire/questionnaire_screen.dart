import 'package:career_navigator/presentation/screens/dashboard/job_seeker_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/questionnaire_model.dart';
import '../services/questionnaire_service.dart';
import '../dashboard/job_seeker_dashboard.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isLoading = false;

  String _educationLevel = "Bachelor's";
  final _fieldController = TextEditingController();
  final _graduationYearController = TextEditingController();

  final List<String> _allInterests = [
    'Software Engineering',
    'Data Science',
    'Finance',
    'Healthcare',
    'Marketing',
    'Education',
    'Design',
    'Business',
  ];
  final List<String> _selectedInterests = [];

  final _skillController = TextEditingController();
  final List<String> _skills = [];

  String _jobType = 'Full-time';
  String _workMode = 'Onsite';
  final _locationController = TextEditingController();

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? '';

    final data = QuestionnaireModel(
      userId: userId,
      educationLevel: _educationLevel,
      fieldOfStudy: _fieldController.text.trim(),
      graduationYear: _graduationYearController.text.trim(),
      careerInterests: _selectedInterests,
      skills: _skills,
      jobType: _jobType,
      workMode: _workMode,
      preferredLocation: _locationController.text.trim(),
      submittedAt: DateTime.now(),
    );

    final success = await QuestionnaireService.submitQuestionnaire(data);
    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const JobSeekerDashboard()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _educationStep() => Column(
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
        onChanged: (val) => setState(() => _educationLevel = val!),
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
        validator: (v) => v!.isEmpty ? 'Required' : null,
      ),
      const SizedBox(height: 16),
      const Text(
        'Graduation Year',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _graduationYearController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          hintText: 'e.g. 2024',
          border: OutlineInputBorder(),
        ),
        validator: (v) => v!.isEmpty ? 'Required' : null,
      ),
    ],
  );

  Widget _interestsStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Select your career interests',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _allInterests
            .map(
              (interest) => FilterChip(
                label: Text(interest),
                selected: _selectedInterests.contains(interest),
                onSelected: (val) => setState(
                  () => val
                      ? _selectedInterests.add(interest)
                      : _selectedInterests.remove(interest),
                ),
              ),
            )
            .toList(),
      ),
    ],
  );

  Widget _skillsStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Add your skills',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _skillController,
              decoration: const InputDecoration(
                hintText: 'e.g. Python',
                border: OutlineInputBorder(),
              ),
              onFieldSubmitted: (_) => _addSkill(),
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
                onDeleted: () => setState(() => _skills.remove(s)),
              ),
            )
            .toList(),
      ),
    ],
  );

  Widget _preferencesStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Job Type', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _jobType,
        items: [
          'Full-time',
          'Part-time',
          'Internship',
          'Contract',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (val) => setState(() => _jobType = val!),
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      const SizedBox(height: 16),
      const Text('Work Mode', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      DropdownButtonFormField<String>(
        value: _workMode,
        items: [
          'Onsite',
          'Remote',
          'Hybrid',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (val) => setState(() => _workMode = val!),
        decoration: const InputDecoration(border: OutlineInputBorder()),
      ),
      const SizedBox(height: 16),
      const Text(
        'Preferred Location',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _locationController,
        decoration: const InputDecoration(
          hintText: 'e.g. Yaoundé, Cameroon',
          border: OutlineInputBorder(),
        ),
      ),
    ],
  );

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
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(
                  steps.length,
                  (i) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 6,
                      decoration: BoxDecoration(
                        color: i <= _currentStep
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Step ${_currentStep + 1} of ${steps.length}: ${titles[_currentStep]}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: steps[_currentStep],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
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
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_currentStep < steps.length - 1) {
                                if (_formKey.currentState!.validate())
                                  setState(() => _currentStep++);
                              } else {
                                _submit();
                              }
                            },
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              _currentStep < steps.length - 1
                                  ? 'Next'
                                  : 'Submit',
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fieldController.dispose();
    _graduationYearController.dispose();
    _skillController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
