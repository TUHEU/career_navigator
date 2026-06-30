// presentation/screens/dashboard/job_seeker_dashboard.dart — v10
// Full redesign: XP bar, stats, community tab, saved jobs, improved UI
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/datasources/local/profile_picture_store.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guest_provider.dart';
import '../../../providers/job_provider.dart';
import '../../../providers/posts_provider.dart';
import '../../../providers/saved_jobs_provider.dart';
import '../../../providers/stats_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/bottom_nav.dart';
import '../../widgets/shared/guest_guard.dart';
import '../auth/sign_in_page.dart';
import '../community/community_feed_page.dart';
import '../jobs/job_detail_page.dart';
import '../jobs/job_listings_page.dart';
import '../jobs/saved_jobs_page.dart';
import '../chat/chat_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';
import '../ai/ai_chat_page.dart';
import '../notifications/notifications_page.dart';
import '../stats/career_stats_page.dart';
import '../profile/edit_profile_page.dart';

class JobSeekerDashboard extends StatefulWidget {
  const JobSeekerDashboard({super.key});
  @override
  State<JobSeekerDashboard> createState() => _JobSeekerDashboardState();
}

class _JobSeekerDashboardState extends State<JobSeekerDashboard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final guest  = context.watch<GuestProvider>();
    final lang   = context.watch<LanguageProvider>();

    final pages = [
      const _HomeTab(),
      const JobListingsPage(),
      guest.isGuest
          ? const GuestLockedPage(feature: GuestFeature.chat)
          : const CommunityFeedPage(),
      guest.isGuest
          ? const GuestLockedPage(feature: GuestFeature.aiTools)
          : const AIChatPage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          NavItem(Icons.home_outlined,        Icons.home,           lang.t(S.home)),
          NavItem(Icons.work_outline,          Icons.work,           lang.t(S.jobs)),
          NavItem(Icons.people_outline,        Icons.people,         'Community'),
          NavItem(Icons.auto_awesome_outlined, Icons.auto_awesome,   lang.t(S.aiHub)),
          NavItem(Icons.settings_outlined,     Icons.settings,       lang.t(S.settings)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  HOME TAB
// ═══════════════════════════════════════════════════════════════
class _HomeTab extends StatefulWidget {
  const _HomeTab();
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobProvider>().loadJobs();
      context.read<StatsProvider>().load();
      context.read<SavedJobsProvider>().loadSaved();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = context.watch<ThemeProvider>().isDarkMode;
    final auth    = context.watch<AuthProvider>();
    final guest   = context.watch<GuestProvider>();
    final lang    = context.watch<LanguageProvider>();
    final jobs    = context.watch<JobProvider>().jobs;
    final stats   = context.watch<StatsProvider>().stats;
    final user    = auth.currentUser;
    final name    = guest.isGuest ? 'Guest' : (user?.fullName ?? 'User');

    return RefreshIndicator(
      color: AppColors.primaryCyan,
      onRefresh: () async {
        await auth.loadUserProfile();
        await context.read<JobProvider>().loadJobs();
        await context.read<StatsProvider>().load();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── AppBar ───────────────────────────────────────────
          SliverAppBar(
            floating: true, snap: true,
            backgroundColor: AppColors.background(isDark), elevation: 0,
            title: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryCyan.withOpacity(0.12),
                  border: Border.all(color: AppColors.primaryCyan.withOpacity(0.35))),
                child: ClipOval(child: Image.asset('assets/logo/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.compass_calibration_outlined,
                    color: AppColors.primaryCyan, size: 18)))),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('CAREER NAVIGATOR', style: TextStyle(
                  color: AppColors.primaryCyan, fontSize: 10,
                  letterSpacing: 1.5, fontWeight: FontWeight.w800)),
                Text(lang.t(S.jobSeeker), style: TextStyle(
                  color: AppColors.textMuted(isDark), fontSize: 10)),
              ]),
            ]),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: AppColors.text(isDark)),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NotificationsPage()))),
              IconButton(
                icon: Icon(Icons.search, color: AppColors.text(isDark)),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SearchPage()))),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // ── Guest banner ─────────────────────────────────
              if (guest.isGuest) ...[
                _GuestBanner(isDark: isDark),
                const SizedBox(height: 16),
              ],

              // ── Welcome card with XP ─────────────────────────
              _WelcomeCard(name: name, isDark: isDark,
                user: user, isGuest: guest.isGuest, stats: stats),
              const SizedBox(height: 20),

              // ── XP Level progress ────────────────────────────
              if (!guest.isGuest && stats != null) ...[
                _XPProgressCard(stats: stats, isDark: isDark),
                const SizedBox(height: 20),
              ],

              // ── Stats row ────────────────────────────────────
              if (!guest.isGuest && stats != null) ...[
                _StatsRow(stats: stats, isDark: isDark),
                const SizedBox(height: 20),
              ],

              // ── Quick actions ────────────────────────────────
              _QuickActions(isDark: isDark, isGuest: guest.isGuest),
              const SizedBox(height: 24),

              // ── AI Tools banner ──────────────────────────────
              _AIToolsBanner(isDark: isDark, isGuest: guest.isGuest),
              const SizedBox(height: 24),

              // ── Featured jobs ────────────────────────────────
              _SectionHeader(
                title: 'Featured Jobs',
                action: 'See all',
                onAction: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const JobListingsPage())),
                isDark: isDark),
              const SizedBox(height: 12),
              if (jobs.isEmpty)
                _EmptyJobs(isDark: isDark)
              else
                ...jobs.take(3).map((j) => _FeaturedJobCard(
                  title: j.title, company: j.company,
                  location: j.location, locationType: j.locationType,
                  isDark: isDark,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => JobDetailPage(job: j))))),
              const SizedBox(height: 24),

              // ── Skill spotlight ──────────────────────────────
              _SkillSpotlight(isDark: isDark),
              const SizedBox(height: 32),
            ])),
          ),
        ],
      ),
    );
  }
}

