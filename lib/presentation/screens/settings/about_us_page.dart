// presentation/screens/settings/about_us_page.dart
// v9 — Solo Fahdil spotlight with proper GitHub avatar loading
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../core/utils/helpers.dart';
import '../../../providers/theme_provider.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final fullUrl = url.startsWith('http') ? url : 'https://$url';
    final uri = Uri.tryParse(fullUrl);
    if (uri == null) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open: $fullUrl')));
    }
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    final uri = Uri.parse('mailto:$email?subject=Career%20Navigator%20Inquiry');
    final launched = await launchUrl(uri);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open email app for: $email')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      appBar: AppBar(
        title: Text('About Us',
            style: TextStyle(color: AppColors.text(isDark),
                fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background(isDark),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(isDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            // ── App hero card ──────────────────────────────────
            _AppHeroCard(isDark: isDark),
            const SizedBox(height: 28),

            // ── Stats row ──────────────────────────────────────
            Row(children: [
              _StatBubble('v9.0',  'Version',   isDark),
              const SizedBox(width: 10),
              _StatBubble('28',    'DB Tables', isDark),
              const SizedBox(width: 10),
              _StatBubble('7+',    'AI Tools',  isDark),
              const SizedBox(width: 10),
              _StatBubble('2',     'Languages', isDark),
            ]),
            const SizedBox(height: 28),

            // ── The Creator section ────────────────────────────
            Align(
              alignment: Alignment.centerLeft,
              child: Text('The Creator',
                  style: TextStyle(
                    color: AppColors.text(isDark),
                    fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'The mind and hands behind Career Navigator — '
                'from architecture to deployment.',
                style: TextStyle(
                    color: AppColors.textMuted(isDark), fontSize: 13)),
            ),
            const SizedBox(height: 16),

            // ── Fahdil card ────────────────────────────────────
            _FahdilCard(
              isDark: isDark,
              onLaunchUrl: (url) => _launchUrl(context, url),
              onSendEmail: (email) => _sendEmail(context, email),
            ),
            const SizedBox(height: 28),

            // ── Tech stack ─────────────────────────────────────
            _TechStackCard(isDark: isDark),
            const SizedBox(height: 24),

            Text('© 2025 Career Navigator\nMade with ❤️ in Cameroon',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textMuted(isDark),
                    fontSize: 12, height: 1.7)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── App Hero Card ─────────────────────────────────────────────────
class _AppHeroCard extends StatelessWidget {
  final bool isDark;
  const _AppHeroCard({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
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
        width: 90, height: 90,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(
            color: AppColors.primaryCyan.withOpacity(0.3),
            blurRadius: 20, spreadRadius: 4)]),
        child: ClipOval(child: Image.asset(
          'assets/logo/logo.png', fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.primaryCyan.withOpacity(0.2),
            child: const Icon(Icons.compass_calibration_outlined,
                color: AppColors.primaryCyan, size: 48)))),
      ),
      const SizedBox(height: 20),
      ShaderMask(
        shaderCallback: (b) => const LinearGradient(
          colors: [AppColors.primaryCyan, Color(0xFF0097A7)]).createShader(b),
        blendMode: BlendMode.srcIn,
        child: const Text('Career Navigator', style: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w800,
          color: Colors.white, letterSpacing: 1)),
      ),
      const SizedBox(height: 6),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primaryCyan.withOpacity(0.12),
          borderRadius: BorderRadius.circular(20)),
        child: const Text('Version 9.0', style: TextStyle(
          color: AppColors.primaryCyan, fontSize: 12,
          fontWeight: FontWeight.w600))),
      const SizedBox(height: 16),
      Text(
        'Career Navigator is an AI-powered career development platform '
        'built for African professionals. We connect talented job seekers '
        'with mentors, opportunities, and intelligent tools to navigate '
        'their career journey.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.textSecondary(isDark),
          fontSize: 13, height: 1.7)),
    ]),
  );
}

