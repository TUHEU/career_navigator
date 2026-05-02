import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const Color primaryCyan = Color(0xFF00E5FF);
  static const Color darkBackground = Color(0xFF0A192F);
  static const Color darkSurface = Color(0xFF0D2137);
  static const Color darkCard = Color(0xFF112240);

  // Light theme colors
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F2F5);
  static const Color lightText = Color(0xFF1A202C);
  static const Color lightTextSecondary = Color(0xFF4A5568);
}

enum AppBackground {
  bg8, // Dark theme (Cosmos)
  bg6, // Light theme (Aurora)
}

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

  String get label {
    switch (this) {
      case AppBackground.bg8:
        return 'Dark Mode';
      case AppBackground.bg6:
        return 'Light Mode';
    }
  }
}

class AppThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  AppBackground _background = AppBackground.bg8;

  ThemeMode get themeMode => _themeMode;
  AppBackground get background => _background;
  String get backgroundPath => _background.assetPath;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  AppThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeStr = prefs.getString('theme_mode') ?? 'dark';
    _themeMode = themeModeStr == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _background = _themeMode == ThemeMode.dark
        ? AppBackground.bg8
        : AppBackground.bg6;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    _background = _themeMode == ThemeMode.dark
        ? AppBackground.bg8
        : AppBackground.bg6;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'theme_mode',
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}

InputDecoration buildInputDecoration({
  required IconData icon,
  required String label,
  Widget? suffix,
  bool isDarkMode = true,
}) {
  return InputDecoration(
    prefixIcon: Icon(icon, color: AppColors.primaryCyan),
    labelText: label,
    labelStyle: TextStyle(
      color: isDarkMode ? Colors.white.withOpacity(0.6) : Colors.grey.shade600,
    ),
    filled: true,
    fillColor: isDarkMode
        ? Colors.white.withOpacity(0.05)
        : Colors.grey.shade100,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
      borderSide: BorderSide(
        color: isDarkMode
            ? Colors.white.withOpacity(0.15)
            : Colors.grey.shade300,
      ),
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
}
