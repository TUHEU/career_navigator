// presentation/screens/jobs/saved_jobs_page.dart — v10
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../providers/saved_jobs_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/loading_widgets.dart';
import 'job_detail_page.dart';

class SavedJobsPage extends StatefulWidget {
  const SavedJobsPage({super.key});
  @override
  State<SavedJobsPage> createState() => _SavedJobsPageState();
}

class _SavedJobsPageState extends State<SavedJobsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavedJobsProvider>().loadSaved();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final sp     = context.watch<SavedJobsProvider>();

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: Text('Saved Jobs', style: TextStyle(
          color: AppColors.text(isDark), fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background(isDark), elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(isDark)),
      ),
      body: sp.isLoading
          ? const LoadingIndicator(message: 'Loading saved jobs...')
          : sp.saved.isEmpty
            ? _EmptyState(isDark: isDark)
            : RefreshIndicator(
                color: AppColors.primaryCyan,
                onRefresh: () => sp.loadSaved(),
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  itemCount: sp.saved.length,
                  itemBuilder: (_, i) {
                    final job = sp.saved[i];
                    final salary = job.salaryMin != null
                        ? '\$${job.salaryMin}–\$${job.salaryMax}/mo' : null;
                    return GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => JobDetailPage(job: job))),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.card(isDark),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.border(isDark))),
                        child: Row(children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryCyan.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.business_center,
                                color: AppColors.primaryCyan, size: 22)),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(job.title, style: TextStyle(
                              color: AppColors.text(isDark),
                              fontWeight: FontWeight.bold, fontSize: 14),
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 2),
                            Text(job.company, style: const TextStyle(
                              color: AppColors.primaryCyan, fontSize: 12)),
                            const SizedBox(height: 4),
                            Row(children: [
                              Icon(Icons.location_on_outlined,
                                  size: 11, color: AppColors.textMuted(isDark)),
                              const SizedBox(width: 2),
                              Text(job.location, style: TextStyle(
                                color: AppColors.textMuted(isDark), fontSize: 11),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                              if (salary != null) ...[
                                const SizedBox(width: 8),
                                Text(salary, style: const TextStyle(
                                  color: Color(0xFF059669), fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                              ],
                            ]),
                          ])),
                          IconButton(
                            icon: const Icon(Icons.bookmark_rounded,
                                color: AppColors.primaryCyan, size: 22),
                            onPressed: () => sp.toggle(job.id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints()),
                        ]),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});
  @override
  Widget build(BuildContext context) => Center(child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.bookmark_outline_rounded, size: 72,
          color: AppColors.textMuted(isDark)),
      const SizedBox(height: 16),
      Text('No saved jobs yet', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      Text('Bookmark jobs you like and find them here',
        style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 13)),
    ],
  ));
}
