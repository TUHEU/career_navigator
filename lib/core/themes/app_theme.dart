import 'package:flutter/material.dart';

class AppColors {
  // ── Brand ──────────────────────────────────────────────────
  // ── Brand ──────────────────────────────────────────────────
  static const Color primaryCyan = Color(
    0xFF00B8D4,
  ); // original cyan (restored)
  static const Color primaryCyanLight = Color(
    0xFF00B8D4,
  ); // same for both modes

  // ── Dark theme ─────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A192F);
  static const Color darkSurface = Color(0xFF0D2137);
  static const Color darkCard = Color(0xFF112240);

  // ── Light theme ────────────────────────────────────────────
  static const Color lightBackground = Color(0xFFF2F5F9);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFE9EFF8);

  // Text — all very dark
  static const Color lightText = Color(0xFF0F172A); // main text (original)
  static const Color lightTextSecondary = Color(0xFF1C2333); // very dark grey
  static const Color lightTextMuted = Color(
    0xFF4A5568,
  ); // medium dark grey — still readable

  // Inputs
  static const Color lightInputFill = Color(0xFFD8E0ED);
  static const Color lightBorder = Color(0xFF8896B0);

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);

  // ── Static helpers ─────────────────────────────────────────
  static Color text(bool isDark) => isDark ? Colors.white : lightText;

  static Color textSecondary(bool isDark) =>
      isDark ? const Color(0xFFCDD5E0) : lightTextSecondary;

  static Color textMuted(bool isDark) =>
      isDark ? const Color(0xFF8899BB) : lightTextMuted;

  static Color background(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;

  static Color card(bool isDark) => isDark ? darkCard : lightCard;

  static Color inputFill(bool isDark) =>
      isDark ? Colors.white.withOpacity(0.07) : lightInputFill;

  static Color border(bool isDark) =>
      isDark ? Colors.white.withOpacity(0.15) : lightBorder;

  static Color cyan(bool isDark) => isDark ? primaryCyanLight : primaryCyan;
}

enum AppBackground { bg8, bg6 }

extension AppBackgroundExt on AppBackground {
  String get assetPath {
    switch (this) {
      case AppBackground.bg8:
        return 'assets/background/bg8.png';
      case AppBackground.bg6:
        return 'assets/background/bg6.png';
    }
  }
}
