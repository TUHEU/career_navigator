// presentation/screens/jobs/job_detail_page.dart
// Full job detail: description, requirements, skills, map, GPS, contact
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/models/job_model.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../data/datasources/local/token_store.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guest_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/guest_guard.dart';

class JobDetailPage extends StatefulWidget {
  final JobListing job;
  const JobDetailPage({super.key, required this.job});
  @override
  State<JobDetailPage> createState() => _JobDetailPageState();
}

class _JobDetailPageState extends State<JobDetailPage> {
  bool _applying  = false;
  bool _applied   = false;
  final _coverCtrl = TextEditingController();

  @override
  void dispose() { _coverCtrl.dispose(); super.dispose(); }

  // ── Open Google Maps / GPS navigation ────────────────────
  Future<void> _openMaps({bool navigate = false}) async {
    final lat = widget.job.latitude;
    final lng = widget.job.longitude;
    if (lat == null || lng == null) return;

    final label = Uri.encodeComponent(
        '${widget.job.company} - ${widget.job.location}');

    Uri uri;
    if (navigate) {
      // GPS turn-by-turn navigation
      uri = Uri.parse(
          'google.navigation:q=$lat,$lng&mode=d');
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        // Fallback to directions URL
        uri = Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      // Just show location on map
      uri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=$label');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Open static map image URL ─────────────────────────────
  String get _staticMapUrl {
    final lat = widget.job.latitude;
    final lng = widget.job.longitude;
    if (lat == null || lng == null) return '';
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$lat,$lng&zoom=14&size=400x200'
        '&markers=color:red%7C$lat,$lng'
        '&key=YOUR_GOOGLE_MAPS_KEY';
  }

  // ── Launch URL helpers ────────────────────────────────────
  Future<void> _launchEmail(String email) async {
    final uri = Uri(scheme: 'mailto', path: email,
        queryParameters: {'subject': 'Application for ${widget.job.title}'});
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchWebsite(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ── Apply for job ─────────────────────────────────────────
  Future<void> _apply() async {
    final guest = context.read<GuestProvider>();
    if (guest.isGuest) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please sign in to apply for jobs')));
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = context.read<ThemeProvider>().isDarkMode;
        return AlertDialog(
          backgroundColor: AppColors.surface(isDark),
          title: Text('Apply for ${widget.job.title}',
              style: TextStyle(color: AppColors.text(isDark))),
          content: TextField(
            controller: _coverCtrl,
            maxLines: 4,
            style: TextStyle(color: AppColors.text(isDark)),
            decoration: InputDecoration(
              hintText: 'Write a brief cover letter (optional)...',
              hintStyle: TextStyle(color: AppColors.textMuted(isDark)),
              filled: true, fillColor: AppColors.inputFill(isDark),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: TextStyle(color: AppColors.textMuted(isDark))),
            ),
            GestureDetector(
              onTap: () async {
                Navigator.pop(ctx);
                setState(() => _applying = true);
                final token = await TokenStore().getAccess();
                if (token == null) {
                  setState(() => _applying = false);
                  return;
                }
                final res = await ApiService().applyForJob(
                  token:       token,
                  jobId:       widget.job.id,
                  coverLetter: _coverCtrl.text.trim(),
                );
                if (!mounted) return;
                setState(() { _applying = false; _applied = res['success'] == true; });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(res['success'] == true
                      ? '✅ Application submitted!'
                      : res['message'] ?? 'Failed to apply'),
                  backgroundColor: res['success'] == true
                      ? Colors.green : Colors.red,
                ));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryCyan, Color(0xFF0097A7)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Submit',
                    style: TextStyle(color: Colors.black,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final lang   = context.watch<LanguageProvider>();
    final job    = widget.job;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: CustomScrollView(slivers: [

        // ── App bar with company name ─────────────────────
        SliverAppBar(
          expandedHeight: 160,
          pinned: true,
          backgroundColor: AppColors.surface(isDark),
          iconTheme: IconThemeData(color: AppColors.text(isDark)),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryCyan.withValues(alpha: 0.15),
                    AppColors.background(isDark),
                  ],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Row(children: [
                  // Company logo or initials
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.primaryCyan.withValues(alpha: 0.3)),
                    ),
                    child: job.companyLogo != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.network(job.companyLogo!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _companyInitial(job)))
                        : _companyInitial(job),
                  ),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(job.title, style: TextStyle(
                        color: AppColors.text(isDark),
                        fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(job.company, style: TextStyle(
                        color: AppColors.primaryCyan,
                        fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  )),
                ]),
              )),
            ),
          ),
        ),

        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── Chips row ───────────────────────────────────
            Wrap(spacing: 8, runSpacing: 8, children: [
              _Chip(job.employmentTypeDisplay, job.employmentTypeColor),
              _Chip(job.locationTypeDisplay, job.locationTypeColor),
              _Chip(job.experienceLevelDisplay, AppColors.primaryCyan),
            ]),
            const SizedBox(height: 16),

            // ── Location + salary ───────────────────────────
            _InfoRow(Icons.location_on_outlined,
                job.location, isDark),
            const SizedBox(height: 8),
            _InfoRow(Icons.attach_money_rounded,
                job.salaryText, isDark),
            const SizedBox(height: 8),
            _InfoRow(Icons.calendar_today_outlined,
                'Posted ${_timeAgo(job.createdAt)}', isDark),
            if (job.applicationsCount > 0) ...[
              const SizedBox(height: 8),
              _InfoRow(Icons.people_outline,
                  '${job.applicationsCount} applicants', isDark),
            ],
            const SizedBox(height: 24),

            // ── MAP SECTION ─────────────────────────────────
            if (job.hasLocation) ...[
              _SectionTitle('Location on Map', isDark),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: GestureDetector(
                  onTap: () => _openMaps(),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: AppColors.card(isDark),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border(isDark)),
                    ),
                    child: Stack(children: [
                      // Map placeholder (replace with flutter_map or google_maps if desired)
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A2332)
                              : const Color(0xFFE8F4FD),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.map_outlined,
                                color: AppColors.primaryCyan, size: 48),
                            const SizedBox(height: 8),
                            Text(
                              '${job.latitude!.toStringAsFixed(4)}, '
                              '${job.longitude!.toStringAsFixed(4)}',
                              style: TextStyle(
                                color: AppColors.textSecondary(isDark),
                                fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(job.location, style: TextStyle(
                              color: AppColors.text(isDark),
                              fontWeight: FontWeight.w600)),
                          ],
                        )),
                      ),
                      // Tap overlay hint
                      Positioned(
                        bottom: 12, right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryCyan,
                            borderRadius: BorderRadius.circular(20)),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.open_in_new,
                                  color: Colors.black, size: 14),
                              SizedBox(width: 4),
                              Text('Open Maps',
                                  style: TextStyle(color: Colors.black,
                                      fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // GPS Navigation button
              GestureDetector(
                onTap: () => _openMaps(navigate: true),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF047857)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(
                      color: const Color(0xFF059669).withValues(alpha: 0.4),
                      blurRadius: 16, offset: const Offset(0, 4))],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.navigation_rounded,
                          color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Navigate with GPS',
                          style: TextStyle(color: Colors.white,
                              fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Description ─────────────────────────────────
            _SectionTitle('Job Description', isDark),
            const SizedBox(height: 10),
            _ExpandableText(job.description, isDark),
            const SizedBox(height: 24),

            // ── Requirements ────────────────────────────────
            if (job.requirements.isNotEmpty) ...[
              _SectionTitle('Requirements', isDark),
              const SizedBox(height: 10),
              _BulletList(job.requirements, isDark),
              const SizedBox(height: 24),
            ],

            // ── Responsibilities ─────────────────────────────
            if (job.responsibilities.isNotEmpty) ...[
              _SectionTitle('Responsibilities', isDark),
              const SizedBox(height: 10),
              _BulletList(job.responsibilities, isDark),
              const SizedBox(height: 24),
            ],

            // ── Benefits ─────────────────────────────────────
            if (job.benefits != null && job.benefits!.isNotEmpty) ...[
              _SectionTitle('Benefits', isDark),
              const SizedBox(height: 10),
              _BulletList(job.benefits!, isDark),
              const SizedBox(height: 24),
            ],

            // ── Skills ───────────────────────────────────────
            if (job.skillsRequired != null &&
                job.skillsRequired!.isNotEmpty) ...[
              _SectionTitle('Required Skills', isDark),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8,
                children: job.skillsRequired!.map((s) =>
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryCyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primaryCyan.withValues(alpha: 0.3)),
                    ),
                    child: Text(s, style: const TextStyle(
                      color: AppColors.primaryCyan, fontSize: 13,
                      fontWeight: FontWeight.w500)),
                  ),
                ).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // ── Contact ──────────────────────────────────────
            if (job.hasContact || job.companyWebsite != null) ...[
              _SectionTitle('Contact & Company', isDark),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border(isDark)),
                ),
                child: Column(children: [
                  if (job.contactEmail != null)
                    _ContactRow(
                      icon: Icons.email_outlined,
                      label: job.contactEmail!,
                      onTap: () => _launchEmail(job.contactEmail!),
                      isDark: isDark,
                    ),
                  if (job.contactPhone != null) ...[
                    if (job.contactEmail != null)
                      Divider(color: AppColors.border(isDark), height: 16),
                    _ContactRow(
                      icon: Icons.phone_outlined,
                      label: job.contactPhone!,
                      onTap: () => _launchPhone(job.contactPhone!),
                      isDark: isDark,
                    ),
                  ],
                  if (job.companyWebsite != null) ...[
                    if (job.hasContact)
                      Divider(color: AppColors.border(isDark), height: 16),
                    _ContactRow(
                      icon: Icons.language_outlined,
                      label: job.companyWebsite!,
                      onTap: () => _launchWebsite(job.companyWebsite!),
                      isDark: isDark,
                    ),
                  ],
                ]),
              ),
              const SizedBox(height: 24),
            ],

            // ── Apply button ─────────────────────────────────
            const SizedBox(height: 8),
            GuestGuard(
              feature: GuestFeature.applyJob,
              child: _ApplyButton(
                applied:  _applied,
                applying: _applying,
                onTap:    _apply,
                lang:     lang,
              ),
            ),
            const SizedBox(height: 32),
          ]),
        )),
      ]),
    );
  }

  Widget _companyInitial(JobListing job) => Center(
    child: Text(
      job.company.isNotEmpty ? job.company[0].toUpperCase() : '?',
      style: const TextStyle(
          color: AppColors.primaryCyan,
          fontSize: 22, fontWeight: FontWeight.bold),
    ),
  );

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inDays >= 30) return '${(d.inDays / 30).floor()}mo ago';
    if (d.inDays >= 1)  return '${d.inDays}d ago';
    if (d.inHours >= 1) return '${d.inHours}h ago';
    return 'just now';
  }
}

