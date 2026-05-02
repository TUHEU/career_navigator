import '../datasources/remote/api_service.dart';
import '../datasources/local/token_store.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiService _apiService = ApiService();
  final TokenStore _tokenStore = TokenStore();

  Future<BaseUser> getProfile() async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.getProfile(token);
    if (response['success'] == true) {
      return UserFactory.createUser(response['data'] as Map<String, dynamic>);
    }
    throw Exception(response['message'] ?? 'Failed to load profile');
  }

  Future<void> setupProfile({
    required String fullName,
    required String dob,
    required String role,
  }) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.setupProfile(
      token: token,
      fullName: fullName,
      dob: dob,
      role: role,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to setup profile');
    }
  }

  Future<void> updateJobSeekerProfile(Map<String, dynamic> fields) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.updateJobSeekerProfile(
      token: token,
      fields: fields,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to update profile');
    }
  }

  Future<void> updateMentorProfile(Map<String, dynamic> fields) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.updateMentorProfile(
      token: token,
      fields: fields,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to update mentor profile');
    }
  }

  Future<void> addEducation(Education education) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.addEducation(
      token: token,
      data: education.toJson(),
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to add education');
    }
  }

  Future<void> updateEducation(int id, Education education) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.updateEducation(
      token: token,
      id: id,
      data: education.toJson(),
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to update education');
    }
  }

  Future<void> deleteEducation(int id) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.deleteEducation(token: token, id: id);
    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to delete education');
    }
  }

  Future<void> addWorkExperience(WorkExperience work) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.addWorkExperience(
      token: token,
      data: work.toJson(),
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to add work experience');
    }
  }

  Future<void> updateWorkExperience(int id, WorkExperience work) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.updateWorkExperience(
      token: token,
      id: id,
      data: work.toJson(),
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ?? 'Failed to update work experience',
      );
    }
  }

  Future<void> deleteWorkExperience(int id) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.deleteWorkExperience(
      token: token,
      id: id,
    );
    if (response['success'] != true) {
      throw Exception(
        response['message'] ?? 'Failed to delete work experience',
      );
    }
  }
}
