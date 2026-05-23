import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/questionnaire_model.dart';

class QuestionnaireService {
  // ⚠️ Change this to your backend URL
  static const String baseUrl = 'http://10.0.2.2:3000';

  static Future<bool> submitQuestionnaire(QuestionnaireModel data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final response = await http.post(
        Uri.parse('$baseUrl/api/questionnaire'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await prefs.setString(
          'last_questionnaire_date',
          DateTime.now().toIso8601String(),
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  static Future<bool> isQuestionnaireDue() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString('last_questionnaire_date');
    if (lastDateStr == null) return true;
    final lastDate = DateTime.parse(lastDateStr);
    return DateTime.now().difference(lastDate).inDays >= 365;
  }
}
