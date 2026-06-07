// test/theme_provider_test.dart — tests providers/theme_provider.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:career_navigator/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('isDarkMode has a boolean default', () {
    final t = ThemeProvider();
    expect(t.isDarkMode, isA<bool>());
  });

  test('backgroundPath returns an asset path', () {
    final t = ThemeProvider();
    expect(t.backgroundPath, contains('assets/'));
  });

  test('toggleTheme flips the value', () async {
    final t = ThemeProvider();
    final before = t.isDarkMode;
    await t.toggleTheme();
    expect(t.isDarkMode, isNot(equals(before)));
  });
}
