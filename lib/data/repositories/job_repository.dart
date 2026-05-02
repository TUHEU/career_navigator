import '../datasources/remote/api_service.dart';
import '../datasources/local/token_store.dart';
import '../models/job_model.dart';

class JobRepository {
  final ApiService _apiService = ApiService();
  final TokenStore _tokenStore = TokenStore();

  Future<List<JobListing>> getJobs({
    String? location,
    String? employmentType,
    String? search,
    int page = 1,
  }) async {
    final response = await _apiService.getJobs(
      location: location,
      employmentType: employmentType,
      search: search,
      page: page,
    );

    if (response['success'] == true) {
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => JobListing.fromJson(json)).toList();
    }
    throw Exception(response['message'] ?? 'Failed to load jobs');
  }

  Future<JobListing> getJobDetail(int jobId) async {
    final response = await _apiService.getJobDetail(jobId);

    if (response['success'] == true) {
      return JobListing.fromJson(response['data'] as Map<String, dynamic>);
    }
    throw Exception(response['message'] ?? 'Failed to load job details');
  }

  Future<void> applyForJob(int jobId, {String? coverLetter}) async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.applyForJob(
      token: token,
      jobId: jobId,
      coverLetter: coverLetter,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to apply for job');
    }
  }

  Future<List<JobApplication>> getMyApplications() async {
    final token = await _tokenStore.getAccess();
    if (token == null) throw Exception('Not authenticated');

    final response = await _apiService.getMyApplications(token);

    if (response['success'] == true) {
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => JobApplication.fromJson(json)).toList();
    }
    throw Exception(response['message'] ?? 'Failed to load applications');
  }

  Future<bool> hasApplied(int jobId) async {
    try {
      final applications = await getMyApplications();
      return applications.any((app) => app.jobId == jobId);
    } catch (e) {
      return false;
    }
  }
}