// ── Welcome Card ─────────────────────────────────────────────────
class _WelcomeCard extends StatelessWidget {
  final String name; final bool isDark, isGuest;
  final dynamic user; final CareerStats? stats;
  const _WelcomeCard({required this.name, required this.isDark,
    required this.user, required this.isGuest, required this.stats});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: isGuest ? null : () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => const EditProfilePage())),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryCyan.withOpacity(isDark ? 0.12 : 0.07),
            AppColors.primaryCyan.withOpacity(isDark ? 0.04 : 0.02),
          ],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.2))),
      child: Row(children: [
        Stack(children: [
          ProfilePictureStore.avatar(
            remoteUrl: user?.profilePictureUrl,
            name: isGuest ? 'G' : (user?.fullName ?? 'U'),
            radius: 34, bgColor: AppColors.primaryCyan),
          if (!isGuest)
            Positioned(bottom: 0, right: 0, child: Container(
              width: 14, height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E), shape: BoxShape.circle,
                border: Border.all(color: AppColors.background(isDark), width: 2)))),
        ]),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Good ${_greeting()}! 👋', style: TextStyle(
            color: AppColors.textMuted(isDark), fontSize: 12)),
          const SizedBox(height: 2),
          Text(name, style: TextStyle(
            color: AppColors.text(isDark), fontSize: 17,
            fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis),
          if (!isGuest && stats != null) ...[
            const SizedBox(height: 6),
            Row(children: [
              const Text('⚡', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text('${stats!.totalXp} XP · Level ${stats!.level}',
                style: const TextStyle(
                  color: AppColors.primaryCyan, fontSize: 11,
                  fontWeight: FontWeight.w600)),
            ]),
          ],
        ])),
        if (!isGuest)
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.primaryCyan, size: 20),
      ]),
    ),
  );

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }
}

// ── XP Progress Card ──────────────────────────────────────────────
class _XPProgressCard extends StatelessWidget {
  final CareerStats stats; final bool isDark;
  const _XPProgressCard({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => const CareerStatsPage())),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(isDark),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(isDark))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('🏆', style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Level ${stats.level} · ${stats.levelTitle}',
              style: TextStyle(color: AppColors.text(isDark),
                fontWeight: FontWeight.bold, fontSize: 13)),
            Text('${stats.xpInLevel} / ${stats.xpForNextLevel} XP to next level',
              style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 11)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primaryCyan.withOpacity(0.2))),
            child: Text('${stats.totalXp} XP', style: const TextStyle(
              color: AppColors.primaryCyan, fontSize: 11, fontWeight: FontWeight.bold))),
        ]),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: stats.levelProgress, minHeight: 7,
            backgroundColor: isDark
                ? Colors.white.withOpacity(0.07) : Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryCyan))),
      ]),
    ),
  );
}

