// presentation/widgets/shared/guest_guard.dart
// Wraps any widget that requires authentication.
// In guest mode shows a "Sign in to access" overlay instead.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/guest_provider.dart';
import '../../screens/auth/sign_in_page.dart';

class GuestGuard extends StatelessWidget {
  final Widget child;
  final GuestFeature feature;

  const GuestGuard({
    super.key,
    required this.child,
    required this.feature,
  });

  @override
  Widget build(BuildContext context) {
    final guest = context.watch<GuestProvider>();
    if (guest.canAccess(feature)) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang   = context.read<LanguageProvider>();

    return Stack(children: [
      child,
      Positioned.fill(child: Container(
        decoration: BoxDecoration(
          color: AppColors.background(isDark).withOpacity(0.92),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryCyan.withOpacity(0.1),
              border: Border.all(
                  color: AppColors.primaryCyan.withOpacity(0.3), width: 1.5)),
            child: const Icon(Icons.lock_outline_rounded,
                color: AppColors.primaryCyan, size: 36),
          ),
          const SizedBox(height: 16),
          Text(lang.t(S.guestMode), style: TextStyle(
            color: AppColors.text(isDark), fontSize: 18,
            fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(lang.t(S.guestModeDesc),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary(isDark), fontSize: 13)),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: _SignInBtn(lang: lang),
          ),
        ]),
      )),
    ]);
  }
}

class _SignInBtn extends StatefulWidget {
  final LanguageProvider lang;
  const _SignInBtn({required this.lang});
  @override State<_SignInBtn> createState() => _SignInBtnState();
}
class _SignInBtnState extends State<_SignInBtn>
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
    onTapDown: (_) => _c.forward(),
    onTapUp: (_) {
      _c.reverse();
      context.read<GuestProvider>().exitGuestMode();
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (_) => false);
    },
    onTapCancel: () => _c.reverse(),
    child: ScaleTransition(scale: _s,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primaryCyan, Color(0xFF0097A7)],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(
            color: AppColors.primaryCyan.withOpacity(0.4),
            blurRadius: 16, offset: const Offset(0, 4))]),
        child: Center(child: Text(
          widget.lang.t(S.signIn).toUpperCase(),
          style: const TextStyle(color: Colors.black, fontSize: 14,
              fontWeight: FontWeight.w800, letterSpacing: 1))),
      ),
    ),
  );
}
