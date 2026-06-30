// presentation/screens/stats/career_stats_page.dart — v10
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/stats_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/loading_widgets.dart';

class CareerStatsPage extends StatefulWidget {
  const CareerStatsPage({super.key});
  @override
  State<CareerStatsPage> createState() => _CareerStatsPageState();
}

class _CareerStatsPageState extends State<CareerStatsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final sp     = context.watch<StatsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: Text('Career Stats', style: TextStyle(
          color: AppColors.text(isDark), fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background(isDark), elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(isDark)),
      ),
      body: sp.isLoading
          ? const LoadingIndicator(message: 'Loading your stats...')
          : sp.stats == null
            ? _ErrorState(isDark: isDark, onRetry: () => sp.load())
            : _StatsBody(isDark: isDark, stats: sp.stats!, achievements: sp.achievements),
    );
  }
}

class _StatsBody extends StatelessWidget {
  final bool isDark;
  final CareerStats stats;
  final List<Achievement> achievements;
  const _StatsBody({required this.isDark, required this.stats, required this.achievements});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // ── XP Level Card ────────────────────────────────────────
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0D1F2D), const Color(0xFF0A1628)]
                : [const Color(0xFFE0F7FA), const Color(0xFFE8F5E9)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryCyan.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.military_tech_rounded,
                  color: AppColors.primaryCyan, size: 28)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Level ${stats.level} · ${stats.levelTitle}',
                style: TextStyle(color: AppColors.text(isDark),
                  fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 2),
              Text('${stats.totalXp} XP total',
                style: TextStyle(color: AppColors.primaryCyan, fontSize: 13)),
            ])),
          ]),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${stats.xpInLevel} / ${stats.xpForNextLevel} XP',
              style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 12)),
            Text('Level ${stats.level + 1}',
              style: TextStyle(color: AppColors.primaryCyan, fontSize: 12,
                fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stats.levelProgress, minHeight: 10,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.07) : Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryCyan),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 24),

      // ── Stats grid ────────────────────────────────────────────
      _SectionTitle('Career Activity', isDark),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 2, shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12, mainAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: [
          _StatCard('Applications', '${stats.applicationsSent}',
            Icons.send_rounded, const Color(0xFF00B8D4), isDark),
          _StatCard('Shortlisted', '${stats.shortlistedCount}',
            Icons.star_rounded, const Color(0xFFF59E0B), isDark),
          _StatCard('Hired', '${stats.hiredCount}',
            Icons.celebration_rounded, const Color(0xFF059669), isDark),
          _StatCard('Saved Jobs', '${stats.savedJobs}',
            Icons.bookmark_rounded, const Color(0xFF7C3AED), isDark),
          _StatCard('Connections', '${stats.totalConnections}',
            Icons.people_rounded, const Color(0xFF3B82F6), isDark),
          _StatCard('AI Sessions', '${stats.aiSessions}',
            Icons.auto_awesome_rounded, const Color(0xFFEC4899), isDark),
        ],
      ),
      const SizedBox(height: 28),

      // ── Achievements ──────────────────────────────────────────
      _SectionTitle('Achievements (${achievements.length})', isDark),
      const SizedBox(height: 12),
      achievements.isEmpty
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border(isDark))),
              child: Center(child: Column(children: [
                const Text('🏆', style: TextStyle(fontSize: 36)),
                const SizedBox(height: 8),
                Text('Complete tasks to earn achievements!',
                  style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 13)),
              ])))
          : Column(children: achievements.map((a) => _AchievementTile(
              a: a, isDark: isDark)).toList()),
      const SizedBox(height: 24),
    ]),
  );
}

class _StatCard extends StatelessWidget {
  final String label, value; final IconData icon;
  final Color color; final bool isDark;
  const _StatCard(this.label, this.value, this.icon, this.color, this.isDark);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withOpacity(isDark ? 0.07 : 0.05),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: color.withOpacity(0.2))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 22),
      const Spacer(),
      Text(value, style: TextStyle(
        color: AppColors.text(isDark), fontSize: 24, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 11)),
    ]),
  );
}

class _AchievementTile extends StatelessWidget {
  final Achievement a; final bool isDark;
  const _AchievementTile({required this.a, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.card(isDark), borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primaryCyan.withOpacity(0.15))),
    child: Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryCyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(a.icon, style: const TextStyle(fontSize: 22)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(a.title, style: TextStyle(
          color: AppColors.text(isDark), fontWeight: FontWeight.bold, fontSize: 14)),
        Text(a.description, style: TextStyle(
          color: AppColors.textMuted(isDark), fontSize: 11),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3))),
          child: Text('+${a.xpReward} XP', style: const TextStyle(
            color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.bold))),
        const SizedBox(height: 4),
        Text(_formatDate(a.earnedAt), style: TextStyle(
          color: AppColors.textMuted(isDark), fontSize: 9)),
      ]),
    ]),
  );

  String _formatDate(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year}';
}

class _SectionTitle extends StatelessWidget {
  final String text; final bool isDark;
  const _SectionTitle(this.text, this.isDark);
  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(
    color: AppColors.text(isDark), fontSize: 18, fontWeight: FontWeight.bold));
}

class _ErrorState extends StatelessWidget {
  final bool isDark; final VoidCallback onRetry;
  const _ErrorState({required this.isDark, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.error_outline, size: 64, color: AppColors.textMuted(isDark)),
      const SizedBox(height: 16),
      Text('Could not load stats', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ElevatedButton(
        onPressed: onRetry,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCyan, foregroundColor: Colors.black),
        child: const Text('Retry')),
    ],
  ));
}
