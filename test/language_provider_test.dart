// test/language_provider_test.dart — tests l10n/language_provider.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:career_navigator/l10n/language_provider.dart';

void main() {
  late LanguageProvider lang;
  setUp(() => lang = LanguageProvider());

  test('defaults to English', () {
    expect(lang.language, AppLanguage.english);
    expect(lang.isFrench, isFalse);
    expect(lang.languageCode, 'en');
  });

  test('t() returns a non-empty string for a known key', () {
    final v = lang.t('signIn');
    expect(v, isNotEmpty);
  });

  test('languageCode matches language', () {
    expect(lang.languageCode, anyOf('en', 'fr'));
  });

  test('AppLanguage enum has english and french', () {
    expect(AppLanguage.values, containsAll([AppLanguage.english, AppLanguage.french]));
  });
}