// ── Sub-widgets ────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text; final bool isDark;
  const _SectionTitle(this.text, this.isDark);
  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(
    color: AppColors.text(isDark), fontSize: 17,
    fontWeight: FontWeight.bold));
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String text; final bool isDark;
  const _InfoRow(this.icon, this.text, this.isDark);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, color: AppColors.primaryCyan, size: 18),
    const SizedBox(width: 8),
    Expanded(child: Text(text, style: TextStyle(
      color: AppColors.textSecondary(isDark), fontSize: 14))),
  ]);
}

class _Chip extends StatelessWidget {
  final String text; final Color color;
  const _Chip(this.text, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.4))),
    child: Text(text, style: TextStyle(color: color,
        fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

class _BulletList extends StatelessWidget {
  final String text; final bool isDark;
  const _BulletList(this.text, this.isDark);
  @override
  Widget build(BuildContext context) {
    final lines = text.split('\n')
        .map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        final clean = line.startsWith('-') ? line.substring(1).trim() : line;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              margin: const EdgeInsets.only(top: 7),
              width: 5, height: 5,
              decoration: const BoxDecoration(
                color: AppColors.primaryCyan, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(clean, style: TextStyle(
              color: AppColors.text(isDark), fontSize: 14, height: 1.5))),
          ]),
        );
      }).toList(),
    );
  }
}

