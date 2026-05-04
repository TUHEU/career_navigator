import '../datasources/remote/api_service.dart';
import '../datasources/local/token_store.dart';

class AuthRepository {
  final ApiService _apiService = ApiService();
  final TokenStore _tokenStore = TokenStore();

  Future<Map<String, dynamic>> register(String email, String password) async {
    try {
      return await _apiService.register(email, password);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    try {
      final response = await _apiService.verifyEmail(email, code);
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        await _tokenStore.save(data['access_token'], data['refresh_token']);
      }
      return response;
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> resendCode(String email) async {
    try {
      return await _apiService.resendCode(email);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        await _tokenStore.save(data['access_token'], data['refresh_token']);
      }
      return response;
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      return await _apiService.forgotPassword(email);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    try {
      return await _apiService.resetPassword(email, code, password);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    final token = await _tokenStore.getAccess();
    if (token == null)
      return {'success': false, 'message': 'Not authenticated'};
    try {
      return await _apiService.deleteAccount(token);
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<void> logout() async {
    await _tokenStore.clear();
  }

  Future<bool> isAuthenticated() async {
    return await _tokenStore.hasToken();
  }

  Future<String?> getAccessToken() async {
    return await _tokenStore.getAccess();
  }
}
