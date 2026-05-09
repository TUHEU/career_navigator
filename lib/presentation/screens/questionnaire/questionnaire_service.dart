import 'package:shared_preferences/shared_preferences.dart';

/// QuestionnaireService
///
/// Tracks whether the annual career questionnaire is due.
/// The actual submission is handled by [UserProvider.updateJobSeekerProfile]
/// via the existing /profile/job-seeker API endpoint — so no separate
/// backend route or questionnaire_model is needed.
class QuestionnaireService {
  static const String _lastDateKey = 'last_questionnaire_date';

  /// Marks the questionnaire as completed today.
  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastDateKey, DateTime.now().toIso8601String());
  }

  /// Returns true if the questionnaire has never been filled,
  /// or if it was last filled more than 365 days ago.
  static Future<bool> isQuestionnaireDue() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString(_lastDateKey);
    if (lastDateStr == null) return true;
    try {
      final lastDate = DateTime.parse(lastDateStr);
      return DateTime.now().difference(lastDate).inDays >= 365;
    } catch (_) {
      return true;
    }
  }

  /// Clears the completion record (useful for testing / account reset).
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastDateKey);
  }
}
