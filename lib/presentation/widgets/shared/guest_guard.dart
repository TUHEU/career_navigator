// presentation/widgets/shared/guest_guard.dart
// Wraps any widget that requires authentication.
// Shows lock overlay for guests instead of the feature.
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
    return _LockedOverlay(feature: feature);
  }
}

// Full-screen locked page for navigation-level features
class GuestLockedPage extends StatelessWidget {
  final GuestFeature feature;
  const GuestLockedPage({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang   = context.read<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryCyan.withValues(alpha: 0.08),
              border: Border.all(
                  color: AppColors.primaryCyan.withValues(alpha: 0.25),
                  width: 1.5)),
            child: const Icon(Icons.lock_outline_rounded,
                color: AppColors.primaryCyan, size: 52),
          ),
          const SizedBox(height: 24),
          Text(lang.t(S.guestMode), style: TextStyle(
            color: AppColors.text(isDark),
            fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(lang.t(S.guestModeDesc),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary(isDark), fontSize: 15, height: 1.5)),
          const SizedBox(height: 32),
          _SignInButton(lang: lang),
          const SizedBox(height: 16),
          Text(lang.t(S.signInToAccess), style: TextStyle(
            color: AppColors.textMuted(isDark), fontSize: 12)),
        ]),
      )),
    );
  }
}

// Inline overlay for widget-level features
class _LockedOverlay extends StatelessWidget {
  final GuestFeature feature;
  const _LockedOverlay({required this.feature});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lang   = context.read<LanguageProvider>();

    return Container(
      color: AppColors.background(isDark),
      child: Center(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryCyan.withValues(alpha: 0.08),
              border: Border.all(
                  color: AppColors.primaryCyan.withValues(alpha: 0.25))),
            child: const Icon(Icons.lock_outline_rounded,
                color: AppColors.primaryCyan, size: 40),
          ),
          const SizedBox(height: 20),
          Text(lang.t(S.guestMode), style: TextStyle(
            color: AppColors.text(isDark),
            fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(lang.t(S.guestModeDesc),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary(isDark), fontSize: 14)),
          const SizedBox(height: 24),
          _SignInButton(lang: lang),
        ]),
      )),
    );
  }
}

class _SignInButton extends StatelessWidget {
  final LanguageProvider lang;
  const _SignInButton({required this.lang});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      context.read<GuestProvider>().exitGuestMode();
      Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (_) => false);
    },
    child: Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryCyan, Color(0xFF0097A7)],
          begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
          color: AppColors.primaryCyan.withValues(alpha: 0.4),
          blurRadius: 16, offset: const Offset(0, 4))]),
      child: Center(child: Text(
        lang.t(S.signIn).toUpperCase(),
        style: const TextStyle(color: Colors.black,
            fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 1))),
    ),
  );
}
