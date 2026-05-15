import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';

// ── Skill data model ──────────────────────────────────────────
class SkillProgress {
  final String name;
  final int level; // 0–100
  final String category;
  final Color color;

  const SkillProgress({
    required this.name,
    required this.level,
    required this.category,
    required this.color,
  });
}

// ── Category colours ──────────────────────────────────────────
const _catColors = {
  'Technical': Color(0xFF00B8D4),
  'Soft Skills': Color(0xFF7C3AED),
  'Tools': Color(0xFF059669),
  'Languages': Color(0xFFF97316),
};

class SkillProgressPage extends StatefulWidget {
  const SkillProgressPage({super.key});
  @override
  State<SkillProgressPage> createState() => _SkillProgressPageState();
}

class _SkillProgressPageState extends State<SkillProgressPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _anim;

  // Skills come from the user's profile skills list
  List<SkillProgress> _skills = [];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _loadSkills();
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _loadSkills() {
    final user = context.read<AuthProvider>().currentUser;
    final raw = user?.skills as List<dynamic>? ?? [];
    final colors = [
      const Color(0xFF00B8D4),
      const Color(0xFF7C3AED),
      const Color(0xFF059669),
      const Color(0xFFF97316),
      const Color(0xFFDC2626),
      const Color(0xFF2563EB),
      const Color(0xFF0891B2),
      const Color(0xFF65A30D),
    ];
    if (raw.isNotEmpty) {
      _skills = raw
          .asMap()
          .entries
          .map(
            (e) => SkillProgress(
              name: e.value.toString(),
              level: 50 + (e.key * 7) % 45, // placeholder level
              category: _guessCategory(e.value.toString()),
              color: colors[e.key % colors.length],
            ),
          )
          .toList();
    } else {
      // Demo data so the screen isn't empty
      _skills = const [
        SkillProgress(
          name: 'Flutter',
          level: 85,
          category: 'Technical',
          color: Color(0xFF00B8D4),
        ),
        SkillProgress(
          name: 'Dart',
          level: 80,
          category: 'Languages',
          color: Color(0xFFF97316),
        ),
        SkillProgress(
          name: 'Python',
          level: 70,
          category: 'Languages',
          color: Color(0xFF059669),
        ),
        SkillProgress(
          name: 'Git',
          level: 75,
          category: 'Tools',
          color: Color(0xFF7C3AED),
        ),
        SkillProgress(
          name: 'Firebase',
          level: 60,
          category: 'Technical',
          color: Color(0xFF2563EB),
        ),
        SkillProgress(
          name: 'REST APIs',
          level: 78,
          category: 'Technical',
          color: Color(0xFF0891B2),
        ),
        SkillProgress(
          name: 'Leadership',
          level: 65,
          category: 'Soft Skills',
          color: Color(0xFFDC2626),
        ),
        SkillProgress(
          name: 'Teamwork',
          level: 88,
          category: 'Soft Skills',
          color: Color(0xFF65A30D),
        ),
      ];
    }
  }

  String _guessCategory(String skill) {
    final s = skill.toLowerCase();
    if ([
      'python',
      'dart',
      'java',
      'kotlin',
      'swift',
      'js',
      'typescript',
    ].any((l) => s.contains(l)))
      return 'Languages';
    if ([
      'git',
      'docker',
      'figma',
      'vs code',
      'jira',
      'postman',
    ].any((t) => s.contains(t)))
      return 'Tools';
    if ([
      'communication',
      'leadership',
      'teamwork',
      'problem',
    ].any((t) => s.contains(t)))
      return 'Soft Skills';
    return 'Technical';
  }

  List<SkillProgress> get _filtered => _selectedCategory == 'All'
      ? _skills
      : _skills.where((s) => s.category == _selectedCategory).toList();

  List<String> get _categories => [
    'All',
    ..._skills.map((s) => s.category).toSet().toList(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: const Text('Skill Progress'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Summary cards ──────────────────────────────
          Row(
            children: [
              _summaryCard(
                'Skills Tracked',
                '${_skills.length}',
                Icons.bar_chart_rounded,
                AppColors.primaryCyan,
                isDark,
              ),
              const SizedBox(width: 12),
              _summaryCard(
                'Avg Level',
                _skills.isEmpty
                    ? '—'
                    : '${(_skills.map((s) => s.level).reduce((a, b) => a + b) / _skills.length).toStringAsFixed(0)}%',
                Icons.trending_up_rounded,
                const Color(0xFF059669),
                isDark,
              ),
              const SizedBox(width: 12),
              _summaryCard(
                'Top Skill',
                _skills.isEmpty
                    ? '—'
                    : _skills.reduce((a, b) => a.level > b.level ? a : b).name,
                Icons.star_rounded,
                const Color(0xFFFFC107),
                isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Radar chart ────────────────────────────────
          if (_skills.isNotEmpty) ...[
            Text(
              'Skill Radar',
              style: TextStyle(
                color: AppColors.text(isDark),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 260,
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border(isDark)),
              ),
              child: AnimatedBuilder(
                animation: _anim,
                builder: (_, __) => CustomPaint(
                  painter: _RadarPainter(
                    skills: _skills.take(6).toList(),
                    progress: _anim.value,
                    isDark: isDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Category filter ────────────────────────────
          Text(
            'Skills by Category',
            style: TextStyle(
              color: AppColors.text(isDark),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final sel = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: sel,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                    selectedColor: AppColors.primaryCyan.withOpacity(0.2),
                    checkmarkColor: AppColors.primaryCyan,
                    side: BorderSide(
                      color: sel
                          ? AppColors.primaryCyan
                          : AppColors.border(isDark),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // ── Skill bars ─────────────────────────────────
          ..._filtered.map((skill) => _skillBar(skill, isDark)),
        ],
      ),
    );
  }

  Widget _summaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border(isDark)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                color: AppColors.text(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(isDark),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skillBar(SkillProgress skill, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill.name,
                style: TextStyle(
                  color: AppColors.text(isDark),
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              Text(
                '${skill.level}%',
                style: TextStyle(
                  color: skill.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: skill.level / 100 * _anim.value,
                minHeight: 10,
                backgroundColor: AppColors.border(isDark).withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation(skill.color),
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            skill.category,
            style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Radar chart painter ───────────────────────────────────────
class _RadarPainter extends CustomPainter {
  final List<SkillProgress> skills;
  final double progress;
  final bool isDark;

  const _RadarPainter({
    required this.skills,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (skills.isEmpty) return;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 40;
    final n = skills.length;
    final step = 2 * math.pi / n;

    // Grid rings
    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.08);

    for (int ring = 1; ring <= 4; ring++) {
      final r = radius * ring / 4;
      final path = Path();
      for (int i = 0; i < n; i++) {
        final angle = step * i - math.pi / 2;
        final x = cx + r * math.cos(angle);
        final y = cy + r * math.sin(angle);
        i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Spoke lines
    final spokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.08);

    for (int i = 0; i < n; i++) {
      final angle = step * i - math.pi / 2;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + radius * math.cos(angle), cy + radius * math.sin(angle)),
        spokePaint,
      );
    }

    // Skill polygon
    final path = Path();
    for (int i = 0; i < n; i++) {
      final angle = step * i - math.pi / 2;
      final r = radius * (skills[i].level / 100) * progress;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFF00B8D4).withOpacity(0.2),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = const Color(0xFF00B8D4),
    );

    // Skill labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < n; i++) {
      final angle = step * i - math.pi / 2;
      final lx = cx + (radius + 22) * math.cos(angle);
      final ly = cy + (radius + 22) * math.sin(angle);
      tp.text = TextSpan(
        text: skills[i].name,
        style: TextStyle(
          color: isDark ? Colors.white70 : Colors.black87,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      );
      tp.layout();
      tp.paint(canvas, Offset(lx - tp.width / 2, ly - tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.progress != progress || old.isDark != isDark;
}
