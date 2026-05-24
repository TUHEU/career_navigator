import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/remote/grok_stream_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/ai_response_widget.dart';

class NetworkOutreachPage extends StatefulWidget {
  const NetworkOutreachPage({super.key});
  @override
  State<NetworkOutreachPage> createState() => _NetworkOutreachPageState();
}

class _NetworkOutreachPageState extends State<NetworkOutreachPage> {
  final _myRoleCtrl = TextEditingController();
  final _myGoalCtrl = TextEditingController();
  final _targetNameCtrl = TextEditingController();
  final _targetRoleCtrl = TextEditingController();
  final _targetCompCtrl = TextEditingController();
  final _commonGroundCtrl = TextEditingController();

  bool _isStreaming = false;
  bool _hasResult = false;
  String _result = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        _myRoleCtrl.text = user.currentJobTitle ?? user.headline ?? '';
      }
    });
  }

  @override
  void dispose() {
    _myRoleCtrl.dispose();
    _myGoalCtrl.dispose();
    _targetNameCtrl.dispose();
    _targetRoleCtrl.dispose();
    _targetCompCtrl.dispose();
    _commonGroundCtrl.dispose();
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
        '''You are a professional networking expert. Generate personalized outreach messages.

MY PROFILE:
- My Role: ${_myRoleCtrl.text.trim().isEmpty ? 'Professional' : _myRoleCtrl.text.trim()}
- My Networking Goal: ${_myGoalCtrl.text.trim()}

TARGET PERSON:
- Name: ${_targetNameCtrl.text.trim().isEmpty ? 'Not specified' : _targetNameCtrl.text.trim()}
- Role: ${_targetRoleCtrl.text.trim()}
- Company: ${_targetCompCtrl.text.trim().isEmpty ? 'Not specified' : _targetCompCtrl.text.trim()}
- Common Ground: ${_commonGroundCtrl.text.trim().isEmpty ? 'None specified' : _commonGroundCtrl.text.trim()}

Provide:
1. Why This Connection Is Valuable
2. LinkedIn/Email Outreach Message (ready to send, under 150 words, NOT generic)
3. Follow-up Message (if no response after 1 week)
4. 3 Conversation Starters to deepen the relationship
5. Value Exchange — what can I offer in return?

Be genuine, not salesy.''';

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
        title: const Text('Network Outreach AI'),
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
                color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.people_outline,
                      color: const Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outreach Generator',
                          style: TextStyle(
                            color: AppColors.text(isDark),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Build meaningful professional relationships with AI-crafted messages',
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
            _label('My Current Role', isDark),
            _field(
              _myRoleCtrl,
              'e.g. Junior Flutter Developer',
              Icons.work_outline,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('My Networking Goal *', isDark),
            _field(
              _myGoalCtrl,
              'e.g. Find a mentor in AI, get referral at Google',
              Icons.flag_outlined,
              isDark,
              maxLines: 2,
            ),
            const SizedBox(height: 14),

            _label('Their Name (optional)', isDark),
            _field(
              _targetNameCtrl,
              'e.g. Sarah Johnson',
              Icons.badge_outlined,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Their Role / Title *', isDark),
            _field(
              _targetRoleCtrl,
              'e.g. Senior AI Engineer at OpenAI',
              Icons.work_outline,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Their Company', isDark),
            _field(
              _targetCompCtrl,
              'e.g. Google, Meta, startup',
              Icons.business_outlined,
              isDark,
            ),
            const SizedBox(height: 14),

            _label('Common Ground', isDark),
            _field(
              _commonGroundCtrl,
              'e.g. Same university, commented on their post',
              Icons.connect_without_contact_outlined,
              isDark,
              maxLines: 2,
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
                    : const Icon(Icons.send_outlined, size: 18),
                label: Text(
                  _isStreaming
                      ? 'Grok is writing...'
                      : 'Generate Outreach Message',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
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
              title: 'Your Outreach Strategy',
              accentColor: const Color(0xFF2563EB),
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