class _ExpandableText extends StatefulWidget {
  final String text; final bool isDark;
  const _ExpandableText(this.text, this.isDark);
  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}
class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        widget.text,
        maxLines: _expanded ? null : 4,
        overflow: _expanded ? null : TextOverflow.ellipsis,
        style: TextStyle(color: AppColors.text(widget.isDark),
            fontSize: 14, height: 1.6),
      ),
      if (widget.text.length > 200) ...[
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Text(_expanded ? 'Show less' : 'Read more',
              style: const TextStyle(color: AppColors.primaryCyan,
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ),
      ],
    ],
  );
}

class _ContactRow extends StatelessWidget {
  final IconData icon; final String label;
  final VoidCallback onTap; final bool isDark;
  const _ContactRow({required this.icon, required this.label,
      required this.onTap, required this.isDark});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryCyan.withValues(alpha: 0.1),
          shape: BoxShape.circle),
        child: Icon(icon, color: AppColors.primaryCyan, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(label, style: TextStyle(
        color: AppColors.primaryCyan, fontSize: 14,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.primaryCyan))),
      Icon(Icons.arrow_forward_ios_rounded,
          size: 14, color: AppColors.textMuted(isDark)),
    ]),
  );
}

class _ApplyButton extends StatefulWidget {
  final bool applied, applying;
  final VoidCallback onTap;
  final LanguageProvider lang;
  const _ApplyButton({required this.applied, required this.applying,
      required this.onTap, required this.lang});
  @override
  State<_ApplyButton> createState() => _ApplyButtonState();
}
class _ApplyButtonState extends State<_ApplyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 100));
    _s = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) { if (!widget.applied && !widget.applying) _c.forward(); },
    onTapUp:   (_) { _c.reverse(); if (!widget.applied) widget.onTap(); },
    onTapCancel: () => _c.reverse(),
    child: ScaleTransition(scale: _s,
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.applied
                ? [Colors.green, Colors.green.shade700]
                : [AppColors.primaryCyan, const Color(0xFF0097A7)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: (widget.applied
                ? Colors.green : AppColors.primaryCyan).withValues(alpha: 0.4),
            blurRadius: 20, offset: const Offset(0, 6))],
        ),
        child: Center(child: widget.applying
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.black))
            : Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(
                  widget.applied
                      ? Icons.check_circle_rounded
                      : Icons.send_rounded,
                  color: Colors.black, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.applied
                      ? widget.lang.t(S.applied)
                      : widget.lang.t(S.applyNow),
                  style: const TextStyle(color: Colors.black,
                      fontSize: 16, fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              ])),
      ),
    ),
  );
}
