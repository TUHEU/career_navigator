// presentation/screens/settings/settings_page.dart
// v8: Language switcher + guest mode awareness + improved design
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/themes/app_theme.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../../data/datasources/local/token_store.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/language_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/guest_provider.dart';
import '../../../providers/theme_provider.dart';
import '../auth/sign_in_page.dart';
import '../profile/edit_profile_page.dart';
import 'about_us_page.dart';
import 'help_faq_page.dart';
import 'privacy_policy_page.dart';
import 'send_feedback_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final theme  = context.watch<ThemeProvider>();
    final lang   = context.watch<LanguageProvider>();
    final auth   = context.read<AuthProvider>();
    final guest  = context.watch<GuestProvider>();

    return Scaffold(
      backgroundColor: AppColors.background(isDark),
      body: SafeArea(child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [

          Text(lang.t(S.settings), style: TextStyle(
            fontSize: 26, fontWeight: FontWeight.bold,
            color: AppColors.text(isDark))),
          const SizedBox(height: 28),

          // Guest banner
          if (guest.isGuest) ...[
            _GuestBanner(lang: lang, isDark: isDark),
            const SizedBox(height: 20),
          ],

          // ── Appearance ─────────────────────────────────
          _SectionLabel(lang.t(S.appearance)),
          const SizedBox(height: 12),
          _SwitchTile(
            icon: isDark ? Icons.dark_mode : Icons.light_mode_outlined,
            label: lang.t(S.darkMode),
            value: isDark,
            onChanged: (_) => theme.toggleTheme(),
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _LangTile(lang: lang, isDark: isDark),

          const SizedBox(height: 24),

          // ── Account ────────────────────────────────────
          if (!guest.isGuest) ...[
            _SectionLabel(lang.t(S.account)),
            const SizedBox(height: 12),
            _Tile(
              icon: Icons.person_outline_rounded,
              label: lang.t(S.editProfile),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage())),
              isDark: isDark,
            ),
            _Tile(
              icon: Icons.lock_outline_rounded,
              label: lang.t(S.changePassword),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const _ChangePasswordPage())),
              isDark: isDark,
            ),
            const SizedBox(height: 24),
          ],

          // ── Support ────────────────────────────────────
          _SectionLabel(lang.t(S.support)),
          const SizedBox(height: 12),
          _Tile(icon: Icons.help_outline_rounded, label: lang.t(S.helpFaq),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HelpFaqPage())),
            isDark: isDark),
          _Tile(icon: Icons.info_outline_rounded, label: lang.t(S.aboutUs),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AboutUsPage())),
            isDark: isDark),
          _Tile(icon: Icons.privacy_tip_outlined, label: lang.t(S.privacyPolicy),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
            isDark: isDark),
          if (!guest.isGuest)
            _Tile(icon: Icons.feedback_outlined, label: lang.t(S.sendFeedback),
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SendFeedbackPage())),
              isDark: isDark),

          const SizedBox(height: 24),

          // Logout / Sign in
          if (guest.isGuest)
            _AuthButton(
              label: lang.t(S.signIn),
              icon: Icons.login_rounded,
              color: AppColors.primaryCyan,
              onTap: () {
                context.read<GuestProvider>().exitGuestMode();
                Navigator.pushAndRemoveUntil(context,
                  MaterialPageRoute(builder: (_) => const SignInPage()),
                  (_) => false);
              },
            )
          else
            _AuthButton(
              label: lang.t(S.logout),
              icon: Icons.logout_rounded,
              color: AppColors.danger,
              onTap: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const SignInPage()),
                    (_) => false);
                }
              },
            ),
          const SizedBox(height: 24),
        ],
      )),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 4),
    child: Text(text.toUpperCase(), style: const TextStyle(
      color: AppColors.primaryCyan, fontSize: 11,
      fontWeight: FontWeight.bold, letterSpacing: 1.5)),
  );
}

