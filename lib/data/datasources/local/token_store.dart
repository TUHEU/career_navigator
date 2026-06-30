import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class TokenStore {
  Future<void> save(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.accessTokenKey, access);
    await prefs.setString(AppConstants.refreshTokenKey, refresh);
  }

  Future<String?> getAccess() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.accessTokenKey);
  }

  Future<String?> getRefresh() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.refreshTokenKey);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.accessTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getAccess();
    return token != null && token.isNotEmpty;
  }

  // ── v11: first-launch tracking for onboarding ──────────────
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('has_launched_before') ?? false);
  }

  Future<void> setFirstLaunchDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_launched_before', true);
  }
}
