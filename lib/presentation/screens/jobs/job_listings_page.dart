// presentation/screens/jobs/job_listings_page.dart
// v9 — Fully redesigned: category tabs, salary display, bookmark,
//       apply modal with cover letter, animated cards, TalentBridge-inspired
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guest_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/loading_widgets.dart';

class JobListingsPage extends StatefulWidget {
  const JobListingsPage({super.key});
  @override
  State<JobListingsPage> createState() => _JobListingsPageState();
}

class _JobListingsPageState extends State<JobListingsPage>
    with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final _searchCtrl = TextEditingController();
  late TabController _tabCtrl;

  List<Map<String, dynamic>> _jobs = [];
  bool _loading = true;
  String _locFilter = 'All';
  String _typeFilter = 'All';
  final Set<int> _bookmarked = {};
  int? _applyingId;

  static const _locs  = ['All', 'Remote', 'Hybrid', 'Onsite'];
  static const _types = ['All', 'Full Time', 'Part Time', 'Contract', 'Internship'];
  static const _typeKeys = ['All', 'full_time', 'part_time', 'contract', 'internship'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _locs.length, vsync: this);
    _tabCtrl.addListener(() {
      if (_tabCtrl.indexIsChanging) {
        setState(() => _locFilter = _locs[_tabCtrl.index]);
        _load();
      }
    });
    _load();
  }

  @override
  void dispose() {
    _tabCtrl.dispose(); _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final loc  = _locFilter != 'All' ? _locFilter : null;
    final type = _typeFilter != 'All' ? _typeKeys[_types.indexOf(_typeFilter)] : null;
    final q    = _searchCtrl.text.trim().isNotEmpty ? _searchCtrl.text.trim() : null;
    final res  = await _api.getJobs(location: loc, employmentType: type, search: q);
    if (mounted && res['success'] == true) {
      setState(() {
        _jobs = List<Map<String, dynamic>>.from(res['data'] ?? []);
        _loading = false;
      });
    } else if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _apply(Map<String, dynamic> job) async {
    final guest = context.read<GuestProvider>();
    if (guest.isGuest) {
      Helpers.showSnackBar(context, 'Sign in to apply for jobs', isError: true);
      return;
    }
    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) return;
    _showApplyModal(job, token);
  }

  void _showApplyModal(Map<String, dynamic> job, String token) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final coverCtrl = TextEditingController();

    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppColors.surface(isDark),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Handle
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border(isDark),
              borderRadius: BorderRadius.circular(2)),
          )),
          const SizedBox(height: 20),
          Text('Apply for ${job['title'] ?? 'Job'}', style: TextStyle(
            color: AppColors.text(isDark), fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(job['company'] ?? '', style: const TextStyle(
            color: AppColors.primaryCyan, fontSize: 14)),
          const SizedBox(height: 20),
          Text('Cover Letter (optional)', style: TextStyle(
            color: AppColors.textSecondary(isDark), fontSize: 13,
            fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: coverCtrl, maxLines: 5,
            style: TextStyle(color: AppColors.text(isDark), fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Tell them why you\'re a great fit...',
              hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
              filled: true,
              fillColor: AppColors.card(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border(isDark))),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border(isDark))),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppColors.primaryCyan))),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: AppColors.border(isDark)),
                foregroundColor: AppColors.text(isDark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Cancel'),
            )),
            const SizedBox(width: 12),
            Expanded(child: StatefulBuilder(
              builder: (_, setSt) {
                bool submitting = false;
                return ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    setState(() => _applyingId = job['id']);
                    final res = await _api.applyForJob(
                      token: token, jobId: job['id'],
                      coverLetter: coverCtrl.text.trim());
                    if (mounted) {
                      setState(() => _applyingId = null);
                      if (res['success'] == true) {
                        Helpers.showSnackBar(context, '🎉 Application submitted!');
                      } else {
                        Helpers.showSnackBar(context,
                          res['message'] ?? 'Failed to apply', isError: true);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            )),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(child: Column(children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Job Listings', style: TextStyle(
              color: AppColors.text(isDark), fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${_jobs.length} opportunities found', style: TextStyle(
              color: AppColors.textMuted(isDark), fontSize: 13)),
            const SizedBox(height: 14),
            // Search bar
            TextField(
              controller: _searchCtrl,
              style: TextStyle(color: AppColors.text(isDark)),
              onSubmitted: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Search jobs, companies...',
                hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryCyan),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: AppColors.textMuted(isDark)),
                        onPressed: () { _searchCtrl.clear(); _load(); })
                    : null,
                filled: true,
                fillColor: AppColors.card(isDark),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: AppColors.border(isDark))),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.primaryCyan))),
            ),
            const SizedBox(height: 12),
            // Type filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: _types.asMap().entries.map((e) {
                final sel = _typeFilter == e.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _typeFilter = e.value);
                      _load();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppColors.primaryCyan.withOpacity(0.15)
                            : AppColors.card(isDark),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel
                            ? AppColors.primaryCyan : AppColors.border(isDark))),
                      child: Text(e.value, style: TextStyle(
                        color: sel ? AppColors.primaryCyan : AppColors.textMuted(isDark),
                        fontSize: 12, fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
                    ),
                  ),
                );
              }).toList()),
            ),
          ]),
        ),
        // Location tabs
        TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primaryCyan,
          unselectedLabelColor: AppColors.textMuted(isDark),
          indicatorColor: AppColors.primaryCyan,
          indicatorWeight: 2,
          dividerColor: AppColors.border(isDark),
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: _locs.map((l) => Tab(text: l)).toList(),
        ),

        // Job list
        Expanded(child: _loading
            ? const LoadingIndicator()
            : _jobs.isEmpty
              ? _EmptyState(isDark: isDark)
              : RefreshIndicator(
                  onRefresh: _load, color: AppColors.primaryCyan,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    itemCount: _jobs.length,
                    itemBuilder: (_, i) => _JobCard(
                      job: _jobs[i], isDark: isDark,
                      bookmarked: _bookmarked.contains(_jobs[i]['id']),
                      isApplying: _applyingId == _jobs[i]['id'],
                      onBookmark: () => setState(() {
                        final id = _jobs[i]['id'] as int;
                        _bookmarked.contains(id)
                            ? _bookmarked.remove(id)
                            : _bookmarked.add(id);
                      }),
                      onApply: () => _apply(_jobs[i]),
                    ),
                  ),
                )),
      ])),
    );
  }
}

