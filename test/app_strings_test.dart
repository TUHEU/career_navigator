// test/app_strings_test.dart — tests l10n/app_strings.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:career_navigator/l10n/app_strings.dart';

void main() {
  group('English strings', () {
    test('core keys present and non-empty', () {
      for (final k in [S.signIn, S.signUp, S.email, S.password, S.logout,
                       S.continueAsGuest, S.settings, S.darkMode, S.language]) {
        expect(enStrings[k], isNotNull, reason: 'Missing EN: $k');
        expect(enStrings[k]!.isNotEmpty, isTrue);
      }
    });
    test('signIn is Sign In', () => expect(enStrings[S.signIn], 'Sign In'));
  });

  group('French strings', () {
    test('core keys present and non-empty', () {
      for (final k in [S.signIn, S.signUp, S.email, S.password, S.logout,
                       S.continueAsGuest, S.settings, S.darkMode, S.language]) {
        expect(frStrings[k], isNotNull, reason: 'Missing FR: $k');
        expect(frStrings[k]!.isNotEmpty, isTrue);
      }
    });
    test('FR differs from EN', () {
      expect(frStrings[S.signIn], isNot(equals(enStrings[S.signIn])));
      expect(frStrings[S.settings], isNot(equals(enStrings[S.settings])));
    });
  });

  group('key coverage', () {
    test('EN and FR have identical keys', () {
      expect(enStrings.keys.toSet().difference(frStrings.keys.toSet()), isEmpty);
      expect(frStrings.keys.toSet().difference(enStrings.keys.toSet()), isEmpty);
    });
    test('no empty values in either map', () {
      for (final v in enStrings.values) { expect(v.isNotEmpty, isTrue); }
      for (final v in frStrings.values) { expect(v.isNotEmpty, isTrue); }
    });
  });
}