// ── Fahdil Card ───────────────────────────────────────────────────
class _FahdilCard extends StatelessWidget {
  final bool isDark;
  final Function(String) onLaunchUrl;
  final Function(String) onSendEmail;

  const _FahdilCard({
    required this.isDark,
    required this.onLaunchUrl,
    required this.onSendEmail,
  });

  // Try multiple GitHub avatar URL formats
  static const _avatarUrl = 'https://avatars.githubusercontent.com/TUHEU';
  static const _avatarUrl2 = 'https://github.com/TUHEU.png?size=200';

  Widget _buildAvatar() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: _avatarUrl,
        width: 80, height: 80, fit: BoxFit.cover,
        // Show initials while loading
        placeholder: (_, __) => _initialsCircle(),
        // On error try second URL, then fall back to initials
        errorWidget: (_, __, ___) => CachedNetworkImage(
          imageUrl: _avatarUrl2,
          width: 80, height: 80, fit: BoxFit.cover,
          placeholder: (_, __) => _initialsCircle(),
          errorWidget: (_, __, ___) => _initialsCircle(),
        ),
      ),
    );
  }

  Widget _initialsCircle() => Container(
    width: 80, height: 80,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.primaryCyan.withOpacity(0.15)),
    alignment: Alignment.center,
    child: const Text('TF', style: TextStyle(
      color: AppColors.primaryCyan,
      fontSize: 28, fontWeight: FontWeight.bold)),
  );

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.card(isDark),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.primaryCyan.withOpacity(0.25)),
      boxShadow: isDark ? [] : [BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 12, offset: const Offset(0, 4))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

      // Top row — avatar + name
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.primaryCyan.withOpacity(0.45), width: 2),
              boxShadow: [BoxShadow(
                color: AppColors.primaryCyan.withOpacity(0.2), blurRadius: 16)]),
            child: _buildAvatar(),
          ),
          Positioned(bottom: 2, right: 2, child: Container(
            width: 18, height: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF22C55E), shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 11))),
        ]),
        const SizedBox(width: 16),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tuheu Tchoubi Pempeme\nMoussa Fahdil',
              style: TextStyle(
                color: AppColors.text(isDark), fontWeight: FontWeight.bold,
                fontSize: 16, height: 1.3)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.primaryCyan.withOpacity(0.3))),
            child: const Text(
              'Full-Stack Engineer · Backend Architect · Mobile Dev',
              style: TextStyle(
                color: AppColors.primaryCyan, fontSize: 10,
                fontWeight: FontWeight.w600))),
        ])),
      ]),
      const SizedBox(height: 18),

      // Highlight bullets
      ...[
        ('🏗️', 'Architect & Backend Lead',
         'Designed the entire system from scratch — RESTful Flask API, '
         '28-table MySQL schema, JWT auth with refresh tokens, OTP email '
         'verification, and role-based access control.'),
        ('📱', 'Flutter Mobile Developer',
         'Built the cross-platform Flutter app covering job listings, '
         'AI advisor, real-time chat, mentor network, profile management, '
         'and the admin dashboard.'),
        ('🤖', 'AI Integration',
         'Integrated Google Gemini AI for the career coaching module — '
         'conversation history, session management, and context-aware '
         'advice generation across 7 tool modes.'),
        ('☁️', 'Cloud & Infrastructure',
         'Deployed the production backend on a Contabo VPS using PM2, '
         'Cloudinary for media storage, and Brevo for transactional '
         'emails and OTP delivery.'),
      ].map((h) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primaryCyan.withOpacity(isDark ? 0.05 : 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.primaryCyan.withOpacity(0.1))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(h.$1, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(h.$2, style: TextStyle(
              color: AppColors.text(isDark),
              fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 3),
            Text(h.$3, style: TextStyle(
              color: AppColors.textMuted(isDark),
              fontSize: 11, height: 1.5)),
          ])),
        ]),
      )),
      const SizedBox(height: 4),

      // Skill chips
      Wrap(spacing: 6, runSpacing: 6, children: [
        'Flutter', 'Python', 'Flask', 'MySQL', 'JWT',
        'Gemini AI', 'Cloudinary', 'Socket.IO', 'PM2', 'VPS',
      ].map((s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.primaryCyan.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.primaryCyan.withOpacity(0.25))),
        child: Text(s, style: const TextStyle(
          color: AppColors.primaryCyan,
          fontSize: 11, fontWeight: FontWeight.w600)),
      )).toList()),
      const SizedBox(height: 16),

      // Social buttons
      Wrap(spacing: 10, runSpacing: 8, children: [
        _SocialButton(
          icon: Icons.code_rounded, label: 'GitHub',
          color: isDark ? Colors.white : const Color(0xFF1F2328),
          onTap: () => onLaunchUrl('https://github.com/TUHEU')),
        _SocialButton(
          icon: Icons.link_rounded, label: 'LinkedIn',
          color: const Color(0xFF0077B5),
          onTap: () => onLaunchUrl(
              'https://www.linkedin.com/in/nadal-junior-63b5933a3/')),
        _SocialButton(
          icon: Icons.email_outlined, label: 'Email',
          color: Colors.redAccent,
          onTap: () => onSendEmail('tuheu.moussa@ictuniversity.edu.cm')),
      ]),
    ]),
  );
}

