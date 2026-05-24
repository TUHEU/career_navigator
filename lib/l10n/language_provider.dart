// l10n/language_provider.dart
// Language provider — drives the entire app's language.
// Usage: context.watch<LanguageProvider>().t(S.signIn)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_strings.dart';

enum AppLanguage { english, french }

class LanguageProvider extends ChangeNotifier {
  AppLanguage _lang = AppLanguage.english;

  AppLanguage get language    => _lang;
  bool        get isFrench    => _lang == AppLanguage.french;
  String      get languageLabel =>
      _lang == AppLanguage.french ? '🇫🇷 Français' : '🇬🇧 English';
  String      get languageCode  =>
      _lang == AppLanguage.french ? 'fr' : 'en';

  LanguageProvider() { _load(); }

  /// Translate a key
  String t(String key) {
    final map = _lang == AppLanguage.french ? frStrings : enStrings;
    return map[key] ?? enStrings[key] ?? key;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_language') ?? 'en';
    _lang = saved == 'fr' ? AppLanguage.french : AppLanguage.english;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    if (_lang == lang) return;
    _lang = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang == AppLanguage.french ? 'fr' : 'en');
    notifyListeners();
  }

  Future<void> toggle() async =>
      setLanguage(_lang == AppLanguage.english ? AppLanguage.french : AppLanguage.english);
}
