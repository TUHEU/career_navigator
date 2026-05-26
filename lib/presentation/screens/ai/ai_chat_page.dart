// presentation/screens/ai/ai_chat_page.dart
// Unified AI Career Assistant — one chat interface with all features:
// • Free chat with career AI
// • /career   — Career path analysis
// • /salary   — Salary negotiation
// • /switch   — Career change simulation
// • /network  — Network outreach message
// • /review   — Performance review coach
// • /skills   — Skill assessment quiz
// • /jobs     — Job recommendations based on profile
// Language-aware, streams responses, copy/share support

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/datasources/remote/grok_stream_service.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../skills/skill_assessment_page.dart';

// ── Message model ─────────────────────────────────────────────
class _Msg {
  final bool   isUser;
  final String text;
  final bool   isStreaming;
  final Color  accentColor;

  const _Msg({
    required this.isUser,
    required this.text,
    this.isStreaming  = false,
    this.accentColor  = AppColors.primaryCyan,
  });

  _Msg copyWith({String? text, bool? isStreaming}) => _Msg(
    isUser:      isUser,
    text:        text        ?? this.text,
    isStreaming: isStreaming  ?? this.isStreaming,
    accentColor: accentColor,
  );
}

// ── Quick-action commands ─────────────────────────────────────
class _Command {
  final String label;
  final String hint;
  final IconData icon;
  final Color  color;
  final String systemPrompt;
  final String placeholder;

  const _Command({
    required this.label,
    required this.hint,
    required this.icon,
    required this.color,
    required this.systemPrompt,
    required this.placeholder,
  });
}

const List<_Command> _commands = [
  _Command(
    label: '🗺️ Career Path',
    hint:  '/career',
    icon:  Icons.psychology_outlined,
    color: AppColors.primaryCyan,
    systemPrompt: 'You are an expert career advisor. Analyze the user\'s skills, '
        'experience and interests to suggest 3 personalized career paths with '
        'required skills, salary ranges, growth prospects, and step-by-step roadmaps.',
    placeholder: 'Describe your skills, experience, and what kind of work excites you...',
  ),
  _Command(
    label: '💰 Salary Negotiation',
    hint:  '/salary',
    icon:  Icons.monetization_on_outlined,
    color: Color(0xFF059669),
    systemPrompt: 'You are an expert salary negotiation coach. Help the user '
        'negotiate their compensation. Provide market data, specific scripts, '
        'counter-offer strategies, and tips for their level and location.',
    placeholder: 'Share your role, current offer, years of experience, and location...',
  ),
  _Command(
    label: '🔄 Career Switch',
    hint:  '/switch',
    icon:  Icons.compare_arrows_rounded,
    color: Color(0xFF7C3AED),
    systemPrompt: 'You are a career transition specialist. Simulate career paths '
        'with projected salary, required skills, transition timeline, satisfaction '
        'score, and actionable first steps for each option.',
    placeholder: 'Tell me your current role and up to 3 roles you\'re considering switching to...',
  ),
  _Command(
    label: '🤝 Network Outreach',
    hint:  '/network',
    icon:  Icons.connect_without_contact_rounded,
    color: Color(0xFFF59E0B),
    systemPrompt: 'You are a professional networking expert. Write compelling, '
        'personalized outreach messages for LinkedIn or email that get responses. '
        'Make them warm, specific, and value-focused.',
    placeholder: 'Describe who you want to reach out to and your goal...',
  ),
  _Command(
    label: '⭐ Review Coach',
    hint:  '/review',
    icon:  Icons.rate_review_outlined,
    color: Color(0xFFEF4444),
    systemPrompt: 'You are a performance review expert. Help the user write '
        'impactful self-assessments that highlight achievements with metrics, '
        'demonstrate leadership, and position them for promotion.',
    placeholder: 'Describe your role, accomplishments this year, and your goal (raise/promotion)...',
  ),
  _Command(
    label: '💡 Job Recommendations',
    hint:  '/jobs',
    icon:  Icons.work_outline_rounded,
    color: Color(0xFF06B6D4),
    systemPrompt: 'You are a job matching expert. Based on the user\'s background, '
        'recommend 5 specific job titles and roles that suit them perfectly, '
        'with reasons, required skills, salary expectations, and where to find them.',
    placeholder: 'Describe your experience, skills, education, and what you\'re looking for...',
  ),
];

