// providers/saved_jobs_provider.dart — v10
import 'package:flutter/material.dart';
import '../data/datasources/remote/api_service.dart';
import '../data/datasources/local/token_store.dart';
import '../data/models/job_model.dart';

class SavedJobsProvider extends ChangeNotifier {
  final _api   = ApiService();
  final _store = TokenStore();

  List<JobListing> _saved  = [];
  Set<int> _savedIds        = {};
  bool _loading             = false;

  List<JobListing> get saved => _saved;
  bool get isLoading         => _loading;
  bool isSaved(int jobId)    => _savedIds.contains(jobId);

  Future<void> loadSaved() async {
    _loading = true; notifyListeners();
    try {
      final token = await _store.getAccess() ?? '';
      final res   = await _api.getSavedJobs(token: token);
      if (res['success'] == true) {
        final list = res['data'] as List<dynamic>? ?? [];
        _saved    = list.map((e) => JobListing.fromJson(e as Map<String,dynamic>)).toList();
        _savedIds = _saved.map((j) => j.id).toSet();
      }
    } catch (_) {} finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> toggle(int jobId) async {
    final wasSaved = _savedIds.contains(jobId);
    // Optimistic
    if (wasSaved) {
      _savedIds.remove(jobId);
      _saved.removeWhere((j) => j.id == jobId);
    } else {
      _savedIds.add(jobId);
    }
    notifyListeners();
    try {
      final token = await _store.getAccess() ?? '';
      if (wasSaved) {
        await _api.unsaveJob(token: token, jobId: jobId);
      } else {
        await _api.saveJob(token: token, jobId: jobId);
        await loadSaved(); // refresh to get full job data
      }
    } catch (_) {
      // Revert
      if (wasSaved) { _savedIds.add(jobId); }
      else          { _savedIds.remove(jobId); }
      notifyListeners();
    }
  }
}
