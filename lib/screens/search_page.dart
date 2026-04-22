import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/token_store.dart';
import '../theme/app_theme.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _ctrl = TextEditingController();
  List<dynamic> _mentors = [];
  List<dynamic> _seekers = [];
  bool _loading = false;
  bool _searched = false;

  Future<void> _search(String q) async {
    if (q.trim().length < 2) return;
    setState(() {
      _loading = true;
      _searched = true;
    });
    try {
      final token = await TokenStore.getAccess();
      if (token == null) return;
      final res = await ApiService.search(token: token, query: q.trim());
      if (res['success'] == true && mounted) {
        final data = res['data'] as Map<String, dynamic>;
        setState(() {
          _mentors = (data['mentors'] as List<dynamic>?) ?? [];
          _seekers = (data['seekers'] as List<dynamic>?) ?? [];
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Search', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: Colors.white),
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: 'Search mentors, job seekers...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryCyan,
                ),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        onPressed: () {
                          _ctrl.clear();
                          setState(() {
                            _mentors = [];
                            _seekers = [];
                            _searched = false;
                          });
                        },
                      )
                    : IconButton(
                        icon: const Icon(
                          Icons.send,
                          color: AppColors.primaryCyan,
                          size: 20,
                        ),
                        onPressed: () => _search(_ctrl.text),
                      ),
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

          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryCyan,
                    ),
                  )
                : !_searched
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.white12,
                          size: 60,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Search for mentors and job seekers',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
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
                        color: Colors.white.withOpacity(0.3),
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
                        _sectionTitle('Mentors (${_mentors.length})'),
                        const SizedBox(height: 10),
                        ..._mentors.map(
                          (m) => _UserCard(
                            user: m as Map<String, dynamic>,
                            isMentor: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (_seekers.isNotEmpty) ...[
                        _sectionTitle('Job Seekers (${_seekers.length})'),
                        const SizedBox(height: 10),
                        ..._seekers.map(
                          (s) => _UserCard(
                            user: s as Map<String, dynamic>,
                            isMentor: false,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      color: AppColors.primaryCyan,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      letterSpacing: 1,
    ),
  );
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final bool isMentor;
  const _UserCard({required this.user, required this.isMentor});

  @override
  Widget build(BuildContext context) {
    final name = (user['full_name'] as String?) ?? '—';
    final picture = user['profile_picture_url'] as String?;
    final headline = (user['headline'] as String?) ?? '';
    final jobTitle = (user['current_job_title'] as String?) ?? '';
    final company = (user['current_company'] as String?) ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryCyan.withOpacity(0.2),
            backgroundImage: picture != null ? NetworkImage(picture) : null,
            child: picture == null
                ? Text(
                    name.isNotEmpty ? name[0] : '?',
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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
                      color: Colors.white.withOpacity(0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isMentor ? 'Mentor' : 'Seeker',
              style: const TextStyle(
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
