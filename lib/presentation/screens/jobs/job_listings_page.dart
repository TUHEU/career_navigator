import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/buttons.dart';
import '../../widgets/shared/cards.dart';
import '../../widgets/shared/inputs.dart';
import '../../widgets/shared/loading_widgets.dart';

class JobListingsPage extends StatefulWidget {
  const JobListingsPage({super.key});

  @override
  State<JobListingsPage> createState() => _JobListingsPageState();
}

class _JobListingsPageState extends State<JobListingsPage> {
  final ApiService _apiService = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _jobs = [];
  bool _isLoading = true;
  String _selectedLocation = 'All';
  String _selectedType = 'All';

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
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);

    final response = await _apiService.getJobs(
      location: _selectedLocation != 'All' ? _selectedLocation : null,
      employmentType: _selectedType != 'All' ? _selectedType : null,
      search: _searchController.text.isNotEmpty ? _searchController.text : null,
    );

    if (mounted && response['success'] == true) {
      setState(() {
        _jobs = List<Map<String, dynamic>>.from(response['data'] ?? []);
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _applyForJob(int jobId) async {
    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) {
      Helpers.showSnackBar(context, 'Please login to apply', isError: true);
      return;
    }

    final coverLetterController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apply for Job',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Cover Letter (optional)'),
            const SizedBox(height: 8),
            TextField(
              controller: coverLetterController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your cover letter here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      setState(() => _isLoading = true);

                      final response = await _apiService.applyForJob(
                        token: token,
                        jobId: jobId,
                        coverLetter: coverLetterController.text.trim(),
                      );

                      if (mounted) {
                        setState(() => _isLoading = false);
                        if (response['success'] == true) {
                          Helpers.showSnackBar(
                            context,
                            'Application submitted!',
                          );
                        } else {
                          Helpers.showSnackBar(
                            context,
                            response['message'] ?? 'Failed to apply',
                            isError: true,
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCyan,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Submit Application'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    _loadJobs();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Job Listings')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchField(
              controller: _searchController,
              onSubmitted: (_) => _loadJobs(),
              onClear: _clearSearch,
              isDark: isDark,
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Location: ',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : AppColors.lightTextSecondary,
                    fontSize: 12,
                  ),
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
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100,
                      selectedColor: AppColors.primaryCyan.withOpacity(0.3),
                      labelStyle: TextStyle(
                        color: _selectedLocation == loc
                            ? AppColors.primaryCyan
                            : (isDark
                                  ? Colors.white70
                                  : AppColors.lightTextSecondary),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Type: ',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white70
                        : AppColors.lightTextSecondary,
                    fontSize: 12,
                  ),
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
                      backgroundColor: isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.grey.shade100,
                      selectedColor: AppColors.primaryCyan.withOpacity(0.3),
                      labelStyle: TextStyle(
                        color: _selectedType == type
                            ? AppColors.primaryCyan
                            : (isDark
                                  ? Colors.white70
                                  : AppColors.lightTextSecondary),
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
            child: _isLoading
                ? const LoadingIndicator()
                : _jobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.work_off,
                          size: 64,
                          color: isDark ? Colors.white24 : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No jobs found',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.4)
                                : Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.3)
                                : Colors.grey.shade500,
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
                      itemBuilder: (_, index) {
                        final job = _jobs[index];
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
