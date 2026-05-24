import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/datasources/remote/grok_stream_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/ai_response_widget.dart';

class CareerPathAnalyzerPage extends StatefulWidget {
  const CareerPathAnalyzerPage({super.key});
  @override
  State<CareerPathAnalyzerPage> createState() => _CareerPathAnalyzerPageState();
}

class _CareerPathAnalyzerPageState extends State<CareerPathAnalyzerPage> {
  final _skillsCtrl = TextEditingController();
  final _interestsCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();

  bool _isStreaming = false;
  bool _hasResult = false;
  String _result = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        if (user.expertiseAreas != null && user.expertiseAreas!.isNotEmpty) {
          _skillsCtrl.text = user.expertiseAreas!.join(', ');
        }
        if (user.yearsOfExperience != null) {
          final t = user.currentJobTitle ?? user.headline ?? '';
          _experienceCtrl.text = t.isNotEmpty
              ? '${user.yearsOfExperience} years — $t'
              : '${user.yearsOfExperience} years of experience';
        }
      }
    });
  }

  @override
  void dispose() {
    _skillsCtrl.dispose();
    _interestsCtrl.dispose();
    _experienceCtrl.dispose();
    _educationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isStreaming) return;
    setState(() {
      _isStreaming = true;
      _result = '';
      _hasResult = false;
    });

    final prompt =
        '''You are a career advisor AI. Analyze this professional profile and suggest 3 personalized career paths.

Skills: ${_skillsCtrl.text.trim().isEmpty ? 'Not specified' : _skillsCtrl.text.trim()}
Interests: ${_interestsCtrl.text.trim().isEmpty ? 'Not specified' : _interestsCtrl.text.trim()}
Experience: ${_experienceCtrl.text.trim().isEmpty ? 'Not specified' : _experienceCtrl.text.trim()}
Education: ${_educationCtrl.text.trim().isEmpty ? 'Not specified' : _educationCtrl.text.trim()}

For each career path provide:
1. Path title
2. Why it matches their profile (2-3 sentences)
3. Required skills to develop
4. Expected salary range
5. Growth potential (High/Medium/Low)
6. First concrete step to take

Format clearly with headers for each path. Be specific and actionable.''';

    GrokStreamService.stream(
      prompt: prompt,
      onChunk: (chunk) {
        if (mounted) setState(() => _result += chunk);
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _isStreaming = false;
            _hasResult = true;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _result = 'Error: $error';
            _isStreaming = false;
            _hasResult = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: const Text('Career Path Analyzer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00B8D4).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF00B8D4).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B8D4).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.psychology_outlined,
                      color: const Color(0xFF00B8D4),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Career Advisor',
                          style: TextStyle(
                            color: AppColors.text(isDark),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Discover career paths that match your unique profile',
                          style: TextStyle(
                            color: AppColors.textSecondary(isDark),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Fields
            _label('Your Skills', isDark),
            _field(
              _skillsCtrl,
              'e.g. Python, Flutter, SQL, Communication',
              Icons.code_outlined,
              isDark,
              maxLines: 2,
            ),
            const SizedBox(height: 14),

            _label('Your Interests', isDark),
            _field(
              _interestsCtrl,
              'e.g. AI, Mobile apps, Finance, Teaching',
              Icons.favorite_outline,
              isDark,
              maxLines: 2,
            ),
            const SizedBox(height: 14),

            _label('Experience', isDark),
            _field(
              _experienceCtrl,
              'e.g. 3 years as backend developer at startups',
              Icons.work_outline,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Education', isDark),
            _field(
              _educationCtrl,
              'e.g. BSc Computer Science, self-taught mobile dev',
              Icons.school_outlined,
              isDark,
            ),
            const SizedBox(height: 14),
            const SizedBox(height: 10),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isStreaming ? null : _submit,
                icon: _isStreaming
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(
                  _isStreaming
                      ? 'Grok is analyzing...'
                      : 'Analyze My Career Paths',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B8D4),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Streaming result
            AIResponseWidget(
              text: _result,
              isStreaming: _isStreaming,
              hasResult: _hasResult,
              title: 'Your Personalized Career Paths',
              accentColor: const Color(0xFF00B8D4),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _label(String text, bool isDark) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: TextStyle(
        color: AppColors.text(isDark),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    bool isDark, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) => TextField(
    controller: ctrl,
    maxLines: maxLines,
    keyboardType: keyboardType,
    style: TextStyle(color: AppColors.text(isDark), fontSize: 13),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.textMuted(isDark), fontSize: 12),
      prefixIcon: Icon(icon, color: AppColors.primaryCyan, size: 18),
      filled: true,
      fillColor: AppColors.inputFill(isDark),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border(isDark)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryCyan, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      alignLabelWithHint: true,
    ),
  );
}
