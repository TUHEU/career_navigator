import 'package:shared_preferences/shared_preferences.dart';

class QuestionnaireService {
  static const String _key = 'questionnaire_completed';

  /// Mark questionnaire as done — called after submit
  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  /// Check if questionnaire was already completed
  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Reset — useful for testing
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
