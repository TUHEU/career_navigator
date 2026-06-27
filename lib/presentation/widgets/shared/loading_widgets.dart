// presentation/widgets/shared/loading_widgets.dart
// v9 — Improved loading states with skeleton shimmer effect
import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

// ── Standard spinner ──────────────────────────────────────────────
class LoadingIndicator extends StatelessWidget {
  final String? message;
  const LoadingIndicator({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 40, height: 40,
        child: CircularProgressIndicator(
          color: AppColors.primaryCyan, strokeWidth: 3)),
      if (message != null) ...[
        const SizedBox(height: 16),
        Text(message!, style: TextStyle(
          color: AppColors.textMuted(isDark), fontSize: 13)),
      ],
    ]));
  }
}

// ── Shimmer skeleton card ─────────────────────────────────────────
class SkeletonCard extends StatefulWidget {
  final double height;
  const SkeletonCard({super.key, this.height = 100});
  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: widget.height,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Color.lerp(
            isDark ? const Color(0xFF1A2235) : const Color(0xFFF0F4F8),
            isDark ? const Color(0xFF1F2C42) : const Color(0xFFE8EDF3),
            _anim.value),
          borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}

// ── List of skeleton cards ────────────────────────────────────────
class SkeletonList extends StatelessWidget {
  final int count; final double cardHeight;
  const SkeletonList({super.key, this.count = 4, this.cardHeight = 120});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Column(children: List.generate(count,
      (i) => SkeletonCard(height: cardHeight))),
  );
}
