// presentation/screens/dashboard/job_seeker_dashboard.dart
// v9 — Complete redesign: stats cards, quick actions, featured jobs preview,
//       XP progress, skill badges, activity feed. TalentBridge-inspired.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/datasources/local/profile_picture_store.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guest_provider.dart';
import '../../../providers/job_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../widgets/shared/bottom_nav.dart';
import '../../widgets/shared/buttons.dart';
import '../../widgets/shared/guest_guard.dart';
import '../profile/edit_profile_page.dart';
import '../auth/sign_in_page.dart';
import '../jobs/job_listings_page.dart';
import '../chat/chat_page.dart';
import '../search/search_page.dart';
import '../settings/settings_page.dart';
import '../ai/ai_chat_page.dart';
import '../notifications/notifications_page.dart';

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
    final lang   = context.watch<LanguageProvider>();
    final guest  = context.watch<GuestProvider>();

    final pages = [
      const _HomeTab(),
      const JobListingsPage(),
      guest.canAccess(GuestFeature.chat)
          ? const ConversationsPage()
          : const GuestLockedPage(feature: GuestFeature.chat),
      guest.canAccess(GuestFeature.aiTools)
          ? const AIChatPage()
          : const GuestLockedPage(feature: GuestFeature.aiTools),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: pages[_currentIndex],
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          NavItem(Icons.home_outlined,         Icons.home,           lang.t(S.home)),
          NavItem(Icons.work_outline,           Icons.work,           lang.t(S.jobs)),
          NavItem(Icons.chat_bubble_outline,    Icons.chat_bubble,    lang.t(S.chat)),
          NavItem(Icons.auto_awesome_outlined,  Icons.auto_awesome,   lang.t(S.aiHub)),
          NavItem(Icons.settings_outlined,      Icons.settings,       lang.t(S.settings)),
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = context.watch<ThemeProvider>().isDarkMode;
    final auth    = context.watch<AuthProvider>();
    final guest   = context.watch<GuestProvider>();
    final lang    = context.watch<LanguageProvider>();
    final jobs    = context.watch<JobProvider>().jobs;
    final user    = auth.currentUser;
    final name    = guest.isGuest ? lang.t(S.guestMode) : (user?.displayName ?? 'User');

    return RefreshIndicator(
      color: AppColors.primaryCyan,
      onRefresh: () async {
        await auth.loadUserProfile();
        await context.read<JobProvider>().loadJobs();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [

          // ── Top AppBar ─────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: AppColors.background(isDark),
            elevation: 0,
            title: Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryCyan.withOpacity(0.12),
                  border: Border.all(color: AppColors.primaryCyan.withOpacity(0.35)),
                ),
                child: ClipOval(child: Image.asset(
                  'assets/logo/logo.png', fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.compass_calibration_outlined,
                    color: AppColors.primaryCyan, size: 16),
                )),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CAREER NAVIGATOR', style: TextStyle(
                  color: AppColors.primaryCyan, fontSize: 10,
                  letterSpacing: 1.5, fontWeight: FontWeight.w800)),
                Text(lang.t(S.jobSeeker), style: TextStyle(
                  color: AppColors.textMuted(isDark), fontSize: 10)),
              ]),
            ]),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_outlined,
                  color: AppColors.text(isDark)),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NotificationsPage())),
              ),
              IconButton(
                icon: Icon(Icons.search, color: AppColors.text(isDark)),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SearchPage())),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(delegate: SliverChildListDelegate([

              // ── Guest banner ────────────────────────────────
              if (guest.isGuest) ...[
                _GuestBanner(lang: lang, isDark: isDark),
                const SizedBox(height: 16),
              ],

              // ── Welcome card ────────────────────────────────
              _WelcomeCard(
                name: name, isDark: isDark, lang: lang,
                user: user, isGuest: guest.isGuest,
              ),
              const SizedBox(height: 20),

              // ── Stats row ───────────────────────────────────
              if (!guest.isGuest) ...[
                _StatsRow(isDark: isDark, lang: lang),
                const SizedBox(height: 20),
              ],

              // ── Quick actions ───────────────────────────────
              _QuickActions(isDark: isDark, lang: lang, isGuest: guest.isGuest),
              const SizedBox(height: 24),

              // ── AI tools banner (from TalentBridge) ─────────
              _AIToolsBanner(isDark: isDark, lang: lang, isGuest: guest.isGuest),
              const SizedBox(height: 24),

              // ── Featured jobs ───────────────────────────────
              _SectionHeader(
                title: 'Featured Jobs',
                onSeeAll: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const JobListingsPage())),
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              if (jobs.isEmpty)
                _EmptyJobs(isDark: isDark)
              else
                ...jobs.take(3).map((j) => _FeaturedJobCard(
                  title:    j.title,
                  company:  j.company,
                  location: j.location,
                  isDark:   isDark,
                  onApply: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const JobListingsPage())),
                )).toList(),
              const SizedBox(height: 24),

              // ── Skill spotlight ──────────────────────────────
              _SkillSpotlight(isDark: isDark, lang: lang),
              const SizedBox(height: 30),
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
  final LanguageProvider lang;
  final dynamic user;
  const _WelcomeCard({required this.name, required this.isDark,
    required this.lang, required this.user, required this.isGuest});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primaryCyan.withOpacity(isDark ? 0.15 : 0.08),
          AppColors.primaryCyan.withOpacity(isDark ? 0.05 : 0.02),
        ],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.primaryCyan.withOpacity(0.25)),
    ),
    child: Row(children: [
      Stack(children: [
        ProfilePictureStore.avatar(
          remoteUrl: user?.profilePictureUrl,
          name: isGuest ? 'G' : (user?.displayName ?? 'U'),
          radius: 36, bgColor: AppColors.primaryCyan,
        ),
        if (!isGuest)
          Positioned(bottom: 0, right: 0, child: Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E), shape: BoxShape.circle,
              border: Border.all(color: AppColors.background(isDark), width: 2)),
          )),
      ]),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(lang.t(S.welcomeBack) + '! 👋', style: TextStyle(
          color: AppColors.textMuted(isDark), fontSize: 12)),
        const SizedBox(height: 2),
        Text(name, style: TextStyle(
          color: AppColors.text(isDark), fontSize: 18,
          fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        const SizedBox(height: 8),
        if (!isGuest)
          GestureDetector(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const EditProfilePage())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryCyan.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.edit_outlined,
                    color: AppColors.primaryCyan, size: 11),
                const SizedBox(width: 4),
                Text(lang.t(S.editProfile), style: const TextStyle(
                  color: AppColors.primaryCyan,
                  fontSize: 11, fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
      ])),
    ]),
  );
}