// ── Social Button ─────────────────────────────────────────────────
class _SocialButton extends StatelessWidget {
  final IconData icon; final String label;
  final Color color; final VoidCallback onTap;
  const _SocialButton({
    required this.icon, required this.label,
    required this.color, required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(
          color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ]),
    ));
}

// ── Tech Stack Card ───────────────────────────────────────────────
class _TechStackCard extends StatelessWidget {
  final bool isDark;
  const _TechStackCard({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.card(isDark),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border(isDark))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryCyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.layers_rounded,
              color: AppColors.primaryCyan, size: 18)),
        const SizedBox(width: 12),
        const Text('Tech Stack', style: TextStyle(
          color: AppColors.primaryCyan, fontSize: 15,
          fontWeight: FontWeight.bold, letterSpacing: 0.5)),
      ]),
      const SizedBox(height: 16),
      ...[
        (Icons.phone_android,    'Flutter',         'Cross-platform mobile app',              const Color(0xFF54C5F8)),
        (Icons.code,             'Python / Flask',  'REST API with Blueprints & JWT',         const Color(0xFF3776AB)),
        (Icons.storage,          'MySQL',           '28-table relational database',            const Color(0xFFF29111)),
        (Icons.psychology,       'Gemini AI',       '7 career coaching tool modes',            AppColors.primaryCyan),
        (Icons.cloud,            'Cloudinary',      'Media storage & transformation',          const Color(0xFF3448C5)),
        (Icons.email_outlined,   'Brevo',           'Transactional email & OTP delivery',      const Color(0xFF0092FF)),
        (Icons.wifi,             'Socket.IO',       'Real-time bidirectional messaging',       const Color(0xFF25D366)),
        (Icons.lock_outline,     'JWT + Bcrypt',    'Secure auth with refresh tokens',         const Color(0xFF059669)),
      ].map((t) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: (t.$4).withOpacity(isDark ? 0.05 : 0.03),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: (t.$4).withOpacity(0.15))),
        child: Row(children: [
          Icon(t.$1, color: t.$4, size: 18),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(t.$2, style: TextStyle(
              color: AppColors.text(isDark),
              fontWeight: FontWeight.bold, fontSize: 13)),
            Text(t.$3, style: TextStyle(
              color: AppColors.textMuted(isDark), fontSize: 11)),
          ])),
        ]),
      )),
    ]),
  );
}

// ── Stat Bubble ───────────────────────────────────────────────────
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
        color: AppColors.primaryCyan, fontSize: 18,
        fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(
        color: AppColors.textMuted(isDark), fontSize: 10),
        textAlign: TextAlign.center),
    ]),
  ));
}
