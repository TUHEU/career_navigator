import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

class UserProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> loadProfile() async {
    _setLoading(true);
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
    try {
      await _userRepository.addEducation(education);
      await loadProfile();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteEducation(int id) async {
    _setLoading(true);
    try {
      await _userRepository.deleteEducation(id);
      await loadProfile();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addWorkExperience(WorkExperience work) async {
    _setLoading(true);
    try {
      await _userRepository.addWorkExperience(work);
      await loadProfile();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteWorkExperience(int id) async {
    _setLoading(true);
    try {
      await _userRepository.deleteWorkExperience(id);
      await loadProfile();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
