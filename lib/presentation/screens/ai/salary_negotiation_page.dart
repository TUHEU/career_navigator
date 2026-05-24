import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/remote/grok_stream_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/ai_response_widget.dart';

class SalaryNegotiationPage extends StatefulWidget {
  const SalaryNegotiationPage({super.key});
  @override
  State<SalaryNegotiationPage> createState() => _SalaryNegotiationPageState();
}

class _SalaryNegotiationPageState extends State<SalaryNegotiationPage> {
  final _roleCtrl = TextEditingController();
  final _offerCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();

  bool _isStreaming = false;
  bool _hasResult = false;
  String _result = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _roleCtrl.dispose();
    _offerCtrl.dispose();
    _currencyCtrl.dispose();
    _locationCtrl.dispose();
    _experienceCtrl.dispose();
    _companyCtrl.dispose();
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
        '''You are a salary negotiation expert. Analyze this job offer and provide strategic negotiation advice.

Role: ${_roleCtrl.text.trim()}
Offer Amount: ${_offerCtrl.text.trim()} ${_currencyCtrl.text.trim()}
Location: ${_locationCtrl.text.trim().isEmpty ? 'Not specified' : _locationCtrl.text.trim()}
Years of Experience: ${_experienceCtrl.text.trim().isEmpty ? 'Not specified' : _experienceCtrl.text.trim()}
Company: ${_companyCtrl.text.trim().isEmpty ? 'Not specified' : _companyCtrl.text.trim()}

Provide:
1. **Market Analysis** — Is this offer competitive? Typical range for this role?
2. **Counter-offer Strategy** — Specific counter-offer amount with reasoning
3. **Negotiation Script** — Exact words to use when countering
4. **Beyond Salary** — Other benefits to negotiate (equity, remote, PTO, signing bonus)
5. **Risk Assessment** — Likelihood of offer being withdrawn if you counter
6. **Red Lines** — What is the minimum you should accept?

Be direct, specific, and tactical. Give real numbers.''';

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
        title: const Text('Salary Negotiation'),
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
                color: const Color(0xFF059669).withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF059669).withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.monetization_on_outlined,
                      color: const Color(0xFF059669),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Negotiation Advisor',
                          style: TextStyle(
                            color: AppColors.text(isDark),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Maximize your compensation without risking the offer',
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
            _label('Job Role *', isDark),
            _field(
              _roleCtrl,
              'e.g. Senior Flutter Developer',
              Icons.work_outline,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Offer Amount *', isDark),
            _field(
              _offerCtrl,
              'e.g. 85000',
              Icons.attach_money,
              isDark,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),

            _label('Currency', isDark),
            _field(_currencyCtrl, 'USD', Icons.currency_exchange, isDark),
            const SizedBox(height: 14),

            _label('Location / Market', isDark),
            _field(
              _locationCtrl,
              'e.g. New York, USA or Remote',
              Icons.location_on_outlined,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Years of Experience', isDark),
            _field(
              _experienceCtrl,
              'e.g. 5 years',
              Icons.timeline_outlined,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Company (optional)', isDark),
            _field(
              _companyCtrl,
              'e.g. Google, startup, SME',
              Icons.business_outlined,
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
                    : const Icon(Icons.balance, size: 18),
                label: Text(
                  _isStreaming
                      ? 'Grok is analyzing...'
                      : 'Get Negotiation Strategy',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
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
              title: 'Your Negotiation Strategy',
              accentColor: const Color(0xFF059669),
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
