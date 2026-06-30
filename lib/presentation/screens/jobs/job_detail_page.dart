// presentation/screens/jobs/job_detail_page.dart — v10
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/models/job_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/saved_jobs_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/datasources/remote/api_service.dart';

class JobDetailPage extends StatefulWidget {
  final JobListing job;
  const JobDetailPage({super.key, required this.job});
  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  bool _applying = false;
  final _coverCtrl = TextEditingController();

  @override
  void dispose() { _coverCtrl.dispose(); super.dispose(); }

  Color _typeColor(String t) {
    switch (t) {
      case 'full_time':  return const Color(0xFF059669);
      case 'part_time':  return const Color(0xFF7C3AED);
      case 'contract':   return const Color(0xFFF59E0B);
      case 'internship': return const Color(0xFF3B82F6);
      default:           return AppColors.primaryCyan;
    }
  }

  String _typeLabel(String t) => t.replaceAll('_', ' ')
      .split(' ').map((w) => w.isNotEmpty
          ? w[0].toUpperCase() + w.substring(1) : '').join(' ');

  void _showApplySheet(bool isDark) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppColors.surface(isDark),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border(isDark),
              borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Apply for ${widget.job.title}', style: TextStyle(
            color: AppColors.text(isDark), fontSize: 18,
            fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.job.company, style: const TextStyle(
            color: AppColors.primaryCyan, fontSize: 13)),
          const SizedBox(height: 18),
          Text('Cover Letter (optional)', style: TextStyle(
            color: AppColors.textSecondary(isDark), fontSize: 13,
            fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _coverCtrl, maxLines: 5,
            style: TextStyle(color: AppColors.text(isDark)),
            decoration: InputDecoration(
              hintText: "Tell them why you're a great fit...",
              hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
              filled: true, fillColor: AppColors.card(isDark),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
              child: const Text('Cancel'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: _applying ? null : () async {
                Navigator.pop(ctx);
                await _apply();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14))),
              child: const Text('Submit',
                style: TextStyle(fontWeight: FontWeight.bold)))),
          ]),
        ]),
      ),
    );
  }

  Future<void> _apply() async {
    final token = await context.read<AuthProvider>().getAccessToken();
    if (token == null) return;
    setState(() => _applying = true);
    final res = await ApiService().applyForJob(
      token: token, jobId: widget.job.id,
      coverLetter: _coverCtrl.text.trim());
    if (mounted) {
      setState(() => _applying = false);
      if (res['success'] == true) {
        Helpers.showSnackBar(context, '🎉 Application submitted!');
      } else {
        Helpers.showSnackBar(context,
          res['message'] ?? 'Failed to apply', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = context.watch<ThemeProvider>().isDarkMode;
    final saved   = context.watch<SavedJobsProvider>();
    final job     = widget.job;
    final isSaved = saved.isSaved(job.id);
    final salary  = job.salaryMin != null && job.salaryMax != null
        ? '\$${job.salaryMin}–\$${job.salaryMax}/${job.salaryCurrency}/mo'
        : null;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: CustomScrollView(slivers: [
        // App bar
        SliverAppBar(
          pinned: true, expandedHeight: 0,
          backgroundColor: AppColors.background(isDark), elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.text(isDark)),
            onPressed: () => Navigator.pop(context)),
          actions: [
            IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                color: isSaved ? AppColors.primaryCyan : AppColors.text(isDark)),
              onPressed: () => saved.toggle(job.id)),
            IconButton(
              icon: Icon(Icons.share_outlined, color: AppColors.text(isDark)),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: '${job.title} at ${job.company}'));
                Helpers.showSnackBar(context, 'Job link copied!');
              }),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          sliver: SliverList(delegate: SliverChildListDelegate([

            // Company & Title
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryCyan.withOpacity(0.2))),
                child: const Icon(Icons.business_center,
                    color: AppColors.primaryCyan, size: 28)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(job.title, style: TextStyle(
                  color: AppColors.text(isDark), fontSize: 20,
                  fontWeight: FontWeight.bold, height: 1.2)),
                const SizedBox(height: 4),
                Text(job.company, style: const TextStyle(
                  color: AppColors.primaryCyan, fontSize: 14,
                  fontWeight: FontWeight.w600)),
              ])),
            ]),
            const SizedBox(height: 16),

            // Tags
            Wrap(spacing: 8, runSpacing: 8, children: [
              _Tag(_typeLabel(job.employmentType),
                  _typeColor(job.employmentType)),
              _Tag(_typeLabel(job.locationType), AppColors.primaryCyan),
              if (salary != null) _Tag(salary, const Color(0xFF059669)),
              _Tag(_typeLabel(job.experienceLevel), const Color(0xFFF59E0B)),
            ]),
            const SizedBox(height: 16),

            // Info row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border(isDark))),
              child: Column(children: [
                _InfoRow(Icons.location_on_outlined, 'Location', job.location, isDark),
                const Divider(height: 20),
                _InfoRow(Icons.people_outline, 'Applications',
                  '${job.applicationsCount} applied', isDark),
                if (job.expiresAt != null) ...[
                  const Divider(height: 20),
                  _InfoRow(Icons.schedule_outlined, 'Deadline',
                    '${job.expiresAt!.day}/${job.expiresAt!.month}/${job.expiresAt!.year}',
                    isDark),
                ],
              ]),
            ),
            const SizedBox(height: 24),

            // Description
            _Section('About the Role', isDark),
            Text(job.description, style: TextStyle(
              color: AppColors.textSecondary(isDark), fontSize: 14, height: 1.7)),
            const SizedBox(height: 24),

            // Requirements
            _Section('Requirements', isDark),
            ...job.requirements.split('\n').where((l) => l.trim().isNotEmpty)
                .map((l) => _Bullet(l.replaceAll('- ', '').trim(), isDark)),
            const SizedBox(height: 24),

            // Responsibilities
            _Section('Responsibilities', isDark),
            ...job.responsibilities.split('\n').where((l) => l.trim().isNotEmpty)
                .map((l) => _Bullet(l.replaceAll('- ', '').trim(), isDark)),
            const SizedBox(height: 24),

            // Skills required
            if (job.skillsRequired != null && job.skillsRequired!.isNotEmpty) ...[
              _Section('Skills Required', isDark),
              Wrap(spacing: 8, runSpacing: 8, children: job.skillsRequired!
                  .map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryCyan.withOpacity(0.25))),
                    child: Text(s, style: const TextStyle(
                      color: AppColors.primaryCyan, fontSize: 12,
                      fontWeight: FontWeight.w600)))).toList()),
              const SizedBox(height: 24),
            ],

            // Benefits
            if (job.benefits != null && job.benefits!.isNotEmpty) ...[
              _Section('Benefits & Perks', isDark),
              ...job.benefits!.split('\n').where((l) => l.trim().isNotEmpty)
                  .map((l) => _Bullet(l.replaceAll('- ', '').trim(), isDark,
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFF059669))),
            ],
          ])),
        ),
      ]),

      // Apply button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: BoxDecoration(
          color: AppColors.surface(isDark),
          border: Border(top: BorderSide(color: AppColors.border(isDark)))),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _applying ? null : () => _showApplySheet(isDark),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryCyan, foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              disabledBackgroundColor: AppColors.primaryCyan.withOpacity(0.5)),
            child: _applying
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black))
                : const Text('Apply Now',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text; final Color color;
  const _Tag(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3))),
    child: Text(text, style: TextStyle(
      color: color, fontSize: 11, fontWeight: FontWeight.bold)));
}

class _Section extends StatelessWidget {
  final String title; final bool isDark;
  const _Section(this.title, this.isDark);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(title, style: TextStyle(
      color: AppColors.text(isDark), fontSize: 16, fontWeight: FontWeight.bold)));
}

class _Bullet extends StatelessWidget {
  final String text; final bool isDark;
  final IconData icon; final Color color;
  const _Bullet(this.text, this.isDark, {
    this.icon = Icons.arrow_right_rounded,
    this.color = AppColors.primaryCyan,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: TextStyle(
        color: AppColors.textSecondary(isDark), fontSize: 13, height: 1.5))),
    ]));
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String label, value; final bool isDark;
  const _InfoRow(this.icon, this.label, this.value, this.isDark);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: AppColors.primaryCyan, size: 18),
    const SizedBox(width: 10),
    Text(label, style: TextStyle(
      color: AppColors.textMuted(isDark), fontSize: 13)),
    const Spacer(),
    Text(value, style: TextStyle(
      color: AppColors.text(isDark), fontSize: 13, fontWeight: FontWeight.w600)),
  ]);
}
