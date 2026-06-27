// presentation/screens/settings/about_us_page.dart
// v9 — Beautiful About Us with creator spotlight, tech stack, app stats
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../providers/theme_provider.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: Text('About Us', style: TextStyle(color: AppColors.text(isDark))),
        backgroundColor: AppColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(isDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // App Hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF0D1F2D), const Color(0xFF0A1628)]
                    : [const Color(0xFFE0F7FA), const Color(0xFFE8F5E9)],
                begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primaryCyan.withOpacity(0.3))),
            child: Column(children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryCyan.withOpacity(0.12),
                  border: Border.all(color: AppColors.primaryCyan.withOpacity(0.4), width: 2),
                  boxShadow: [BoxShadow(
                    color: AppColors.primaryCyan.withOpacity(0.25),
                    blurRadius: 30, spreadRadius: 5)]),
                child: ClipOval(child: Image.asset(
                  'assets/logo/logo.png', fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.compass_calibration_outlined,
                    color: AppColors.primaryCyan, size: 38))),
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(
                  colors: [AppColors.primaryCyan, Color(0xFF0097A7)],
                ).createShader(b),
                blendMode: BlendMode.srcIn,
                child: const Text('Career Navigator', style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800,
                  color: Colors.white, letterSpacing: 1)),
              ),
              const SizedBox(height: 8),
              Text('Your Future Starts Here', style: TextStyle(
                color: AppColors.textMuted(isDark), fontSize: 14,
                letterSpacing: 1)),
              const SizedBox(height: 16),
              Text(
                'Career Navigator is an AI-powered career development platform '
                'built for African professionals. We connect talented job seekers '
                'with mentors, opportunities, and intelligent tools to navigate '
                'their career journey.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary(isDark), fontSize: 13, height: 1.7)),
            ]),
          ),
          const SizedBox(height: 24),

          // Stats
          Row(children: [
            _StatBubble('v7.0', 'Version', isDark),
            const SizedBox(width: 10),
            _StatBubble('19', 'DB Tables', isDark),
            const SizedBox(width: 10),
            _StatBubble('7+', 'AI Tools', isDark),
            const SizedBox(width: 10),
            _StatBubble('2', 'Langs', isDark),
          ]),
          const SizedBox(height: 28),

          // Creator card
          _SectionTitle('The Creator', isDark),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card(isDark),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border(isDark))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryCyan.withOpacity(0.12),
                    border: Border.all(color: AppColors.primaryCyan.withOpacity(0.4), width: 2)),
                  child: const Center(child: Text('TF', style: TextStyle(
                    color: AppColors.primaryCyan, fontSize: 20, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Tuheu Tchoubi Pempeme\nMoussa Fahdil', style: TextStyle(
                    color: AppColors.text(isDark), fontWeight: FontWeight.bold,
                    fontSize: 15, height: 1.3)),
                  const SizedBox(height: 4),
                  const Text('Full-Stack Engineer', style: TextStyle(
                    color: AppColors.primaryCyan, fontSize: 12)),
                ])),
              ]),
              const SizedBox(height: 16),
              Text(
                'Designed and built the entire Career Navigator platform — '
                'from the Flask REST API backend to the Flutter mobile frontend. '
                'Architected 19 database tables, integrated Gemini AI, deployed on '
                'a Contabo VPS with PM2, and implemented real-time chat, '
                'OTP email verification, and cloud media storage via Cloudinary.',
                style: TextStyle(
                  color: AppColors.textSecondary(isDark), fontSize: 13, height: 1.7)),
              const SizedBox(height: 16),
              Wrap(spacing: 6, runSpacing: 6, children: [
                'Flutter', 'Python', 'Flask', 'MySQL',
                'Gemini AI', 'Cloudinary', 'JWT', 'Socket.IO',
              ].map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryCyan.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryCyan.withOpacity(0.25))),
                child: Text(s, style: const TextStyle(
                  color: AppColors.primaryCyan, fontSize: 11, fontWeight: FontWeight.w600)),
              )).toList()),
            ]),
          ),
          const SizedBox(height: 28),

          // Tech Stack
          _SectionTitle('Tech Stack', isDark),
          const SizedBox(height: 12),
          ...[
            (Icons.phone_android,     'Flutter',        'Cross-platform mobile app',        const Color(0xFF54C5F8)),
            (Icons.code,              'Python / Flask', 'REST API backend with Blueprints', const Color(0xFF3776AB)),
            (Icons.storage,           'MySQL',          '19-table relational database',     const Color(0xFFF29111)),
            (Icons.psychology,        'Gemini AI',      'Intelligent career coaching',      AppColors.primaryCyan),
            (Icons.cloud,             'Cloudinary',     'Media storage & transformation',   const Color(0xFF3448C5)),
            (Icons.email_outlined,    'Brevo',          'Transactional email & OTP',        const Color(0xFF0092FF)),
            (Icons.wifi,              'Socket.IO',      'Real-time messaging',              const Color(0xFF010101)),
            (Icons.lock_outline,      'JWT + Bcrypt',   'Secure auth with refresh tokens',  const Color(0xFF059669)),
          ].map((t) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card(isDark), borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border(isDark))),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: t.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(t.$1, color: t.$4, size: 20)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t.$2, style: TextStyle(
                  color: AppColors.text(isDark), fontWeight: FontWeight.bold, fontSize: 13)),
                Text(t.$3, style: TextStyle(
                  color: AppColors.textMuted(isDark), fontSize: 11)),
              ])),
            ]),
          )),
          const SizedBox(height: 24),
          Center(child: Text(
            '© 2025 Career Navigator\nMade with ❤️ in Cameroon',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted(isDark), fontSize: 12, height: 1.7))),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text; final bool isDark;
  const _SectionTitle(this.text, this.isDark);
  @override
  Widget build(BuildContext context) => Text(text, style: TextStyle(
    color: AppColors.text(isDark), fontSize: 18, fontWeight: FontWeight.bold));
}

class _StatBubble extends StatelessWidget {
  final String value, label; final bool isDark;
  const _StatBubble(this.value, this.label, this.isDark);
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
      color: AppColors.primaryCyan.withOpacity(0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.primaryCyan.withOpacity(0.2))),
    child: Column(children: [
      Text(value, style: const TextStyle(
        color: AppColors.primaryCyan, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 10), textAlign: TextAlign.center),
    ]),
  ));
}
