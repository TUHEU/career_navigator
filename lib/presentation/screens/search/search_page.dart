import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/inputs.dart';
import '../../widgets/shared/loading_widgets.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  List<Map<String, dynamic>> _mentors = [];
  List<Map<String, dynamic>> _seekers = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  bool _isSending = false;
  int? _sendingTo;

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.length < 2) {
      Helpers.showSnackBar(
        context,
        'Enter at least 2 characters',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) {
      setState(() => _isLoading = false);
      Helpers.showSnackBar(context, 'Please login to search', isError: true);
      return;
    }

    final response = await _apiService.search(token: token, query: query);

    if (mounted && response['success'] == true) {
      final data = response['data'] as Map<String, dynamic>;
      setState(() {
        _mentors = List<Map<String, dynamic>>.from(data['mentors'] ?? []);
        _seekers = List<Map<String, dynamic>>.from(data['seekers'] ?? []);
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
      Helpers.showSnackBar(
        context,
        response['message'] ?? 'Search failed',
        isError: true,
      );
    }
  }

  Future<void> _sendInvite(int userId, String name) async {
    setState(() {
      _isSending = true;
      _sendingTo = userId;
    });
    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) {
      setState(() => _isSending = false);
      Helpers.showSnackBar(
        context,
        'Please login to send invites',
        isError: true,
      );
      return;
    }
    final response = await _apiService.sendMentorRequest(
      token: token,
      mentorId: userId,
      message: 'I would like to connect with you as my mentor.',
    );
    if (mounted) {
      setState(() => _isSending = false);
      if (response['success'] == true) {
        Helpers.showSnackBar(context, 'Invite sent to $name!');
      } else {
        Helpers.showSnackBar(
          context,
          response['message'] ?? 'Failed to send invite',
          isError: true,
        );
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _mentors = [];
      _seekers = [];
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Search & Connect')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchField(
              controller: _searchController,
              onSubmitted: (_) => _search(),
              onClear: _clearSearch,
              isDark: isDark,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const LoadingIndicator()
                : !_hasSearched
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: isDark ? Colors.white24 : Colors.grey.shade400,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Search for mentors and professionals',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.3)
                                : Colors.grey.shade500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : (_mentors.isEmpty && _seekers.isEmpty)
                ? Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.3)
                            : Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: [
                      if (_mentors.isNotEmpty) ...[
                        Text(
                          'Mentors (${_mentors.length})',
                          style: const TextStyle(
                            color: AppColors.primaryCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._mentors.map(
                          (mentor) => _buildUserCard(mentor, true, isDark),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (_seekers.isNotEmpty) ...[
                        Text(
                          'Job Seekers (${_seekers.length})',
                          style: const TextStyle(
                            color: AppColors.primaryCyan,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._seekers.map(
                          (seeker) => _buildUserCard(seeker, false, isDark),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isMentor, bool isDark) {
    final name = user['full_name'] ?? 'Unknown';
    final picture = user['profile_picture_url'] as String?;
    final headline = user['headline'] as String? ?? '';
    final jobTitle = user['current_job_title'] as String? ?? '';
    final company = user['current_company'] as String? ?? '';
    final userId = user['id'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
            backgroundImage: picture != null ? NetworkImage(picture) : null,
            child: picture == null
                ? Text(
                    Helpers.getInitials(name),
                    style: const TextStyle(
                      color: AppColors.primaryCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : AppColors.lightText,
                  ),
                ),
                if (headline.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    headline,
                    style: const TextStyle(
                      color: AppColors.primaryCyan,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (jobTitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    company.isNotEmpty ? '$jobTitle @ $company' : jobTitle,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withOpacity(0.45)
                          : AppColors.lightTextSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isMentor)
            _isSending && _sendingTo == userId
                ? const SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryCyan,
                    ),
                  )
                : ElevatedButton(
                    onPressed: () => _sendInvite(userId, name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCyan,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Invite',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryCyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Seeker',
                style: TextStyle(
                  color: AppColors.primaryCyan,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