// ── Stats Row ─────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final bool isDark; final LanguageProvider lang;
  const _StatsRow({required this.isDark, required this.lang});

  @override
  Widget build(BuildContext context) => Row(children: [
    _StatCard(value: '0', label: 'Applications', icon: Icons.send_outlined, isDark: isDark),
    const SizedBox(width: 10),
    _StatCard(value: '0', label: 'Saved Jobs',   icon: Icons.bookmark_outline, isDark: isDark),
    const SizedBox(width: 10),
    _StatCard(value: '0', label: 'Connections',  icon: Icons.people_outline, isDark: isDark),
  ]);
}

class _StatCard extends StatelessWidget {
  final String value, label; final IconData icon; final bool isDark;
  const _StatCard({required this.value, required this.label,
    required this.icon, required this.isDark});

  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
    decoration: BoxDecoration(
      color: AppColors.card(isDark),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border(isDark))),
    child: Column(children: [
      Icon(icon, color: AppColors.primaryCyan, size: 18),
      const SizedBox(height: 6),
      Text(value, style: TextStyle(
        color: AppColors.text(isDark), fontSize: 18,
        fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 9),
        textAlign: TextAlign.center, maxLines: 1,
        overflow: TextOverflow.ellipsis),
    ]),
  ));
}

// ── Quick Actions ─────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  final bool isDark, isGuest; final LanguageProvider lang;
  const _QuickActions({required this.isDark, required this.lang, required this.isGuest});

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.work_outline, 'Find Jobs', AppColors.primaryCyan,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JobListingsPage()))),
      (Icons.people_outline, 'Mentors', const Color(0xFF7C3AED),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()))),
      (Icons.psychology_outlined, 'AI Coach', const Color(0xFF059669),
        isGuest ? () => _guestSnack(context) :
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatPage()))),
      (Icons.chat_bubble_outline, 'Messages', const Color(0xFFF59E0B),
        isGuest ? () => _guestSnack(context) :
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConversationsPage()))),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Quick Actions', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 16,
        fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(children: actions.map((a) => Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: GestureDetector(
          onTap: a.$4,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: (a.$3).withOpacity(isDark ? 0.08 : 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: (a.$3).withOpacity(0.2))),
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

  void _guestSnack(BuildContext context) =>
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Sign in to access this feature'),
      backgroundColor: AppColors.primaryCyan,
      behavior: SnackBarBehavior.floating,
    ));
}

