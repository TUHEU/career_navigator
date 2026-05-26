import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/remote/grok_stream_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/ai_response_widget.dart';

class CareerChangeSimulatorPage extends StatefulWidget {
  const CareerChangeSimulatorPage({super.key});
  @override
  State<CareerChangeSimulatorPage> createState() =>
      _CareerChangeSimulatorPageState();
}

class _CareerChangeSimulatorPageState extends State<CareerChangeSimulatorPage> {
  final _currentRoleCtrl = TextEditingController();
  final _currentSalCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _targetRole1Ctrl = TextEditingController();
  final _targetRole2Ctrl = TextEditingController();
  final _targetRole3Ctrl = TextEditingController();

  bool _isStreaming = false;
  bool _hasResult = false;
  String _result = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _currentRoleCtrl.dispose();
    _currentSalCtrl.dispose();
    _locationCtrl.dispose();
    _targetRole1Ctrl.dispose();
    _targetRole2Ctrl.dispose();
    _targetRole3Ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isStreaming) return;
    setState(() {
      _isStreaming = true;
      _result = '';
      _hasResult = false;
    });

    final prompt = () {
      final targets = [
        _targetRole1Ctrl.text.trim(),
        _targetRole2Ctrl.text.trim(),
        _targetRole3Ctrl.text.trim(),
      ].where((t) => t.isNotEmpty).toList();
      return '''You are a career strategist. Simulate ${targets.length} career path change(s).

Current Role: ${_currentRoleCtrl.text.trim()}
Current Salary: ${_currentSalCtrl.text.trim().isEmpty ? 'Not specified' : _currentSalCtrl.text.trim()}
Location: ${_locationCtrl.text.trim().isEmpty ? 'Not specified' : _locationCtrl.text.trim()}
Target Paths: ${targets.join(', ')}

For EACH target career path simulate and provide:
**[Path Name]**
📊 Projected Salary: Starting → 3 years → 5 years
📈 Growth Potential: percentage / trajectory
😊 Satisfaction Score: 1-10 with reasoning
⏱️ Transition Time: How long to make this switch
🛠️ Skills Gap: What you need to learn
💰 Salary Change: Compared to current role
🚀 First 3 Steps: Concrete actions to start today
⚠️ Risks: Main challenges

End with a recommendation of which path best balances growth, satisfaction, and feasibility.''';
    }();

    GrokStreamService.stream(
      prompt: prompt,
      onChunk: (chunk) {
        if (mounted) setState(() => _result += chunk);
      },
      onDone: () {
        if (mounted)
          setState(() {
            _isStreaming = false;
            _hasResult = true;
          });
      },
      onError: (error) {
        if (mounted)
          setState(() {
            _result = 'Error: $error';
            _isStreaming = false;
            _hasResult = false;
          });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: const Text('Career Change Simulator'),
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
                color: const Color(0xFF7C3AED).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.compare_arrows,
                      color: const Color(0xFF7C3AED),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Career Change Simulator',
                          style: TextStyle(
                            color: AppColors.text(isDark),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'See projected salary, growth & satisfaction for each path',
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
            _label('Current Role *', isDark),
            _field(
              _currentRoleCtrl,
              'e.g. Backend Python Developer',
              Icons.work_history_outlined,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Current Salary', isDark),
            _field(
              _currentSalCtrl,
              'e.g. 70,000 USD',
              Icons.attach_money,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Location', isDark),
            _field(
              _locationCtrl,
              'e.g. London',
              Icons.location_on_outlined,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Target Path 1 *', isDark),
            _field(
              _targetRole1Ctrl,
              'e.g. Product Manager',
              Icons.looks_one_outlined,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Target Path 2', isDark),
            _field(
              _targetRole2Ctrl,
              'e.g. Data Scientist',
              Icons.looks_two_outlined,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Target Path 3', isDark),
            _field(
              _targetRole3Ctrl,
              'e.g. Freelance Consultant',
              Icons.looks_3_outlined,
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
                    : const Icon(Icons.compare_arrows, size: 18),
                label: Text(
                  _isStreaming
                      ? 'Grok is simulating...'
                      : 'Simulate Career Paths',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
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
              title: 'Career Path Simulations',
              accentColor: const Color(0xFF7C3AED),
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
