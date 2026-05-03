import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color darkBackground = Color(0xFF0A192F);
  static const Color darkSurface = Color(0xFF0D2137);
  static const Color darkCard = Color(0xFF112240);

  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F2F5);
  static const Color lightText = Color(0xFF1A202C);
  static const Color lightTextSecondary = Color(0xFF4A5568);
}

enum AppBackground { bg8, bg6 }

enum ThemeMode { dark, light }

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

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;
  String get backgroundPath =>
      _isDarkMode ? 'assets/background/bg8.png' : 'assets/background/bg6.png';

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme_mode');
    _isDarkMode = savedTheme != 'light';
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _isDarkMode ? 'dark' : 'light');
    notifyListeners();
  }
}
