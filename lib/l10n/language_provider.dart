// l10n/language_provider.dart
// Simple language provider — English or French.
// Usage: context.read<LanguageProvider>().strings.signIn
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_en.dart';
import 'app_fr.dart';

enum AppLanguage { english, french }

class LanguageProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.english;

  AppLanguage get language => _language;
  bool get isFrench => _language == AppLanguage.french;

  String get languageLabel =>
      _language == AppLanguage.french ? '🇫🇷 Français' : '🇬🇧 English';

  // Returns the correct string set
  dynamic get strings =>
      _language == AppLanguage.french ? _FrStrings() : _EnStrings();

  LanguageProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('app_language') ?? 'en';
    _language = saved == 'fr' ? AppLanguage.french : AppLanguage.english;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'app_language',
      lang == AppLanguage.french ? 'fr' : 'en',
    );
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    await setLanguage(
      _language == AppLanguage.english
          ? AppLanguage.french
          : AppLanguage.english,
    );
  }

  // Helper for direct string access
  String t(String key) {
    if (_language == AppLanguage.french) {
      return _frStrings[key] ?? _enStrings[key] ?? key;
    }
    return _enStrings[key] ?? key;
  }

  static final Map<String, String> _enStrings = {
    'signIn': AppStrings.signIn,
    'signUp': AppStrings.signUp,
    'email': AppStrings.email,
    'password': AppStrings.password,
    'forgotPassword': AppStrings.forgotPassword,
    'verifyEmail': AppStrings.verifyEmail,
    'verifyEmailSub': AppStrings.verifyEmailSub,
    'verifyBtn': AppStrings.verifyBtn,
    'resendCode': AppStrings.resendCode,
    'didntReceive': AppStrings.didntReceive,
    'backToSignIn': AppStrings.backToSignIn,
    'logout': AppStrings.logout,
    'dashboard': AppStrings.dashboard,
    'welcomeBack': AppStrings.welcomeBack,
    'aiCareerTools': AppStrings.aiCareerTools,
    'settings': AppStrings.settings,
    'appearance': AppStrings.appearance,
    'darkMode': AppStrings.darkMode,
    'language': AppStrings.language,
    'account': AppStrings.account,
    'editProfile': AppStrings.editProfile,
    'changePassword': AppStrings.changePassword,
    'deleteAccount': AppStrings.deleteAccount,
    'helpFaq': AppStrings.helpFaq,
    'aboutUs': AppStrings.aboutUs,
    'privacyPolicy': AppStrings.privacyPolicy,
    'sendFeedback': AppStrings.sendFeedback,
    'jobs': AppStrings.jobs,
    'save': AppStrings.save,
    'cancel': AppStrings.cancel,
    'loading': AppStrings.loading,
    'error': AppStrings.error,
    'success': AppStrings.success,
    'noData': AppStrings.noData,
    'changePhoto': AppStrings.changePhoto,
  };

  static final Map<String, String> _frStrings = {
    'signIn': AppStringsFr.signIn,
    'signUp': AppStringsFr.signUp,
    'email': AppStringsFr.email,
    'password': AppStringsFr.password,
    'forgotPassword': AppStringsFr.forgotPassword,
    'verifyEmail': AppStringsFr.verifyEmail,
    'verifyEmailSub': AppStringsFr.verifyEmailSub,
    'verifyBtn': AppStringsFr.verifyBtn,
    'resendCode': AppStringsFr.resendCode,
    'didntReceive': AppStringsFr.didntReceive,
    'backToSignIn': AppStringsFr.backToSignIn,
    'logout': AppStringsFr.logout,
    'dashboard': AppStringsFr.dashboard,
    'welcomeBack': AppStringsFr.welcomeBack,
    'aiCareerTools': AppStringsFr.aiCareerTools,
    'settings': AppStringsFr.settings,
    'appearance': AppStringsFr.appearance,
    'darkMode': AppStringsFr.darkMode,
    'language': AppStringsFr.language,
    'account': AppStringsFr.account,
    'editProfile': AppStringsFr.editProfile,
    'changePassword': AppStringsFr.changePassword,
    'deleteAccount': AppStringsFr.deleteAccount,
    'helpFaq': AppStringsFr.helpFaq,
    'aboutUs': AppStringsFr.aboutUs,
    'privacyPolicy': AppStringsFr.privacyPolicy,
    'sendFeedback': AppStringsFr.sendFeedback,
    'jobs': AppStringsFr.jobs,
    'save': AppStringsFr.save,
    'cancel': AppStringsFr.cancel,
    'loading': AppStringsFr.loading,
    'error': AppStringsFr.error,
    'success': AppStringsFr.success,
    'noData': AppStringsFr.noData,
    'changePhoto': AppStringsFr.changePhoto,
  };
}

class _EnStrings {
  @override
  dynamic noSuchMethod(Invocation i) => AppStrings.noData;
}

class _FrStrings {
  @override
  dynamic noSuchMethod(Invocation i) => AppStringsFr.noData;
}
