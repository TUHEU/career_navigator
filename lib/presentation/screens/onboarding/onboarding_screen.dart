// presentation/screens/onboarding/onboarding_screen.dart
// v8: Full animated onboarding — language-aware, ApexSpeech-inspired design
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/themes/app_theme.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../auth/sign_in_page.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _page = 0;

  late AnimationController _bgCtrl;
  late AnimationController _contentCtrl;
  late Animation<double>   _fade;
  late Animation<double>   _slide;

  static const _colors = [
    AppColors.primaryCyan,
    Color(0xFF7C3AED),
    Color(0xFF059669),
  ];
  static const _icons = [
    Icons.work_outline_rounded,
    Icons.people_outline_rounded,
    Icons.auto_awesome_rounded,
  ];
  static const _tagKeys   = [S.onboard1Tag,   S.onboard2Tag,   S.onboard3Tag];
  static const _titleKeys = [S.onboard1Title, S.onboard2Title, S.onboard3Title];
  static const _subKeys   = [S.onboard1Sub,   S.onboard2Sub,   S.onboard3Sub];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _bgCtrl = AnimationController(vsync: this,
        duration: const Duration(seconds: 10))..repeat();
    _contentCtrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 700));
    _fade  = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _slide = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic);
    _contentCtrl.forward();
  }

  @override
  void dispose() {
    _pageCtrl.dispose(); _bgCtrl.dispose(); _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_page < 2) {
      _contentCtrl.reset();
      await _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
      _contentCtrl.forward();
    } else {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_done', true);
      if (mounted) {
        Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (_, _, _) => const SignInPage(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, a, _, child) =>
            FadeTransition(opacity: a, child: child),
      ));
      }
    }
  }

  Future<void> _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (mounted) {
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const SignInPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang  = context.watch<LanguageProvider>();
    final color = _colors[_page];

    return Scaffold(
      backgroundColor: const Color(0xFF080A12),
      body: Stack(children: [

        // Animated bg
        Positioned.fill(child: AnimatedBuilder(
          animation: _bgCtrl,
          builder: (_, _) => CustomPaint(
            painter: _BgPainter(progress: _bgCtrl.value, color: color)),
        )),

        // Rotating rings
        Center(child: AnimatedBuilder(
          animation: _bgCtrl,
          builder: (_, _) => Stack(alignment: Alignment.center,
            children: List.generate(3, (i) {
              final sz = 200.0 + i * 90;
              return Transform.rotate(
                angle: _bgCtrl.value * 2 * pi * (i.isEven ? 0.4 : -0.4),
                child: Container(width: sz, height: sz,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.04 + i * 0.01), width: 1))),
              );
            }),
          ),
        )),

        // Corner circles
        Positioned(bottom: -80, left: -50, child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 220, height: 220,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: color.withValues(alpha: 0.04),
            border: Border.all(color: color.withValues(alpha: 0.07))),
        )),
        Positioned(top: -50, right: -30, child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: 160, height: 160,
          decoration: BoxDecoration(shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.06))),
        )),

        SafeArea(child: Column(children: [

          // Skip button
          Align(alignment: Alignment.topRight,
            child: Padding(padding: const EdgeInsets.fromLTRB(0, 8, 8, 0),
              child: TextButton(onPressed: _skip,
                child: Text(lang.t(S.skip), style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2,
                )),
              ),
            ),
          ),

          // Page content
          Expanded(child: PageView.builder(
            controller: _pageCtrl,
            onPageChanged: (i) {
              setState(() => _page = i);
              _contentCtrl.forward(from: 0);
            },
            itemCount: 3,
            itemBuilder: (_, i) => _PageView(
              icon:  _icons[i],
              color: _colors[i],
              tag:   lang.t(_tagKeys[i]),
              title: lang.t(_titleKeys[i]),
              sub:   lang.t(_subKeys[i]),
              fade:  _fade,
              slide: _slide,
            ),
          )),

          // Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 36),
            child: Column(children: [
              // Dots
              Row(mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final active = _page == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 28 : 6, height: 6,
                    decoration: BoxDecoration(
                      color: active ? color : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(3)),
                  );
                }),
              ),
              const SizedBox(height: 32),
              _CTAButton(
                label: _page == 2 ? lang.t(S.getStarted) : lang.t(S.next),
                icon:  _page == 2 ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
                color: color,
                onTap: _next,
              ),
            ]),
          ),
        ])),
      ]),
    );
  }
}

class _PageView extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tag, title, sub;
  final Animation<double> fade, slide;

  const _PageView({
    required this.icon, required this.color,
    required this.tag,  required this.title, required this.sub,
    required this.fade, required this.slide,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

      AnimatedBuilder(
        animation: slide,
        builder: (_, child) => Transform.scale(
          scale: 0.6 + 0.4 * Curves.elasticOut.transform(slide.value),
          child: child,
        ),
        child: Container(
          width: 136, height: 136,
          decoration: BoxDecoration(shape: BoxShape.circle,
            color: color.withValues(alpha: 0.08),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            boxShadow: [BoxShadow(
              color: color.withValues(alpha: 0.22), blurRadius: 50, spreadRadius: 8)]),
          child: Icon(icon, color: color, size: 62),
        ),
      ),
      const SizedBox(height: 36),

      AnimatedBuilder(animation: fade,
        builder: (_, child) => Opacity(opacity: fade.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.35))),
          child: Text(tag, style: TextStyle(color: color, fontSize: 10,
              fontWeight: FontWeight.w800, letterSpacing: 2)),
        ),
      ),
      const SizedBox(height: 20),

      AnimatedBuilder(animation: slide,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, 24 * (1 - slide.value)),
          child: Opacity(opacity: fade.value, child: child),
        ),
        child: Text(title, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800,
              color: Colors.white, height: 1.2, letterSpacing: -0.5)),
      ),
      const SizedBox(height: 16),

      AnimatedBuilder(animation: fade,
        builder: (_, child) => Opacity(opacity: fade.value * 0.85, child: child),
        child: Text(sub, textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15,
              color: Colors.white.withValues(alpha: 0.6), height: 1.65)),
      ),
    ]),
  );
}

class _CTAButton extends StatefulWidget {
  final String label; final IconData icon;
  final Color color; final VoidCallback onTap;
  const _CTAButton({required this.label, required this.icon,
      required this.color, required this.onTap});
  @override State<_CTAButton> createState() => _CTAButtonState();
}
class _CTAButtonState extends State<_CTAButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _s;
  @override void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _s = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _c.forward(),
    onTapUp: (_) { _c.reverse(); widget.onTap(); },
    onTapCancel: () => _c.reverse(),
    child: ScaleTransition(scale: _s,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [widget.color, widget.color.withValues(alpha: 0.7)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(
            color: widget.color.withValues(alpha: 0.4),
            blurRadius: 24, offset: const Offset(0, 8))]),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(widget.label, style: const TextStyle(color: Colors.white,
              fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          const SizedBox(width: 10),
          Icon(widget.icon, color: Colors.white, size: 20),
        ]),
      ),
    ),
  );
}

class _BgPainter extends CustomPainter {
  final double progress; final Color color;
  const _BgPainter({required this.progress, required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(0.2 * sin(progress * 2 * pi), -0.5), radius: 1.0,
        colors: [color.withValues(alpha: 0.07), const Color(0xFF080A12)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }
  @override bool shouldRepaint(_BgPainter o) =>
      o.progress != progress || o.color != color;
}
