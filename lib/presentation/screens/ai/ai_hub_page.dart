import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/theme_provider.dart';
import 'career_path_analyzer_page.dart';
import 'salary_negotiation_page.dart';
import 'career_change_simulator_page.dart';
import 'network_outreach_page.dart';
import 'performance_review_page.dart';

class AIHubPage extends StatelessWidget {
  const AIHubPage({super.key});

  static const List<_AITool> _tools = [
    _AITool(
      title: 'Career Path Analyzer',
      subtitle:
          'Discover personalized career paths that match your skills and interests',
      icon: Icons.psychology_outlined,
      color: Color(0xFF00B8D4),
      tag: 'Career Discovery',
    ),
    _AITool(
      title: 'Salary Negotiation',
      subtitle: 'Analyze market rates and get counter-offer strategies',
      icon: Icons.monetization_on_outlined,
      color: Color(0xFF059669),
      tag: 'Compensation',
    ),
    _AITool(
      title: 'Career Change Simulator',
      subtitle:
          'Simulate career paths with projected salary, growth & satisfaction',
      icon: Icons.compare_arrows,
      color: Color(0xFF7C3AED),
      tag: 'Career Switch',
    ),
    _AITool(
      title: 'Network Outreach AI',
      subtitle:
          'Generate personalized messages to build meaningful connections',
      icon: Icons.people_outline,
      color: Color(0xFF2563EB),
      tag: 'Networking',
    ),
    _AITool(
      title: 'Performance Review Coach',
      subtitle: 'Present your accomplishments to maximize promotion chances',
      icon: Icons.emoji_events_outlined,
      color: Color(0xFFDC2626),
      tag: 'Career Growth',
    ),
  ];

  void _navigate(BuildContext context, int index) {
    final pages = [
      const CareerPathAnalyzerPage(),
      const SalaryNegotiationPage(),
      const CareerChangeSimulatorPage(),
      const NetworkOutreachPage(),
      const PerformanceReviewPage(),
    ];
    Navigator.push(context, MaterialPageRoute(builder: (_) => pages[index]));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: const Text('AI Career Tools'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryCyan.withValues(alpha: 0.15),
                  AppColors.primaryCyan.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primaryCyan.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.primaryCyan,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Powered by Claude AI',
                        style: TextStyle(
                          color: AppColors.primaryCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '5 AI tools to accelerate your career. '
                        'Get personalized advice in seconds.',
                        style: TextStyle(
                          color: AppColors.textSecondary(isDark),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Choose a Tool',
            style: TextStyle(
              color: AppColors.text(isDark),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),

          // Tool cards
          ...List.generate(_tools.length, (i) {
            final tool = _tools[i];
            return _ToolCard(
              tool: tool,
              onTap: () => _navigate(context, i),
              isDark: isDark,
            );
          }),
          const SizedBox(height: 16),

          // Info note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.card(isDark),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border(isDark)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textMuted(isDark),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI responses are for guidance only. '
                    'Always validate salary data with current market sources.',
                    style: TextStyle(
                      color: AppColors.textMuted(isDark),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AITool {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String tag;
  const _AITool({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.tag,
  });
}

class _ToolCard extends StatelessWidget {
  final _AITool tool;
  final VoidCallback onTap;
  final bool isDark;
  const _ToolCard({
    required this.tool,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(isDark)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tool.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(tool.icon, color: tool.color, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tool.title,
                        style: TextStyle(
                          color: AppColors.text(isDark),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: tool.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tool.tag,
                        style: TextStyle(
                          color: tool.color,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tool.subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary(isDark),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: AppColors.textMuted(isDark),
          ),
        ],
      ),
    ),
  );
}
