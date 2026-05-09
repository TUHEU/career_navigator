import 'package:flutter/material.dart';

class AppColors {
  // ── Brand ──────────────────────────────────────────────────
  static const Color primaryCyan = Color(0xFF00B8D4); // slightly deeper cyan
  static const Color primaryCyanLight = Color(0xFF00E5FF); // accent highlight

  // ── Dark theme ─────────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0A192F);
  static const Color darkSurface = Color(0xFF0D2137);
  static const Color darkCard = Color(0xFF112240);

  // ── Light theme — FIX: much darker so text is readable ─────
  static const Color lightBackground = Color(0xFFEEF1F6); // was 0xFFF5F7FA
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFE2E8F0); // was 0xFFF0F2F5
  static const Color lightText = Color(0xFF0F172A); // near black
  static const Color lightTextSecondary = Color(0xFF334155); // dark slate
  static const Color lightTextMuted = Color(0xFF64748B); // medium slate

  // ── Light input / border ────────────────────────────────────
  static const Color lightInputFill = Color(0xFFE8EDF5);
  static const Color lightBorder = Color(0xFFB0BEC5);

  // ── Status ──────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC2626);
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
