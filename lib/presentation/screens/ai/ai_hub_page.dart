// presentation/screens/ai/ai_hub_page.dart
// v9 — AI Hub landing: command cards grid, recent sessions, quick launch
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/theme_provider.dart';
import 'ai_chat_page.dart';

class AIHubPage extends StatelessWidget {
  const AIHubPage({super.key});

  static const _tools = [
    _Tool('🗺️ Career Path',      'Analyze your skills & get personalized career roadmaps',
      AppColors.primaryCyan, '/career'),
    _Tool('💰 Salary Coach',     'Market data, negotiation scripts & counter-offer strategies',
      Color(0xFF059669), '/salary'),
    _Tool('🔄 Career Switch',    'Simulate career transitions with timelines & projections',
      Color(0xFF7C3AED), '/switch'),
    _Tool('🤝 Network Outreach', 'Generate compelling outreach messages for LinkedIn & email',
      Color(0xFFF59E0B), '/network'),
    _Tool('⭐ Review Coach',     'Prepare for performance reviews with talking points & scripts',
      Color(0xFFEC4899), '/review'),
    _Tool('💬 Free Chat',        'Ask anything about your career, resume, or job search',
      AppColors.primaryCyan, ''),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(child: CustomScrollView(slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3))),
                  child: const Icon(Icons.auto_awesome,
                      color: AppColors.primaryCyan, size: 26)),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('AI Career Hub', style: TextStyle(
                    color: AppColors.text(isDark), fontSize: 22,
                    fontWeight: FontWeight.bold)),
                  Text('Powered by Gemini AI', style: TextStyle(
                    color: AppColors.textMuted(isDark), fontSize: 12)),
                ]),
              ]),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF0D1F2D), const Color(0xFF0A1628)]
                        : [const Color(0xFFE0F7FA), const Color(0xFFE8F5E9)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryCyan.withOpacity(0.25))),
                child: Text(
                  '✨ Your AI career advisor is ready. Choose a tool below '
                  'or just start chatting for personalized guidance.',
                  style: TextStyle(
                    color: AppColors.textSecondary(isDark), fontSize: 13, height: 1.5)),
              ),
              const SizedBox(height: 20),
              Text('Choose a Tool', style: TextStyle(
                color: AppColors.text(isDark), fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
            ],
          )),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12,
              mainAxisSpacing: 12, childAspectRatio: 1.1),
            delegate: SliverChildBuilderDelegate(
              (_, i) => _ToolCard(tool: _tools[i], isDark: isDark,
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => AIChatPage(
                    initialCommand: _tools[i].command)))),
              childCount: _tools.length),
          ),
        ),
        const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
      ])),
    );
  }
}

class _Tool {
  final String label, description, command;
  final Color color;
  const _Tool(this.label, this.description, this.color, this.command);
}

class _ToolCard extends StatefulWidget {
  final _Tool tool; final bool isDark; final VoidCallback onTap;
  const _ToolCard({required this.tool, required this.isDark, required this.onTap});
  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 100));
    _s = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final t = widget.tool;
    return GestureDetector(
      onTapDown: (_) => _c.forward(),
      onTapUp:   (_) { _c.reverse(); widget.onTap(); },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(scale: _s,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: t.color.withOpacity(widget.isDark ? 0.07 : 0.05),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: t.color.withOpacity(0.25)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: t.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10)),
              child: Text(t.label.split(' ')[0], style: const TextStyle(fontSize: 20))),
            const SizedBox(height: 10),
            Text(t.label.split(' ').skip(1).join(' '), style: TextStyle(
              color: AppColors.text(widget.isDark),
              fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 4),
            Expanded(child: Text(t.description, style: TextStyle(
              color: AppColors.textMuted(widget.isDark), fontSize: 10, height: 1.4),
              maxLines: 3, overflow: TextOverflow.ellipsis)),
          ]),
        )),
    );
  }
}
