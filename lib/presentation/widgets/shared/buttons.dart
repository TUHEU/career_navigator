import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

// ─── PrimaryButton ───────────────────────────────────────────
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon; // FIX: added icon parameter

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon, // optional — pass null to use text-only style
  });

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (isLoading) {
      child = const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.black),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      );
    } else {
      child = Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      );
    }

    final btn = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryCyan,
        foregroundColor: Colors.black,
        minimumSize: isFullWidth
            ? const Size(double.infinity, 52)
            : const Size(140, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: child,
    );
    return isFullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

// ─── SecondaryButton ─────────────────────────────────────────
// FIX: was missing entirely — used in mentor_dashboard & job_seeker_dashboard
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget child;
    if (isLoading) {
      child = SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: isDark ? Colors.white : AppColors.lightText,
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      );
    } else {
      child = Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      );
    }

    final btn = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? Colors.white : AppColors.lightText,
        minimumSize: isFullWidth
            ? const Size(double.infinity, 52)
            : const Size(140, 48),
        side: BorderSide(
          color: isDark ? Colors.white.withOpacity(0.3) : Colors.grey.shade400,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: child,
    );
    return isFullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}
