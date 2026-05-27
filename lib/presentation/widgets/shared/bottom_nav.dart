// presentation/widgets/shared/bottom_nav.dart
// Fixed: overflow with long French labels using FittedBox + Expanded
import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

class NavItem {
  final IconData outlinedIcon;
  final IconData filledIcon;
  final String   label;
  const NavItem(this.outlinedIcon, this.filledIcon, this.label);
}

class AppBottomNav extends StatelessWidget {
  final int               currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem>     items;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(top: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade200)),
        boxShadow: [BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final sel  = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 2),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primaryCyan.withValues(alpha: 0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          sel ? item.filledIcon : item.outlinedIcon,
                          color: sel
                              ? AppColors.primaryCyan
                              : (isDark
                                  ? Colors.white38
                                  : Colors.grey.shade500),
                          size: 22),
                        const SizedBox(height: 3),
                        // FittedBox scales down text to prevent overflow
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: sel
                                  ? AppColors.primaryCyan
                                  : (isDark
                                      ? Colors.white38
                                      : Colors.grey.shade500),
                              fontSize: 10,
                              fontWeight: sel
                                  ? FontWeight.bold
                                  : FontWeight.normal),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
