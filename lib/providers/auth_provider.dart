import 'package:flutter/material.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  final UserRepository _userRepository = UserRepository();

  BaseUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  BaseUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

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