// ── Main Page ─────────────────────────────────────────────────
class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});
  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage>
    with TickerProviderStateMixin {
  final _inputCtrl   = TextEditingController();
  final _scrollCtrl  = ScrollController();
  final List<_Msg>   _messages = [];

  bool        _isStreaming  = false;
  _Command?   _activeCmd;
  late AnimationController _sendBtnCtrl;
  late Animation<double>   _sendBtnScale;

  @override
  void initState() {
    super.initState();
    _sendBtnCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 100));
    _sendBtnScale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _sendBtnCtrl, curve: Curves.easeOut));

    // Welcome message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      final name = user?.displayName?.split(' ').first ?? 'there';
      _addAI(
        'Hi $name! 👋 I\'m your AI Career Assistant.\n\n'
        'I can help you with:\n'
        '• Career path analysis and planning\n'
        '• Salary negotiation strategies\n'
        '• Career change simulations\n'
        '• Network outreach messages\n'
        '• Performance review coaching\n'
        '• Job recommendations\n\n'
        'Use the quick buttons below or just type your question!',
      );
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    _sendBtnCtrl.dispose();
    super.dispose();
  }

  void _addAI(String text, {bool streaming = false, Color? color}) {
    setState(() => _messages.add(_Msg(
      isUser:      false,
      text:        text,
      isStreaming: streaming,
      accentColor: color ?? AppColors.primaryCyan,
    )));
    _scrollToBottom();
  }

  void _updateLastAI(String text, {bool streaming = true}) {
    if (_messages.isEmpty) return;
    setState(() {
      final last = _messages.last;
      _messages[_messages.length - 1] =
          last.copyWith(text: text, isStreaming: streaming);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _isStreaming) return;

    _inputCtrl.clear();

    // User message
    setState(() => _messages.add(_Msg(isUser: true, text: text)));
    _scrollToBottom();

    // Check for skill assessment command
    if (text.toLowerCase().startsWith('/skills') ||
        text.toLowerCase().contains('skill assessment') ||
        text.toLowerCase().contains('test my skills')) {
      await Future.delayed(const Duration(milliseconds: 300));
      _addAI('Opening Skill Assessment for you! 🎯');
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SkillAssessmentPage()));
      }
      return;
    }

    final cmd    = _activeCmd;
    final sysP   = cmd?.systemPrompt ??
        'You are a professional career advisor AI assistant. '
        'Give practical, actionable career advice. Be concise and helpful.';
    final color  = cmd?.color ?? AppColors.primaryCyan;

    setState(() => _isStreaming = true);
    _addAI('', streaming: true, color: color);

    String response = '';

    await GrokStreamService.stream(
      prompt:       text,
      systemPrompt: sysP,
      maxTokens:    1200,
      onChunk: (chunk) {
        response += chunk;
        _updateLastAI(response, streaming: true);
      },
      onDone: () {
        _updateLastAI(response, streaming: false);
        setState(() {
          _isStreaming  = false;
          _activeCmd    = null;
        });
      },
      onError: (err) {
        _updateLastAI('⚠️ $err', streaming: false);
        setState(() { _isStreaming = false; _activeCmd = null; });
      },
    );
  }

  void _selectCommand(_Command cmd) {
    setState(() => _activeCmd = cmd);
    _inputCtrl.text = '';
    FocusScope.of(context).requestFocus(FocusNode());
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(cmd.icon, color: Colors.white, size: 16),
        const SizedBox(width: 8),
        Text('${cmd.label} mode activated'),
      ]),
      backgroundColor: cmd.color,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final lang   = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        backgroundColor: AppColors.surface(isDark),
        elevation: 0,
        title: Row(children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withValues(alpha: 0.12),
              shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome,
                color: AppColors.primaryCyan, size: 18),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(lang.t(S.aiHub), style: TextStyle(
              color: AppColors.text(isDark),
              fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Career AI Assistant', style: TextStyle(
              color: AppColors.textMuted(isDark), fontSize: 11)),
          ]),
        ]),
        iconTheme: IconThemeData(color: AppColors.text(isDark)),
        actions: [
          // Clear chat
          if (_messages.length > 1)
            IconButton(
              icon: Icon(Icons.delete_outline,
                  color: AppColors.textMuted(isDark), size: 20),
              onPressed: () => setState(() {
                _messages.clear();
                _activeCmd = null;
              }),
              tooltip: 'Clear chat',
            ),
        ],
      ),
      body: Column(children: [

        // ── Active command indicator ──────────────────────
        if (_activeCmd != null)
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            color: _activeCmd!.color.withValues(alpha: 0.08),
            child: Row(children: [
              Icon(_activeCmd!.icon,
                  color: _activeCmd!.color, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(
                '${_activeCmd!.label} — ${_activeCmd!.placeholder}',
                style: TextStyle(color: _activeCmd!.color,
                    fontSize: 12),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              )),
              GestureDetector(
                onTap: () => setState(() => _activeCmd = null),
                child: Icon(Icons.close,
                    color: _activeCmd!.color, size: 16),
              ),
            ]),
          ),

        // ── Messages ──────────────────────────────────────
        Expanded(child: _messages.isEmpty
            ? _EmptyState(isDark: isDark)
            : ListView.builder(
                controller: _scrollCtrl,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (_, i) => _MessageBubble(
                  msg: _messages[i],
                  isDark: isDark,
                ),
              ),
        ),

        // ── Quick command chips ────────────────────────────
        Container(
          height: 46,
          color: AppColors.surface(isDark),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8),
            itemCount: _commands.length + 1, // +1 for skills
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              if (i == _commands.length) {
                // Skill Assessment special chip
                return _CmdChip(
                  label: '🧠 Skill Test',
                  color: const Color(0xFFEC4899),
                  isActive: false,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const SkillAssessmentPage())),
                );
              }
              final cmd = _commands[i];
              return _CmdChip(
                label:    cmd.label,
                color:    cmd.color,
                isActive: _activeCmd == cmd,
                onTap:    () => _selectCommand(cmd),
              );
            },
          ),
        ),

        // ── Input bar ─────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          decoration: BoxDecoration(
            color: AppColors.surface(isDark),
            border: Border(top: BorderSide(
                color: AppColors.border(isDark))),
          ),
          child: SafeArea(
            top: false,
            child: Row(children: [
              Expanded(child: Container(
                decoration: BoxDecoration(
                  color: AppColors.inputFill(isDark),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _activeCmd != null
                        ? _activeCmd!.color.withValues(alpha: 0.5)
                        : AppColors.border(isDark),
                    width: _activeCmd != null ? 1.5 : 1,
                  ),
                ),
                child: Row(children: [
                  Expanded(child: TextField(
                    controller: _inputCtrl,
                    enabled:    !_isStreaming,
                    maxLines:   4, minLines: 1,
                    style: TextStyle(
                        color: AppColors.text(isDark), fontSize: 14),
                    decoration: InputDecoration(
                      hintText: _activeCmd?.placeholder
                          ?? 'Ask anything about your career...',
                      hintStyle: TextStyle(
                          color: AppColors.textMuted(isDark),
                          fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _send(),
                  )),
                  if (_isStreaming)
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _activeCmd?.color ??
                              AppColors.primaryCyan,
                        ),
                      ),
                    ),
                ]),
              )),
              const SizedBox(width: 8),

              // Send button
              GestureDetector(
                onTapDown: (_) => _sendBtnCtrl.forward(),
                onTapUp:   (_) {
                  _sendBtnCtrl.reverse();
                  _send();
                },
                onTapCancel: () => _sendBtnCtrl.reverse(),
                child: ScaleTransition(
                  scale: _sendBtnScale,
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isStreaming
                            ? [Colors.grey.shade600, Colors.grey.shade700]
                            : [
                                _activeCmd?.color ?? AppColors.primaryCyan,
                                (_activeCmd?.color ?? AppColors.primaryCyan)
                                    .withValues(alpha: 0.7),
                              ],
                        begin: Alignment.topLeft,
                        end:   Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(
                        color: (_activeCmd?.color ?? AppColors.primaryCyan)
                            .withValues(alpha: _isStreaming ? 0 : 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )],
                    ),
                    child: Icon(
                      _isStreaming
                          ? Icons.hourglass_empty_rounded
                          : Icons.send_rounded,
                      color: Colors.white, size: 18),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Message bubble ─────────────────────────────────────────────
class _MessageBubble extends StatefulWidget {
  final _Msg msg; final bool isDark;
  const _MessageBubble({required this.msg, required this.isDark});
  @override State<_MessageBubble> createState() => _MessageBubbleState();
}
class _MessageBubbleState extends State<_MessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _cursorCtrl;
  late Animation<double>   _cursorAnim;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _cursorCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 500))..repeat(reverse: true);
    _cursorAnim = Tween<double>(begin: 0, end: 1).animate(_cursorCtrl);
  }
  @override void dispose() { _cursorCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final msg     = widget.msg;
    final isDark  = widget.isDark;
    final isUser  = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // AI avatar
          if (!isUser) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: msg.accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: msg.accentColor.withValues(alpha: 0.3))),
              child: Icon(Icons.auto_awesome,
                  color: msg.accentColor, size: 16),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(child: Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [

              // Bubble
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isUser ? LinearGradient(colors: [
                    AppColors.primaryCyan,
                    AppColors.primaryCyan.withValues(alpha: 0.8),
                  ]) : null,
                  color: isUser ? null : AppColors.card(isDark),
                  borderRadius: BorderRadius.only(
                    topLeft:     const Radius.circular(18),
                    topRight:    const Radius.circular(18),
                    bottomLeft:  Radius.circular(isUser ? 18 : 4),
                    bottomRight: Radius.circular(isUser ? 4  : 18),
                  ),
                  border: isUser ? null : Border.all(
                    color: msg.isStreaming
                        ? msg.accentColor.withValues(alpha: 0.4)
                        : AppColors.border(isDark),
                    width: msg.isStreaming ? 1.5 : 1,
                  ),
                  boxShadow: isUser ? [BoxShadow(
                    color: AppColors.primaryCyan.withValues(alpha: 0.25),
                    blurRadius: 8, offset: const Offset(0, 2),
                  )] : null,
                ),
                child: msg.text.isEmpty && msg.isStreaming
                    ? _TypingIndicator(color: msg.accentColor)
                    : RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: isUser ? Colors.black : AppColors.text(isDark),
                            fontSize: 14, height: 1.6),
                          children: [
                            TextSpan(text: msg.text),
                            if (msg.isStreaming)
                              WidgetSpan(child: AnimatedBuilder(
                                animation: _cursorAnim,
                                builder: (_, __) => Opacity(
                                  opacity: _cursorAnim.value,
                                  child: Text('▋', style: TextStyle(
                                    color: msg.accentColor, fontSize: 14)),
                                ),
                              )),
                          ],
                        ),
                      ),
              ),

              // Copy button for AI messages
              if (!isUser && !msg.isStreaming && msg.text.isNotEmpty) ...[
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: msg.text));
                    setState(() => _copied = true);
                    Future.delayed(const Duration(seconds: 2),
                        () { if (mounted) setState(() => _copied = false); });
                  },
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(
                      _copied ? Icons.check : Icons.copy_outlined,
                      size: 12,
                      color: _copied ? Colors.green : AppColors.textMuted(isDark)),
                    const SizedBox(width: 4),
                    Text(
                      _copied ? 'Copied!' : 'Copy',
                      style: TextStyle(
                        fontSize: 11,
                        color: _copied ? Colors.green : AppColors.textMuted(isDark)),
                    ),
                  ]),
                ),
              ],
            ],
          )),

          // User avatar
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.primaryCyan.withValues(alpha: 0.15),
                shape: BoxShape.circle),
              child: const Icon(Icons.person,
                  color: AppColors.primaryCyan, size: 18),
            ),
          ],
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  final Color color;
  const _TypingIndicator({required this.color});
  @override State<_TypingIndicator> createState() => _TypingIndicatorState();
}
class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200))..repeat();
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, __) => Row(mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final delay = i / 3;
        final val = ((_c.value - delay) % 1.0).clamp(0.0, 1.0);
        final opacity = val < 0.5 ? val * 2 : (1 - val) * 2;
        return Container(
          width: 7, height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.3 + opacity * 0.7),
            shape: BoxShape.circle),
        );
      }),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryCyan.withValues(alpha: 0.08),
          shape: BoxShape.circle,
          border: Border.all(
              color: AppColors.primaryCyan.withValues(alpha: 0.2), width: 1.5)),
        child: const Icon(Icons.auto_awesome,
            color: AppColors.primaryCyan, size: 44),
      ),
      const SizedBox(height: 16),
      Text('AI Career Assistant', style: TextStyle(
        color: AppColors.text(isDark),
        fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Select a tool or ask anything',
          style: TextStyle(color: AppColors.textMuted(isDark))),
    ],
  ));
}

class _CmdChip extends StatelessWidget {
  final String   label;
  final Color    color;
  final bool     isActive;
  final VoidCallback onTap;
  const _CmdChip({required this.label, required this.color,
      required this.isActive, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? color : color.withValues(alpha: 0.3),
            width: isActive ? 1.5 : 1)),
        child: Text(label, style: TextStyle(
          color: isActive ? Colors.white : color,
          fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
