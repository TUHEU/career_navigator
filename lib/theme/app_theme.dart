import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color darkBackground = Color(0xFF0A192F);
  static const Color darkSurface = Color(0xFF0D2137);
  static const Color darkCard = Color(0xFF112240);
}

enum AppBackground { bg4, bg6, bg8, bg9 }

extension AppBackgroundExt on AppBackground {
  String get assetPath {
    switch (this) {
      case AppBackground.bg4:
        return 'assets/background/bg4.png';
      case AppBackground.bg6:
        return 'assets/background/bg6.png';
      case AppBackground.bg8:
        return 'assets/background/bg8.png';
      case AppBackground.bg9:
        return 'assets/background/bg9.png';
    }
  }

  String get label {
    switch (this) {
      case AppBackground.bg4:
        return 'Ocean Deep';
      case AppBackground.bg6:
        return 'Aurora';
      case AppBackground.bg8:
        return 'Cosmos';
      case AppBackground.bg9:
        return 'Nebula';
    }
  }

  String get key {
    switch (this) {
      case AppBackground.bg4:
        return 'bg4';
      case AppBackground.bg6:
        return 'bg6';
      case AppBackground.bg8:
        return 'bg8';
      case AppBackground.bg9:
        return 'bg9';
    }
  }
}

class AppThemeProvider extends ChangeNotifier {
  AppBackground _background = AppBackground.bg8;

  AppBackground get background => _background;
  String get backgroundPath => _background.assetPath;

  AppThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('app_background') ?? 'bg8';
    _background = AppBackground.values.firstWhere(
      (b) => b.key == key,
      orElse: () => AppBackground.bg8,
    );
    notifyListeners();
  }

  Future<void> setBackground(AppBackground bg) async {
    _background = bg;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_background', bg.key);
  }
}

InputDecoration buildInputDecoration({
  required IconData icon,
  required String label,
  Widget? suffix,
}) => InputDecoration(
  prefixIcon: Icon(icon, color: AppColors.primaryCyan),
  labelText: label,
  labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
  filled: true,
  fillColor: Colors.white.withOpacity(0.05),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: BorderSide(color: Colors.white.withOpacity(0.15)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: const BorderSide(color: AppColors.primaryCyan),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(15),
    borderSide: const BorderSide(color: Colors.redAccent),
  ),
  suffixIcon: suffix,
);