// ── AI Tools Banner ────────────────────────────────────────────────
class _AIToolsBanner extends StatelessWidget {
  final bool isDark, isGuest; final LanguageProvider lang;
  const _AIToolsBanner({required this.isDark, required this.lang, required this.isGuest});

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
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0D1F2D), const Color(0xFF0A1628)]
              : [const Color(0xFFE0F7FA), const Color(0xFFE8F5E9)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryCyan.withOpacity(0.15), shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3))),
          child: const Icon(Icons.auto_awesome, color: AppColors.primaryCyan, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(lang.t(S.aiCareerTools), style: TextStyle(
            color: AppColors.text(isDark), fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 4),
          Text(
            isGuest ? lang.t(S.signInToAccess) : lang.t(S.aiCareerSub),
            style: TextStyle(color: AppColors.primaryCyan.withOpacity(0.8), fontSize: 12)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryCyan.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(isGuest ? Icons.lock_outline : Icons.arrow_forward_ios,
                color: AppColors.primaryCyan, size: 12),
            if (!isGuest) ...[
              const SizedBox(width: 4),
              const Text('Try', style: TextStyle(
                color: AppColors.primaryCyan, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ]),
        ),
      ]),
    ),
  );
}

// ── Section Header ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title; final VoidCallback onSeeAll; final bool isDark;
  const _SectionHeader({required this.title, required this.onSeeAll, required this.isDark});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: TextStyle(
        color: AppColors.text(isDark), fontSize: 16, fontWeight: FontWeight.bold)),
      GestureDetector(
        onTap: onSeeAll,
        child: const Text('See all', style: TextStyle(
          color: AppColors.primaryCyan, fontSize: 13, fontWeight: FontWeight.w600))),
    ],
  );
}

// ── Featured Job Card ─────────────────────────────────────────────
class _FeaturedJobCard extends StatelessWidget {
  final String title, company, location;
  final bool isDark;
  final VoidCallback onApply;
  const _FeaturedJobCard({
    required this.title, required this.company,
    required this.location, required this.isDark, required this.onApply,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.card(isDark),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.border(isDark)),
    ),
    child: Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: AppColors.primaryCyan.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.business_center,
            color: AppColors.primaryCyan, size: 22),
      ),
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
          Icon(Icons.location_on_outlined,
              color: AppColors.textMuted(isDark), size: 11),
          const SizedBox(width: 2),
          Text(location, style: TextStyle(
            color: AppColors.textMuted(isDark), fontSize: 11)),
        ]),
      ])),
      GestureDetector(
        onTap: onApply,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryCyan.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3))),
          child: const Text('Apply', style: TextStyle(
            color: AppColors.primaryCyan, fontSize: 11,
            fontWeight: FontWeight.bold)),
        ),
      ),
    ]),
  );
}

// ── Empty Jobs ────────────────────────────────────────────────────
class _EmptyJobs extends StatelessWidget {
  final bool isDark;
  const _EmptyJobs({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.card(isDark),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.border(isDark))),
    child: Column(children: [
      Icon(Icons.work_off_outlined, size: 40, color: AppColors.textMuted(isDark)),
      const SizedBox(height: 8),
      Text('No jobs loaded yet', style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 13)),
    ]),
  );
}

// ── Skill Spotlight ───────────────────────────────────────────────
class _SkillSpotlight extends StatelessWidget {
  final bool isDark; final LanguageProvider lang;
  const _SkillSpotlight({required this.isDark, required this.lang});

  static const _skills = [
    ('Flutter', 0.85, Color(0xFF54C5F8)),
    ('Python',  0.70, Color(0xFF3776AB)),
    ('SQL',     0.60, Color(0xFFF29111)),
    ('React',   0.50, Color(0xFF61DAFB)),
  ];

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Top In-Demand Skills', style: TextStyle(
        color: AppColors.text(isDark), fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text('Trending in the African job market', style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 12)),
      const SizedBox(height: 14),
      ..._skills.map((s) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(s.$1, style: TextStyle(
              color: AppColors.text(isDark), fontSize: 13, fontWeight: FontWeight.w600)),
            Text('${(s.$2 * 100).toInt()}% demand', style: TextStyle(
              color: s.$3, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: s.$2, minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.07) : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(s.$3),
            ),
          ),
        ]),
      )),
    ],
  );
}

// ── Guest Banner ──────────────────────────────────────────────────
class _GuestBanner extends StatelessWidget {
  final LanguageProvider lang; final bool isDark;
  const _GuestBanner({required this.lang, required this.isDark});

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
      Expanded(child: Text(lang.t(S.guestWarning),
          style: const TextStyle(color: AppColors.warning, fontSize: 12))),
      GestureDetector(
        onTap: () {
          context.read<GuestProvider>().exitGuestMode();
          Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const SignInPage()),
            (_) => false);
        },
        child: const Text('Sign In', style: TextStyle(
          color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    ]),
  );
}