// ── Stats Row ─────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final CareerStats stats; final bool isDark;
  const _StatsRow({required this.stats, required this.isDark});

  @override
  Widget build(BuildContext context) => Row(children: [
    _StatCard('${stats.applicationsSent}', 'Applied',
      Icons.send_outlined, isDark,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const CareerStatsPage()))),
    const SizedBox(width: 10),
    _StatCard('${stats.savedJobs}', 'Saved',
      Icons.bookmark_outline, isDark,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const SavedJobsPage()))),
    const SizedBox(width: 10),
    _StatCard('${stats.totalConnections}', 'Network',
      Icons.people_outline, isDark,
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const SearchPage()))),
  ]);
}

class _StatCard extends StatelessWidget {
  final String value, label; final IconData icon;
  final bool isDark; final VoidCallback? onTap;
  const _StatCard(this.value, this.label, this.icon, this.isDark, {this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.card(isDark), borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(isDark))),
      child: Column(children: [
        Icon(icon, color: AppColors.primaryCyan, size: 18),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(
          color: AppColors.text(isDark), fontSize: 18,
          fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(
          color: AppColors.textMuted(isDark), fontSize: 9)),
      ]),
    ),
  ));
}

// ── Quick Actions ─────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final bool isDark, isGuest;
  const _QuickActions({required this.isDark, required this.isGuest});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.work_outline, 'Find Jobs', const Color(0xFF00B8D4),
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const JobListingsPage()))),
      (Icons.bookmark_outline, 'Saved', const Color(0xFF7C3AED),
        isGuest ? () => _snack(context) :
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SavedJobsPage()))),
      (Icons.people_outline, 'Network', const Color(0xFF059669),
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SearchPage()))),
      (Icons.bar_chart_rounded, 'My Stats', const Color(0xFFF59E0B),
        isGuest ? () => _snack(context) :
        () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CareerStatsPage()))),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quick Actions', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(children: actions.map((a) => Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: a.$4,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: a.$3.withOpacity(isDark ? 0.08 : 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: a.$3.withOpacity(0.2))),
            child: Column(children: [
              Icon(a.$1, color: a.$3, size: 22),
              const SizedBox(height: 6),
              Text(a.$2, style: TextStyle(
                color: AppColors.text(isDark), fontSize: 10,
                fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
            ]),
          ),
        ),
      ))).toList()),
    ]);
  }

  void _snack(BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Sign in to access this feature'),
      backgroundColor: AppColors.primaryCyan,
      behavior: SnackBarBehavior.floating));
}

// ── AI Banner ─────────────────────────────────────────────────────
class _AIToolsBanner extends StatelessWidget {
  final bool isDark, isGuest;
  const _AIToolsBanner({required this.isDark, required this.isGuest});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: isGuest
        ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Sign in to use AI Career Tools'),
            backgroundColor: AppColors.primaryCyan,
            behavior: SnackBarBehavior.floating))
        : () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AIChatPage())),
    child: Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0D1F2D), const Color(0xFF0A1628)]
              : [const Color(0xFFE0F7FA), const Color(0xFFE8F5E9)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3))),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryCyan.withOpacity(0.15),
            shape: BoxShape.circle),
          child: const Icon(Icons.auto_awesome,
              color: AppColors.primaryCyan, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Career Tools', style: TextStyle(
            color: AppColors.text(isDark),
            fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 3),
          Text(isGuest ? 'Sign in to unlock AI coaching' :
            'Career Path · Salary · Interview · Switch',
            style: TextStyle(
              color: AppColors.primaryCyan.withOpacity(0.8), fontSize: 11)),
        ])),
        Icon(isGuest ? Icons.lock_outline : Icons.arrow_forward_ios_rounded,
            color: AppColors.primaryCyan, size: 16),
      ]),
    ),
  );
}

