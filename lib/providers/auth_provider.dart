import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';
import '../data/datasources/local/token_store.dart';

class AuthProvider extends ChangeNotifier {
  late final AuthRepository _authRepository;
  late final UserRepository _userRepository;
  final TokenStore _tokenStore = TokenStore();

  BaseUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  BaseUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _authRepository = AuthRepository();
    _userRepository = UserRepository();
  }

  Future<String?> getAccessToken() async {
    return await _tokenStore.getAccess();
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    final response = await _authRepository.login(email, password);

    if (response['success'] == true) {
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
    try {
      _currentUser = await _userRepository.getProfile();
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _setLoading(true);
    _clearError();

    final response = await _authRepository.register(email, password);
    _setLoading(false);

    if (response['success'] != true) {
      _error = response['message'] ?? 'Registration failed';
    }
    return response['success'] == true;
  }

  Future<bool> verifyEmail(String email, String code) async {
    _setLoading(true);
    _clearError();

    final response = await _authRepository.verifyEmail(email, code);

    if (response['success'] == true) {
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

    final response = await _authRepository.resendCode(email);
    _setLoading(false);

    if (response['success'] != true) {
      _error = response['message'] ?? 'Failed to resend code';
    }
    return response['success'] == true;
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();

    final response = await _authRepository.forgotPassword(email);
    _setLoading(false);

    if (response['success'] != true) {
      _error = response['message'] ?? 'Failed to send reset code';
    }
    return response['success'] == true;
  }

  Future<bool> resetPassword(String email, String code, String password) async {
    _setLoading(true);
    _clearError();

    final response = await _authRepository.resetPassword(
      email: email,
      code: code,
      password: password,
    );
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

    try {
      await _userRepository.setupProfile(
        fullName: fullName,
        dob: dob,
        role: role,
      );
      final success = await loadUserProfile();
      _setLoading(false);
      return success;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
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
