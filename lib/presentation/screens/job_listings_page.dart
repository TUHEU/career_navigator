import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/token_store.dart';
import '../../core/themes/app_theme.dart';
import '../../widgets/shared_widgets.dart';

class JobListingsPage extends StatefulWidget {
  const JobListingsPage({super.key});

  @override
  State<JobListingsPage> createState() => _JobListingsPageState();
}

class _JobListingsPageState extends State<JobListingsPage> {
  List<dynamic> _jobs = [];
  bool _loading = true;
  String _searchQuery = '';
  String? _selectedLocation;
  String? _selectedType;

  final List<String> _locations = ['All', 'Remote', 'Hybrid', 'Onsite'];
  final List<String> _jobTypes = [
    'All',
    'full_time',
    'part_time',
    'contract',
    'internship',
    'freelance',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocation = 'All';
    _selectedType = 'All';
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => _loading = true);
    try {
      final token = await TokenStore.getAccess();
      if (token == null) return;

      final res = await ApiService.getJobs(
        location: _selectedLocation != 'All' ? _selectedLocation : null,
        employmentType: _selectedType != 'All' ? _selectedType : null,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
      );

      if (res['success'] == true && mounted) {
        setState(() {
          _jobs = (res['data'] as List<dynamic>?) ?? [];
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _applyForJob(int jobId) async {
    final token = await TokenStore.getAccess();
    if (token == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login to apply')));
      return;
    }

    final coverLetterCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Apply for Job',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: coverLetterCtrl,
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
              decoration: buildInputDecoration(
                icon: Icons.edit_note,
                label: 'Cover Letter (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _loading = true);
              try {
                final res = await ApiService.applyForJob(
                  token: token,
                  jobId: jobId,
                  coverLetter: coverLetterCtrl.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res['message'] ?? 'Application submitted!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to apply. Try again.'),
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
            child: const Text(
              'Submit',
              style: TextStyle(color: AppColors.primaryCyan),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Job Listings',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                _searchQuery = value;
                _loadJobs();
              },
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryCyan,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        onPressed: () {
                          _searchQuery = '';
                          _loadJobs();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white.withOpacity(0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryCyan),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Location: ',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                ..._locations.map(
                  (loc) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(loc),
                      selected: _selectedLocation == loc,
                      onSelected: (selected) {
                        setState(() {
                          _selectedLocation = selected ? loc : 'All';
                        });
                        _loadJobs();
                      },
                      backgroundColor: Colors.white.withOpacity(0.05),
                      selectedColor: AppColors.primaryCyan.withOpacity(0.3),
                      labelStyle: TextStyle(
                        color: _selectedLocation == loc
                            ? AppColors.primaryCyan
                            : Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Type: ',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                ..._jobTypes.map(
                  (type) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.replaceAll('_', ' ').toUpperCase()),
                      selected: _selectedType == type,
                      onSelected: (selected) {
                        setState(() {
                          _selectedType = selected ? type : 'All';
                        });
                        _loadJobs();
                      },
                      backgroundColor: Colors.white.withOpacity(0.05),
                      selectedColor: AppColors.primaryCyan.withOpacity(0.3),
                      labelStyle: TextStyle(
                        color: _selectedType == type
                            ? AppColors.primaryCyan
                            : Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryCyan,
                    ),
                  )
                : _jobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.work_off,
                          color: Colors.white24,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No jobs found',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadJobs,
                    color: AppColors.primaryCyan,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: _jobs.length,
                      itemBuilder: (_, i) {
                        final job = _jobs[i] as Map<String, dynamic>;
                        return JobCard(
                          job: job,
                          onApply: () => _applyForJob(job['id']),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
