// test/validators_test.dart — tests core/utils/validators.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:career_navigator/core/utils/validators.dart';

void main() {
  group('Validators.validateEmail', () {
    test('rejects null / empty', () {
      expect(Validators.validateEmail(null), isNotNull);
      expect(Validators.validateEmail(''), isNotNull);
    });
    test('rejects invalid formats', () {
      expect(Validators.validateEmail('notanemail'), isNotNull);
      expect(Validators.validateEmail('@nodomain.com'), isNotNull);
      expect(Validators.validateEmail('missing@dot'), isNotNull);
    });
    test('accepts valid emails', () {
      expect(Validators.validateEmail('user@example.com'), isNull);
      expect(Validators.validateEmail('test.user@domain.co'), isNull);
    });
  });

  group('Validators.validatePassword', () {
    test('rejects null / empty', () {
      expect(Validators.validatePassword(null), isNotNull);
      expect(Validators.validatePassword(''), isNotNull);
    });
    test('rejects too short', () => expect(Validators.validatePassword('Ab1!'), isNotNull));
    test('rejects no uppercase', () => expect(Validators.validatePassword('alllower1!'), isNotNull));
    test('rejects no lowercase', () => expect(Validators.validatePassword('ALLCAPS1!'), isNotNull));
    test('rejects no digit', () => expect(Validators.validatePassword('NoDigits!'), isNotNull));
    test('rejects no special', () => expect(Validators.validatePassword('NoSpecial1'), isNotNull));
    test('accepts strong', () {
      expect(Validators.validatePassword('Password123!'), isNull);
      expect(Validators.validatePassword('MyStr0ng@Pass'), isNull);
    });
  });

  group('Validators.passwordStrength', () {
    test('0 for empty', () => expect(Validators.passwordStrength(''), 0));
    test('4 for strong', () => expect(Validators.passwordStrength('Password123!'), 4));
    test('increases with requirements', () {
      expect(Validators.passwordStrength('Password1!'),
          greaterThan(Validators.passwordStrength('password')));
    });
  });

  group('Validators.strengthLabel', () {
    test('Weak 0-1', () {
      expect(Validators.strengthLabel(0), 'Weak');
      expect(Validators.strengthLabel(1), 'Weak');
    });
    test('Fair 2', () => expect(Validators.strengthLabel(2), 'Fair'));
    test('Good 3', () => expect(Validators.strengthLabel(3), 'Good'));
    test('Strong 4', () => expect(Validators.strengthLabel(4), 'Strong'));
  });

  group('Validators.validateRequired', () {
    test('rejects null / empty', () {
      expect(Validators.validateRequired(null, 'Field'), isNotNull);
      expect(Validators.validateRequired('', 'Field'), isNotNull);
    });
    test('accepts value', () => expect(Validators.validateRequired('hi', 'Field'), isNull));
    test('includes field name', () =>
        expect(Validators.validateRequired(null, 'Email'), contains('Email')));
  });

  group('Validators.validateYear', () {
    test('rejects null / empty', () {
      expect(Validators.validateYear(null), isNotNull);
      expect(Validators.validateYear(''), isNotNull);
    });
    test('rejects non-numeric / out of range', () {
      expect(Validators.validateYear('abcd'), isNotNull);
      expect(Validators.validateYear('1800'), isNotNull);
    });
    test('accepts valid year', () => expect(Validators.validateYear('2020'), isNull));
  });

  group('Validators.validatePhone', () {
    test('accepts null / empty (optional)', () {
      expect(Validators.validatePhone(null), isNull);
      expect(Validators.validatePhone(''), isNull);
    });
    test('accepts valid', () {
      expect(Validators.validatePhone('+237699123456'), isNull);
      expect(Validators.validatePhone('0699123456'), isNull);
    });
    test('rejects too short', () => expect(Validators.validatePhone('123'), isNotNull));
  });
}
