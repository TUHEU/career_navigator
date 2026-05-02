import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/themes/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(AppConstants.themeModeKey);
    _isDarkMode = savedTheme != 'light';
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.themeModeKey,
      _isDarkMode ? 'dark' : 'light',
    );
    notifyListeners();
  }

  Color get backgroundColor =>
      _isDarkMode ? AppColors.darkBackground : AppColors.lightBackground;

  Color get surfaceColor =>
      _isDarkMode ? AppColors.darkSurface : AppColors.lightSurface;

  Color get cardColor => _isDarkMode ? AppColors.darkCard : AppColors.lightCard;

  Color get textColor => _isDarkMode ? Colors.white : AppColors.lightText;

  Color get textSecondaryColor => _isDarkMode
      ? Colors.white.withOpacity(0.6)
      : AppColors.lightTextSecondary;
}
