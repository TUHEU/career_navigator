import 'package:flutter/material.dart';

class AppColors {
  // ── Brand ────────────────────────────────────────────────
  static const Color primaryCyan = Color(
    0xFF007A99,
  ); // darker cyan — readable on white
  static const Color primaryCyanLight = Color(
    0xFF00B8D4,
  ); // lighter variant for dark mode

  // ── Dark theme ───────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A192F);
  static const Color darkSurface = Color(0xFF0D2137);
  static const Color darkCard = Color(0xFF112240);

  // ── Light theme — maximum contrast ───────────────────────
  static const Color lightBackground = Color(0xFFF0F4F8); // soft off-white
  static const Color lightSurface = Color(0xFFFFFFFF); // pure white cards
  static const Color lightCard = Color(0xFFE8EEF6); // light blue-grey card

  // Text — all very dark for maximum readability
  static const Color lightText = Color(0xFF0D1117); // near black
  static const Color lightTextSecondary = Color(0xFF24292F); // dark grey
  static const Color lightTextMuted = Color(0xFF57606A); // medium grey

  // Inputs
  static const Color lightInputFill = Color(
    0xFFDDE4EE,
  ); // visible input background
  static const Color lightBorder = Color(0xFF8C959F); // clear border

  // Status
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);

  // ── Convenience getters ──────────────────────────────────
  static Color text(bool isDark) => isDark ? Colors.white : lightText;

  static Color textSecondary(bool isDark) =>
      isDark ? Colors.white70 : lightTextSecondary;

  static Color textMuted(bool isDark) =>
      isDark ? Colors.white54 : lightTextMuted;

  static Color background(bool isDark) =>
      isDark ? darkBackground : lightBackground;

  static Color surface(bool isDark) => isDark ? darkSurface : lightSurface;

  static Color card(bool isDark) => isDark ? darkCard : lightCard;

  static Color inputFill(bool isDark) =>
      isDark ? Colors.white.withOpacity(0.06) : lightInputFill;

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
