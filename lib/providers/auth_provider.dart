import 'package:flutter/material.dart';
import '../data/datasources/local/token_store.dart';
import '../data/datasources/remote/api_service.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final TokenStore _tokenStore = TokenStore();
  final UserRepository _userRepository = UserRepository();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Public getter for userRepository - FIXES the error
  UserRepository get userRepository => _userRepository;

  Future<String?> getAccessToken() async {
    return await _tokenStore.getAccess();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    final response = await _apiService.login(email, password);

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      await _tokenStore.save(data['access_token'], data['refresh_token']);
      final success = await loadUserProfile();
      _setLoading(false);
      return success;
    } else {
      _error = response['message'] ?? 'Login failed';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loadUserProfile() async {
    final token = await _tokenStore.getAccess();
    if (token == null) return false;

    final response = await _apiService.getProfile(token);
    if (response['success'] == true) {
      _currentUser = User.fromJson(response['data'] as Map<String, dynamic>);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _clearError();

    final response = await _apiService.register(email, password);
    _setLoading(false);

    if (response['success'] != true) {
      _error = response['message'] ?? 'Registration failed';
    }
    return response['success'] == true;
  }

  Future<bool> verifyEmail(String email, String code) async {
    _setLoading(true);
    _clearError();

    final response = await _apiService.verifyEmail(email, code);

    if (response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      await _tokenStore.save(data['access_token'], data['refresh_token']);
      final success = await loadUserProfile();
      _setLoading(false);
      return success;
    } else {
      _error = response['message'] ?? 'Verification failed';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> resendCode(String email) async {
    _setLoading(true);
    _clearError();

    final response = await _apiService.resendCode(email);
    _setLoading(false);

    if (response['success'] != true) {
      _error = response['message'] ?? 'Failed to resend code';
    }
    return response['success'] == true;
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    final response = await _apiService.forgotPassword(email);
    _setLoading(false);

    if (response['success'] != true) {
      _error = response['message'] ?? 'Failed to send reset code';
    }
    return response['success'] == true;
  }

  Future<bool> resetPassword(String email, String code, String password) async {
    _setLoading(true);
    _clearError();

    final response = await _apiService.resetPassword(email, code, password);
    _setLoading(false);

    if (response['success'] != true) {
      _error = response['message'] ?? 'Failed to reset password';
    }
    return response['success'] == true;
  }

  Future<bool> setupProfile({
    required String fullName,
    required String dob,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    final token = await _tokenStore.getAccess();
    if (token == null) {
      _error = 'Not authenticated';
      _setLoading(false);
      return false;
    }

    final response = await _apiService.setupProfile(
      token: token,
      fullName: fullName,
      dob: dob,
      role: role,
    );
    _setLoading(false);

    if (response['success'] == true) {
      await loadUserProfile();
      return true;
    } else {
      _error = response['message'] ?? 'Failed to setup profile';
      return false;
    }
  }

  Future<void> logout() async {
    await _tokenStore.clear();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
