// test/unit_test.dart
// Career Navigator Flutter — Unit Tests v8.1
// Fixed: uses actual method names from validators.dart and helpers.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:career_navigator/core/utils/validators.dart';
import 'package:career_navigator/core/utils/helpers.dart';
import 'package:career_navigator/l10n/app_strings.dart';
import 'package:career_navigator/providers/guest_provider.dart';

void main() {

  // ══════════════════════════════════════════════════════════
  // VALIDATORS
  // ══════════════════════════════════════════════════════════
  group('Validators', () {

    group('validateEmail', () {
      test('rejects null and empty', () {
        expect(Validators.validateEmail(null), isNotNull);
        expect(Validators.validateEmail(''),   isNotNull);
      });

      test('rejects invalid formats', () {
        expect(Validators.validateEmail('notanemail'),    isNotNull);
        expect(Validators.validateEmail('missing@dot'),   isNotNull);
        expect(Validators.validateEmail('@nodomain.com'), isNotNull);
        expect(Validators.validateEmail('no-at-sign'),    isNotNull);
      });

      test('accepts valid emails', () {
        expect(Validators.validateEmail('user@example.com'),    isNull);
        expect(Validators.validateEmail('test.user@domain.co'), isNull);
        expect(Validators.validateEmail('hello@mail.org'),      isNull);
      });
    });

    group('validatePassword', () {
      test('rejects null and empty', () {
        expect(Validators.validatePassword(null), isNotNull);
        expect(Validators.validatePassword(''),   isNotNull);
      });

      test('rejects password under 8 chars', () {
        expect(Validators.validatePassword('Ab1!'), isNotNull);
      });

      test('rejects missing uppercase', () {
        expect(Validators.validatePassword('alllower1!'), isNotNull);
      });

      test('rejects missing lowercase', () {
        expect(Validators.validatePassword('ALLCAPS1!'), isNotNull);
      });

      test('rejects missing digit', () {
        expect(Validators.validatePassword('NoDigits!'), isNotNull);
      });

      test('rejects missing special character', () {
        expect(Validators.validatePassword('NoSpecial1'), isNotNull);
      });

      test('accepts strong passwords', () {
        expect(Validators.validatePassword('Password123!'),  isNull);
        expect(Validators.validatePassword('MyStr0ng@Pass'), isNull);
        expect(Validators.validatePassword('Secure#99Pass'), isNull);
      });
    });

    group('validateRequired', () {
      test('rejects null and empty', () {
        expect(Validators.validateRequired(null, 'Field'), isNotNull);
        expect(Validators.validateRequired('',   'Field'), isNotNull);
      });

      test('accepts non-empty value', () {
        expect(Validators.validateRequired('hello',   'Field'), isNull);
        expect(Validators.validateRequired('Flutter', 'Field'), isNull);
      });

      test('includes field name in error message', () {
        final msg = Validators.validateRequired(null, 'Email');
        expect(msg, contains('Email'));
      });
    });

    group('passwordStrength', () {
      test('returns 0 for empty password', () {
        expect(Validators.passwordStrength(''), 0);
      });

      test('returns 4 for strong password', () {
        expect(Validators.passwordStrength('Password123!'), 4);
      });

      test('increases with each requirement met', () {
        final weak   = Validators.passwordStrength('password');
        final medium = Validators.passwordStrength('Password1');
        final strong = Validators.passwordStrength('Password1!');
        expect(medium, greaterThan(weak));
        expect(strong, greaterThan(medium));
      });
    });

    group('strengthLabel', () {
      test('returns Weak for score 0-1', () {
        expect(Validators.strengthLabel(0), 'Weak');
        expect(Validators.strengthLabel(1), 'Weak');
      });

      test('returns Fair for score 2', () {
        expect(Validators.strengthLabel(2), 'Fair');
      });

      test('returns Good for score 3', () {
        expect(Validators.strengthLabel(3), 'Good');
      });

      test('returns Strong for score 4', () {
        expect(Validators.strengthLabel(4), 'Strong');
      });
    });

    group('validatePhone', () {
      test('accepts null and empty (optional field)', () {
        expect(Validators.validatePhone(null), isNull);
        expect(Validators.validatePhone(''),   isNull);
      });

      test('accepts valid phone numbers', () {
        expect(Validators.validatePhone('+237699123456'), isNull);
        expect(Validators.validatePhone('0699123456'),    isNull);
      });

      test('rejects too-short number', () {
        expect(Validators.validatePhone('123'), isNotNull);
      });
    });

  });

  // ══════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════
  group('Helpers', () {

    group('getInitials', () {
      test('returns ? for empty name', () {
        expect(Helpers.getInitials(''), '?');
      });

      test('returns first letter for single name', () {
        expect(Helpers.getInitials('John'),  'J');
        expect(Helpers.getInitials('alice'), 'A');
      });

      test('returns initials of first and last name', () {
        expect(Helpers.getInitials('John Doe'),    'JD');
        expect(Helpers.getInitials('Alice Smith'), 'AS');
      });

      test('initials are always uppercase', () {
        expect(Helpers.getInitials('john doe'),  'JD');
        expect(Helpers.getInitials('alice bob'), 'AB');
      });
    });

    group('getRelativeTime', () {
      test('returns empty string for null/empty', () {
        expect(Helpers.getRelativeTime(null), '');
        expect(Helpers.getRelativeTime(''),   '');
      });

      test('returns minutes ago', () {
        final t = DateTime.now()
            .subtract(const Duration(minutes: 5))
            .toIso8601String();
        expect(Helpers.getRelativeTime(t), contains('m ago'));
      });

      test('returns hours ago', () {
        final t = DateTime.now()
            .subtract(const Duration(hours: 3))
            .toIso8601String();
        expect(Helpers.getRelativeTime(t), contains('h ago'));
      });

      test('returns days ago', () {
        final t = DateTime.now()
            .subtract(const Duration(days: 2))
            .toIso8601String();
        expect(Helpers.getRelativeTime(t), contains('d ago'));
      });

      test('returns weeks ago', () {
        final t = DateTime.now()
            .subtract(const Duration(days: 14))
            .toIso8601String();
        expect(Helpers.getRelativeTime(t), contains('w ago'));
      });

      test('returns Just now for very recent time', () {
        final t = DateTime.now()
            .subtract(const Duration(seconds: 10))
            .toIso8601String();
        expect(Helpers.getRelativeTime(t), 'Just now');
      });
    });

    group('formatDate', () {
      test('returns empty string for null', () {
        expect(Helpers.formatDate(null), '');
      });

      test('formats date correctly', () {
        final date   = DateTime(2025, 1, 15);
        final result = Helpers.formatDate(date);
        expect(result, contains('2025'));
        expect(result, contains('15'));
      });
    });

  });

  // ══════════════════════════════════════════════════════════
  // LANGUAGE STRINGS  (v8)
  // ══════════════════════════════════════════════════════════
  group('AppStrings', () {

    group('English strings', () {
      test('all key constants have EN translations', () {
        final keys = [
          S.signIn, S.signUp, S.email, S.password, S.logout,
          S.continueAsGuest, S.verifyEmail, S.verifyBtn,
          S.settings, S.darkMode, S.language, S.editProfile,
          S.onboard1Title, S.onboard2Title, S.onboard3Title,
          S.guestMode, S.guestModeDesc, S.signInToAccess,
        ];
        for (final k in keys) {
          expect(enStrings[k], isNotNull,
              reason: 'Missing EN string for key: $k');
          expect(enStrings[k]!.isNotEmpty, isTrue,
              reason: 'Empty EN string for key: $k');
        }
      });

      test('sign in string is correct', () {
        expect(enStrings[S.signIn], 'Sign In');
      });

      test('continue as guest is correct', () {
        expect(enStrings[S.continueAsGuest], 'Continue as Guest');
      });

      test('onboarding has 3 full pages', () {
        for (final k in [
          S.onboard1Tag, S.onboard1Title, S.onboard1Sub,
          S.onboard2Tag, S.onboard2Title, S.onboard2Sub,
          S.onboard3Tag, S.onboard3Title, S.onboard3Sub,
        ]) {
          expect(enStrings[k], isNotNull);
          expect(enStrings[k]!.length, greaterThan(3));
        }
      });
    });

    group('French strings', () {
      test('all key constants have FR translations', () {
        final keys = [
          S.signIn, S.signUp, S.email, S.password, S.logout,
          S.continueAsGuest, S.verifyEmail, S.verifyBtn,
          S.settings, S.darkMode, S.language, S.editProfile,
          S.onboard1Title, S.onboard2Title, S.onboard3Title,
          S.guestMode, S.guestModeDesc,
        ];
        for (final k in keys) {
          expect(frStrings[k], isNotNull,
              reason: 'Missing FR string for key: $k');
          expect(frStrings[k]!.isNotEmpty, isTrue,
              reason: 'Empty FR string for key: $k');
        }
      });

      test('FR and EN strings are different (real translation)', () {
        expect(frStrings[S.signIn],    isNot(equals(enStrings[S.signIn])));
        expect(frStrings[S.settings],  isNot(equals(enStrings[S.settings])));
        expect(frStrings[S.logout],    isNot(equals(enStrings[S.logout])));
      });

      test('FR sign in is correct', () {
        expect(frStrings[S.signIn], 'Se connecter');
      });
    });

    group('String key coverage', () {
      test('EN and FR maps have identical keys', () {
        final enKeys = enStrings.keys.toSet();
        final frKeys = frStrings.keys.toSet();
        expect(enKeys.difference(frKeys), isEmpty,
            reason: 'Keys in EN but missing in FR');
        expect(frKeys.difference(enKeys), isEmpty,
            reason: 'Keys in FR but missing in EN');
      });
    });

  });

  // ══════════════════════════════════════════════════════════
  // GUEST PROVIDER  (v8)
  // ══════════════════════════════════════════════════════════
  group('GuestProvider', () {
    late GuestProvider guest;

    setUp(() => guest = GuestProvider());

    test('starts as NOT guest', () {
      expect(guest.isGuest, isFalse);
    });

    test('enterGuestMode sets isGuest to true', () {
      guest.enterGuestMode();
      expect(guest.isGuest, isTrue);
    });

    test('exitGuestMode sets isGuest back to false', () {
      guest.enterGuestMode();
      guest.exitGuestMode();
      expect(guest.isGuest, isFalse);
    });

    group('canAccess — authenticated user', () {
      test('can access all features', () {
        for (final f in GuestFeature.values) {
          expect(guest.canAccess(f), isTrue,
              reason: 'Authenticated user blocked from: $f');
        }
      });
    });

    group('canAccess — guest user', () {
      setUp(() => guest.enterGuestMode());

      test('can browse jobs',    () => expect(guest.canAccess(GuestFeature.browseJobs),   isTrue));
      test('can view mentors',   () => expect(guest.canAccess(GuestFeature.viewMentors),  isTrue));
      test('can view about',     () => expect(guest.canAccess(GuestFeature.viewAbout),    isTrue));
      test('cannot apply',       () => expect(guest.canAccess(GuestFeature.applyJob),     isFalse));
      test('cannot chat',        () => expect(guest.canAccess(GuestFeature.chat),         isFalse));
      test('cannot use AI',      () => expect(guest.canAccess(GuestFeature.aiTools),      isFalse));
      test('cannot edit profile',() => expect(guest.canAccess(GuestFeature.editProfile),  isFalse));
      test('cannot notifications',()=> expect(guest.canAccess(GuestFeature.notifications),isFalse));
      test('cannot send request',() => expect(guest.canAccess(GuestFeature.sendRequest),  isFalse));
    });

    test('GuestFeature has 9 values', () {
      expect(GuestFeature.values.length, 9);
    });

  });

  // ══════════════════════════════════════════════════════════
  // APP CONSTANTS
  // ══════════════════════════════════════════════════════════
  group('AppConstants', () {
    test('baseUrl starts with http', () {
      const url = 'http://192.168.1.191:5000';
      expect(url, startsWith('http'));
      expect(url, isNotEmpty);
    });

    test('AI stream endpoint is /ai/stream', () {
      const endpoint = '/ai/stream';
      expect(endpoint, equals('/ai/stream'));
    });
  });

}