// ── Job Card ──────────────────────────────────────────────────────
class _JobCard extends StatelessWidget {
  final Map<String, dynamic> job;
  final bool isDark, bookmarked, isApplying;
  final VoidCallback onBookmark, onApply;
  const _JobCard({
    required this.job, required this.isDark,
    required this.bookmarked, required this.isApplying,
    required this.onBookmark, required this.onApply,
  });

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'full_time': return const Color(0xFF059669);
      case 'part_time': return const Color(0xFF7C3AED);
      case 'contract':  return const Color(0xFFF59E0B);
      case 'internship':return const Color(0xFF3B82F6);
      default:          return AppColors.primaryCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final type   = (job['employment_type'] ?? 'full_time').toString();
    final salary = job['salary_min'] != null && job['salary_max'] != null
        ? '\$${job['salary_min']?.toStringAsFixed(0)}–\$${job['salary_max']?.toStringAsFixed(0)}/mo'
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border(isDark)),
        boxShadow: isDark ? [] : [BoxShadow(
          color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Top row
        Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.business_center,
                color: AppColors.primaryCyan, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(job['title'] ?? '', style: TextStyle(
              color: AppColors.text(isDark), fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(job['company'] ?? '', style: const TextStyle(
              color: AppColors.primaryCyan, fontSize: 13, fontWeight: FontWeight.w500)),
          ])),
          IconButton(
            icon: Icon(
              bookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
              color: bookmarked ? AppColors.primaryCyan : AppColors.textMuted(isDark),
              size: 22),
            onPressed: onBookmark,
            padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ]),
        const SizedBox(height: 12),
        // Tags row
        Wrap(spacing: 6, runSpacing: 6, children: [
          _Tag(type.replaceAll('_', ' ').toUpperCase(), _typeColor(type)),
          if (job['location_type'] != null)
            _Tag(job['location_type'].toString(), AppColors.primaryCyan),
          if (salary != null) _Tag(salary, const Color(0xFF059669)),
        ]),
        const SizedBox(height: 12),
        // Location + deadline
        Row(children: [
          Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted(isDark)),
          const SizedBox(width: 4),
          Text(job['location'] ?? 'Location', style: TextStyle(
            color: AppColors.textMuted(isDark), fontSize: 12)),
          const Spacer(),
          if (job['deadline'] != null) ...[
            Icon(Icons.schedule, size: 12, color: AppColors.textMuted(isDark)),
            const SizedBox(width: 3),
            Text('Closes ${job['deadline']}', style: TextStyle(
              color: AppColors.textMuted(isDark), fontSize: 11)),
          ],
        ]),
        const SizedBox(height: 14),
        // Apply button
        SizedBox(width: double.infinity,
          child: ElevatedButton(
            onPressed: isApplying ? null : onApply,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCyan,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              disabledBackgroundColor: AppColors.primaryCyan.withOpacity(0.5)),
            child: isApplying
                ? const SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                : const Text('Apply Now',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ),
      ]),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text; final Color color;
  const _Tag(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3))),
    child: Text(text, style: TextStyle(
      color: color, fontSize: 10, fontWeight: FontWeight.bold)),
  );
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.work_off_outlined, size: 72, color: AppColors.textMuted(isDark)),
      const SizedBox(height: 16),
      Text('No jobs found', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text('Try adjusting filters or search terms', style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 13)),
    ],
  ));
}
