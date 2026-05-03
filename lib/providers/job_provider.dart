import 'package:flutter/material.dart';
import '../data/models/job_model.dart';
import '../data/repositories/job_repository.dart';

class JobProvider extends ChangeNotifier {
  final JobRepository _jobRepository = JobRepository();

  List<JobListing> _jobs = [];
  List<JobApplication> _applications = [];
  bool _isLoading = false;
  String? _error;
  String _selectedLocation = 'All';
  String _selectedType = 'All';
  String _searchQuery = '';

  List<JobListing> get jobs => _jobs;
  List<JobApplication> get applications => _applications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadJobs() async {
    _setLoading(true);
    try {
      _jobs = await _jobRepository.getJobs(
        location: _selectedLocation != 'All' ? _selectedLocation : null,
        employmentType: _selectedType != 'All' ? _selectedType : null,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<void> loadApplications() async {
    _setLoading(true);
    try {
      _applications = await _jobRepository.getMyApplications();
      _setLoading(false);
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
    }
  }

  Future<bool> applyForJob(int jobId, {String? coverLetter}) async {
    _setLoading(true);
    try {
      await _jobRepository.applyForJob(jobId, coverLetter: coverLetter);
      await loadApplications();
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> hasApplied(int jobId) async {
    try {
      return await _jobRepository.hasApplied(jobId);
    } catch (e) {
      return false;
    }
  }

  void setLocationFilter(String location) {
    _selectedLocation = location;
    loadJobs();
  }

  void setTypeFilter(String type) {
    _selectedType = type;
    loadJobs();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadJobs();
  }

  void clearFilters() {
    _selectedLocation = 'All';
    _selectedType = 'All';
    _searchQuery = '';
    loadJobs();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
