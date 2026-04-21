import 'package:flutter/material.dart';
import '../main.dart';
import '../services/token_store.dart';
import '../theme/app_theme.dart';
import 'mentor_profile_page.dart';
import 'profile_setup_page.dart';
import 'sign_in_page.dart';

class SettingsPage extends StatefulWidget {
  final Map<String, dynamic> profile;
  final String role;

  const SettingsPage({super.key, required this.profile, required this.role});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ThemeMode _themeMode = ThemeMode.dark;
  Locale _locale = const Locale('en');

  @override
  void initState() {
    super.initState();
    final appState = MyApp.of(context);
    if (appState != null) {
      _themeMode = appState.themeMode;
      _locale = appState.locale;
    }
  }

  void _onThemeChanged(ThemeMode? mode) {
    if (mode == null) return;
    final appState = MyApp.of(context);
    if (appState != null) {
      appState.updateThemeMode(mode);
    }
    setState(() {
      _themeMode = mode;
    });
  }

  void _onLocaleChanged(Locale? locale) {
    if (locale == null) return;
    final appState = MyApp.of(context);
    if (appState != null) {
      appState.updateLocale(locale);
    }
    setState(() {
      _locale = locale;
    });
  }

  Future<void> _logout() async {
    await TokenStore.clear();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (route) => false,
      );
    }
  }

  void _editProfile() {
    if (widget.role == 'mentor') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MentorProfilePage(profile: widget.profile),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileSetupPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primaryCyan),
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Profile'),
            const SizedBox(height: 8),
            _buildListTile(
              icon: Icons.edit,
              title: 'Edit Profile',
              subtitle: 'Update your account details',
              onTap: _editProfile,
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Appearance'),
            const SizedBox(height: 8),
            _buildListTile(
              icon: Icons.color_lens,
              title: 'Theme',
              subtitle: _themeMode == ThemeMode.light
                  ? 'Light'
                  : _themeMode == ThemeMode.dark
                  ? 'Dark'
                  : 'System',
              trailing: DropdownButton<ThemeMode>(
                value: _themeMode,
                dropdownColor: AppColors.darkBackground,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                  DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                ],
                onChanged: _onThemeChanged,
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Language'),
            const SizedBox(height: 8),
            _buildListTile(
              icon: Icons.language,
              title: 'App Language',
              subtitle: _locale.languageCode == 'es' ? 'Spanish' : 'English',
              trailing: DropdownButton<Locale>(
                value: _locale,
                dropdownColor: AppColors.darkBackground,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(value: Locale('en'), child: Text('English')),
                  DropdownMenuItem(value: Locale('es'), child: Text('Spanish')),
                ],
                onChanged: _onLocaleChanged,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Logout',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.05),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryCyan),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(color: Colors.white70))
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}