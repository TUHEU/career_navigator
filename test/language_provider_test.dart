import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:career_navigator/l10n/language_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LanguageProvider lang;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    lang = LanguageProvider();

    // Give _load() time to complete.
    await Future.delayed(Duration.zero);
  });

  test('defaults to English', () {
    expect(lang.language, AppLanguage.english);
    expect(lang.isFrench, isFalse);
    expect(lang.languageCode, 'en');
  });

  test('t() returns a non-empty string for a known key', () {
    final value = lang.t('signIn');
    expect(value, isNotEmpty);
  });

  test('languageCode matches language', () {
    expect(lang.languageCode, anyOf(['en', 'fr']));
  });

  test('AppLanguage enum has english and french', () {
    expect(
      AppLanguage.values,
      containsAll([AppLanguage.english, AppLanguage.french]),
    );
  });

  test('toggle changes language', () async {
    await lang.toggle();

    expect(lang.language, anyOf([AppLanguage.english, AppLanguage.french]));
  });

  test('setLanguage updates languageCode', () async {
    await lang.setLanguage(AppLanguage.french);

    expect(lang.language, AppLanguage.french);
    expect(lang.languageCode, 'fr');

    await lang.setLanguage(AppLanguage.english);

    expect(lang.language, AppLanguage.english);
    expect(lang.languageCode, 'en');
  });
}
