import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';
import '../data/datasources/local/token_store.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final TokenStore _tokenStore = TokenStore();

  BaseUser? _currentUser;
  bool _isLoading = false;
  String? _error;

  BaseUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isJobSeeker => _currentUser is JobSeeker;
  bool get isMentor => _currentUser is Mentor;
  bool get isAdmin => _currentUser is Admin;

  Future<bool> loadProfile() async {
    _setLoading(true);
    _clearError();

    try {
      _currentUser = await _userRepository.getProfile();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> updateJobSeekerProfile(Map<String, dynamic> fields) async {
    _setLoading(true);
    _clearError();

    try {
      await _userRepository.updateJobSeekerProfile(fields);
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMentorProfile(Map<String, dynamic> fields) async {
    _setLoading(true);
    _clearError();

    try {
      await _userRepository.updateMentorProfile(fields);
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addEducation(Education education) async {
    _setLoading(true);
    _clearError();

    try {
      await _userRepository.addEducation(education);
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateEducation(int id, Education education) async {
    _setLoading(true);
    _clearError();

    try {
      await _userRepository.updateEducation(id, education);
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteEducation(int id) async {
    _setLoading(true);
    _clearError();

    try {
      await _userRepository.deleteEducation(id);
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addWorkExperience(WorkExperience work) async {
    _setLoading(true);
    _clearError();

    try {
      await _userRepository.addWorkExperience(work);
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateWorkExperience(int id, WorkExperience work) async {
    _setLoading(true);
    _clearError();

    try {
      await _userRepository.updateWorkExperience(id, work);
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteWorkExperience(int id) async {
    _setLoading(true);
    _clearError();

    try {
      await _userRepository.deleteWorkExperience(id);
      await loadProfile();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    _currentUser = null;
    _error = null;
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