class _Tile extends StatelessWidget {
  final IconData icon; final String label;
  final VoidCallback onTap; final bool isDark;
  final Color? iconColor;
  const _Tile({required this.icon, required this.label,
      required this.onTap, required this.isDark, this.iconColor});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: AppColors.card(isDark),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border(isDark))),
    child: ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primaryCyan, size: 22),
      title: Text(label, style: TextStyle(
          color: iconColor ?? AppColors.text(isDark),
          fontWeight: FontWeight.w500)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: AppColors.textMuted(isDark), size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class _SwitchTile extends StatelessWidget {
  final IconData icon; final String label;
  final bool value; final ValueChanged<bool> onChanged;
  final bool isDark;
  const _SwitchTile({required this.icon, required this.label,
      required this.value, required this.onChanged, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: AppColors.card(isDark),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border(isDark))),
    child: SwitchListTile(
      secondary: Icon(icon, color: AppColors.primaryCyan, size: 22),
      title: Text(label, style: TextStyle(
          color: AppColors.text(isDark), fontWeight: FontWeight.w500)),
      value: value, onChanged: onChanged,
      activeColor: AppColors.primaryCyan,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class _LangTile extends StatelessWidget {
  final LanguageProvider lang; final bool isDark;
  const _LangTile({required this.lang, required this.isDark});

  void _show(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: AppColors.surface(isDark),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border(isDark),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(lang.t(S.chooseLanguage), style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold,
              color: AppColors.text(isDark))),
          const SizedBox(height: 20),
          for (final opt in [
            (AppLanguage.english, '🇬🇧 English'),
            (AppLanguage.french,  '🇫🇷 Français'),
          ])
            Padding(padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () async {
                  await lang.setLanguage(opt.$1);
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: lang.language == opt.$1
                        ? AppColors.primaryCyan.withOpacity(0.12)
                        : AppColors.card(isDark),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: lang.language == opt.$1
                          ? AppColors.primaryCyan
                          : AppColors.border(isDark),
                      width: lang.language == opt.$1 ? 1.5 : 1)),
                  child: Row(children: [
                    Text(opt.$2, style: TextStyle(fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: lang.language == opt.$1
                            ? AppColors.primaryCyan
                            : AppColors.text(isDark))),
                    const Spacer(),
                    if (lang.language == opt.$1)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.primaryCyan, size: 20),
                  ]),
                ),
              ),
            ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.card(isDark),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.border(isDark))),
    child: ListTile(
      leading: const Icon(Icons.language_rounded,
          color: AppColors.primaryCyan, size: 22),
      title: Text(lang.t(S.language), style: TextStyle(
          color: AppColors.text(isDark), fontWeight: FontWeight.w500)),
      trailing: GestureDetector(
        onTap: () => _show(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryCyan.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryCyan.withOpacity(0.4))),
          child: Text(lang.languageLabel, style: const TextStyle(
              color: AppColors.primaryCyan,
              fontWeight: FontWeight.bold, fontSize: 13)),
        ),
      ),
      onTap: () => _show(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}

class _GuestBanner extends StatelessWidget {
  final LanguageProvider lang; final bool isDark;
  const _GuestBanner({required this.lang, required this.isDark});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.warning.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.warning.withOpacity(0.3))),
    child: Row(children: [
      Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Text(lang.t(S.guestModeDesc),
        style: TextStyle(color: AppColors.warning, fontSize: 13))),
    ]),
  );
}

class _AuthButton extends StatelessWidget {
  final String label; final IconData icon;
  final Color color; final VoidCallback onTap;
  const _AuthButton({required this.label, required this.icon,
      required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 52,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: color,
            fontWeight: FontWeight.w600, fontSize: 15)),
      ]),
    ),
  );
}

// ── Change password inline ─────────────────────────────────
class _ChangePasswordPage extends StatefulWidget {
  const _ChangePasswordPage();
  @override
  State<_ChangePasswordPage> createState() => _ChangePasswordPageState();
}
class _ChangePasswordPageState extends State<_ChangePasswordPage> {
  final _currCtrl    = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _sc = false, _sn = false, _sf = false;

  @override
  void dispose() {
    _currCtrl.dispose(); _newCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_newCtrl.text != _confirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    setState(() => _loading = true);
    final token = await TokenStore().getAccess();
    if (token == null) { setState(() => _loading = false); return; }
    final res = await ApiService().changePassword(
        token, _currCtrl.text, _newCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed')));
    }
  }

  Widget _f(String lbl, TextEditingController c, bool show,
      VoidCallback tog, bool d) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextField(controller: c, obscureText: !show,
      style: TextStyle(color: AppColors.text(d)),
      decoration: InputDecoration(labelText: lbl,
        labelStyle: TextStyle(color: AppColors.textSecondary(d)),
        filled: true, fillColor: AppColors.inputFill(d),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: AppColors.border(d))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primaryCyan, width: 2)),
        suffixIcon: IconButton(
          icon: Icon(show ? Icons.visibility_off : Icons.visibility,
              color: AppColors.primaryCyan, size: 20),
          onPressed: tog))));

  @override
  Widget build(BuildContext context) {
    final d = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.background(d),
      appBar: AppBar(
        title: Text(context.read<LanguageProvider>().t(S.changePassword),
            style: TextStyle(color: AppColors.text(d))),
        backgroundColor: AppColors.surface(d), elevation: 0,
        iconTheme: IconThemeData(color: AppColors.text(d))),
      body: Padding(padding: const EdgeInsets.all(20),
        child: Column(children: [
          _f('Current Password', _currCtrl, _sc, () => setState(() => _sc = !_sc), d),
          _f('New Password', _newCtrl, _sn, () => setState(() => _sn = !_sn), d),
          _f('Confirm Password', _confirmCtrl, _sf, () => setState(() => _sf = !_sf), d),
          const SizedBox(height: 12),
          GestureDetector(onTap: _loading ? null : _submit,
            child: Container(height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppColors.primaryCyan, Color(0xFF0097A7)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                    color: AppColors.primaryCyan.withOpacity(0.4),
                    blurRadius: 16, offset: const Offset(0, 4))]),
              child: Center(child: _loading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('CHANGE PASSWORD', style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w800,
                      letterSpacing: 1))))),
        ])),
    );
  }
}
