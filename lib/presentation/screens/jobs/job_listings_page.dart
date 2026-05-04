import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/buttons.dart';
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
                      itemBuilder: (_, index) =>
                          _buildJobCard(_jobs[index], isDark),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: AppColors.primaryCyan,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job['title'] ?? '',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.lightText,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job['company'] ?? '',
                      style: const TextStyle(
                        color: AppColors.primaryCyan,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (job['employment_type'] ?? 'full_time')
                      .toString()
                      .replaceAll('_', ' ')
                      .toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primaryCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: isDark
                    ? Colors.white.withOpacity(0.4)
                    : Colors.grey.shade500,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                job['location'] ?? '',
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _applyForJob(job['id']),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Apply Now',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSubmitted;
  final VoidCallback? onClear;
  final bool isDark;
  const SearchField({
    super.key,
    required this.controller,
    required this.onSubmitted,
    this.onClear,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : Colors.grey.shade800),
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: 'Search jobs...',
        hintStyle: TextStyle(
          color: isDark ? Colors.white.withOpacity(0.35) : Colors.grey.shade500,
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.primaryCyan),
        suffixIcon: controller.text.isNotEmpty && onClear != null
            ? IconButton(
                icon: Icon(
                  Icons.clear,
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.grey.shade500,
                ),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryCyan),
        ),
      ),
    );
  }
}