// ── Section Header ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title, action; final VoidCallback onAction; final bool isDark;
  const _SectionHeader({required this.title, required this.action,
    required this.onAction, required this.isDark});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: TextStyle(
        color: AppColors.text(isDark), fontSize: 16, fontWeight: FontWeight.bold)),
      GestureDetector(onTap: onAction,
        child: Text(action, style: const TextStyle(
          color: AppColors.primaryCyan, fontSize: 13, fontWeight: FontWeight.w600))),
    ]);
}

// ── Featured Job Card ─────────────────────────────────────────────
class _FeaturedJobCard extends StatelessWidget {
  final String title, company, location, locationType;
  final bool isDark; final VoidCallback onTap;
  const _FeaturedJobCard({
    required this.title, required this.company,
    required this.location, required this.locationType,
    required this.isDark, required this.onTap,
  });

  Color _locColor() {
    switch (locationType) {
      case 'remote': return const Color(0xFF059669);
      case 'hybrid': return const Color(0xFFF59E0B);
      default:       return AppColors.primaryCyan;
    }
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card(isDark), borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border(isDark))),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryCyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.business_center,
              color: AppColors.primaryCyan, size: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(
            color: AppColors.text(isDark), fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(company, style: const TextStyle(
            color: AppColors.primaryCyan, fontSize: 12)),
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.location_on_outlined, size: 11,
                color: AppColors.textMuted(isDark)),
            const SizedBox(width: 2),
            Expanded(child: Text(location, style: TextStyle(
              color: AppColors.textMuted(isDark), fontSize: 11),
              overflow: TextOverflow.ellipsis)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: _locColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _locColor().withOpacity(0.3))),
              child: Text(locationType[0].toUpperCase() + locationType.substring(1),
                style: TextStyle(color: _locColor(), fontSize: 9,
                  fontWeight: FontWeight.bold))),
          ]),
        ])),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right_rounded,
            color: AppColors.primaryCyan, size: 20),
      ]),
    ),
  );
}

class _EmptyJobs extends StatelessWidget {
  final bool isDark;
  const _EmptyJobs({required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.card(isDark), borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border(isDark))),
    child: Column(children: [
      Icon(Icons.work_off_outlined, size: 40, color: AppColors.textMuted(isDark)),
      const SizedBox(height: 8),
      Text('No jobs loaded yet', style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 13)),
    ]));
}

// ── Skill Spotlight ───────────────────────────────────────────────
class _SkillSpotlight extends StatelessWidget {
  final bool isDark;
  const _SkillSpotlight({required this.isDark});

  static const _skills = [
    ('Flutter',  0.85, Color(0xFF54C5F8)),
    ('Python',   0.72, Color(0xFF3776AB)),
    ('SQL',      0.68, Color(0xFFF29111)),
    ('React',    0.60, Color(0xFF61DAFB)),
    ('Node.js',  0.55, Color(0xFF68A063)),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _SectionHeader(
        title: 'In-Demand Skills', action: 'Take Assessment',
        onAction: () {}, isDark: isDark),
      const SizedBox(height: 14),
      ..._skills.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(s.$1, style: TextStyle(
              color: AppColors.text(isDark), fontSize: 13,
              fontWeight: FontWeight.w600)),
            Text('${(s.$2 * 100).toInt()}% demand',
              style: TextStyle(color: s.$3, fontSize: 11,
                fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: s.$2, minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.07) : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(s.$3))),
        ]),
      )),
    ],
  );
}

// ── Guest Banner ──────────────────────────────────────────────────
class _GuestBanner extends StatelessWidget {
  final bool isDark;
  const _GuestBanner({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.warning.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.warning.withOpacity(0.3))),
    child: Row(children: [
      const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 18),
      const SizedBox(width: 10),
      const Expanded(child: Text('You are in guest mode. Some features are limited.',
        style: TextStyle(color: AppColors.warning, fontSize: 12))),
      GestureDetector(
        onTap: () {
          context.read<GuestProvider>().exitGuestMode();
          Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const SignInPage()),
            (_) => false);
        },
        child: const Text('Sign In', style: TextStyle(
          color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold))),
    ]),
  );
}
