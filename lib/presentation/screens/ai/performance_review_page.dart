import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/datasources/remote/grok_stream_service.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/ai_response_widget.dart';

class PerformanceReviewPage extends StatefulWidget {
  const PerformanceReviewPage({super.key});
  @override
  State<PerformanceReviewPage> createState() => _PerformanceReviewPageState();
}

class _PerformanceReviewPageState extends State<PerformanceReviewPage> {
  final _roleCtrl = TextEditingController();
  final _desiredOutcomeCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  final _accomplishCtrl = TextEditingController();
  final _metricsCtrl = TextEditingController();
  final _challengesCtrl = TextEditingController();

  bool _isStreaming = false;
  bool _hasResult = false;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _desiredOutcomeCtrl.text = 'Promotion';
  }

  @override
  void dispose() {
    _roleCtrl.dispose();
    _desiredOutcomeCtrl.dispose();
    _companyCtrl.dispose();
    _accomplishCtrl.dispose();
    _metricsCtrl.dispose();
    _challengesCtrl.dispose();
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
        '''You are an executive coach. Help this professional maximize their annual review impact.

Role: ${_roleCtrl.text.trim().isEmpty ? 'Not specified' : _roleCtrl.text.trim()}
Company: ${_companyCtrl.text.trim().isEmpty ? 'Not specified' : _companyCtrl.text.trim()}
Desired Outcome: ${_desiredOutcomeCtrl.text.trim()}

Accomplishments:
${_accomplishCtrl.text.trim()}

Metrics:
${_metricsCtrl.text.trim().isEmpty ? 'None provided' : _metricsCtrl.text.trim()}

Challenges Overcome:
${_challengesCtrl.text.trim().isEmpty ? 'None provided' : _challengesCtrl.text.trim()}

Provide:
1. **Reframed Accomplishments** — Rewrite using STAR method with impact language
2. **Power Phrases** — 5 specific phrases showing leadership and business impact
3. **Self-Review Script** — Compelling 2-minute verbal summary for the meeting
4. **Promotion/Raise Case** — Why a ${_desiredOutcomeCtrl.text.trim()} is justified
5. **Weak Spots to Address** — Common objections and how to counter them
6. **Next Steps to Commit To** — 3 forward-looking commitments

Use confident, professional language. Focus on business impact, not tasks.''';

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
        title: const Text('Performance Review Coach'),
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
                color: const Color(0xFFDC2626).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.emoji_events_outlined,
                      color: const Color(0xFFDC2626),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review Coach',
                          style: TextStyle(
                            color: AppColors.text(isDark),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Transform your work into a compelling case for promotion',
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
            _label('Your Role', isDark),
            _field(
              _roleCtrl,
              'e.g. Senior Developer',
              Icons.work_outline,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Desired Outcome', isDark),
            _field(
              _desiredOutcomeCtrl,
              'e.g. Promotion, 20% raise',
              Icons.trending_up,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Company (optional)', isDark),
            _field(
              _companyCtrl,
              'e.g. Tech startup, Fortune 500',
              Icons.business_outlined,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Your Accomplishments *', isDark),
            _field(
              _accomplishCtrl,
              'e.g. Led migration, mentored 2 juniors, reduced load time by 40%',
              Icons.checklist_outlined,
              isDark,
              maxLines: 6,
            ),
            const SizedBox(height: 14),

            _label('Metrics & Numbers', isDark),
            _field(
              _metricsCtrl,
              'e.g. 40% faster, 25% fewer bugs, \$50k saved',
              Icons.bar_chart_outlined,
              isDark,
              maxLines: 3,
            ),
            const SizedBox(height: 14),

            _label('Challenges Overcome', isDark),
            _field(
              _challengesCtrl,
              'e.g. Delivered despite team being short-staffed',
              Icons.shield_outlined,
              isDark,
              maxLines: 3,
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
                      ? 'Grok is preparing your case...'
                      : 'Prepare My Review',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
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
              title: 'Your Review Strategy',
              accentColor: const Color(0xFFDC2626),
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
