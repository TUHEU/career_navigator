// test/helpers_test.dart — tests core/utils/helpers.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:career_navigator/core/utils/helpers.dart';

void main() {
  group('Helpers.getInitials', () {
    test('? for empty', () => expect(Helpers.getInitials(''), '?'));
    test('single name', () {
      expect(Helpers.getInitials('John'), 'J');
      expect(Helpers.getInitials('alice'), 'A');
    });
    test('first + last', () {
      expect(Helpers.getInitials('John Doe'), 'JD');
      expect(Helpers.getInitials('alice smith'), 'AS');
    });
    test('always uppercase', () => expect(Helpers.getInitials('john doe'), 'JD'));
  });

  group('Helpers.formatDate', () {
    test('empty for null', () => expect(Helpers.formatDate(null), ''));
    test('formats d/m/y', () {
      final r = Helpers.formatDate(DateTime(2025, 1, 15));
      expect(r, contains('2025'));
      expect(r, contains('15'));
    });
  });

  group('Helpers.formatDateTime', () {
    test('empty for null / empty', () {
      expect(Helpers.formatDateTime(null), '');
      expect(Helpers.formatDateTime(''), '');
    });
    test('formats date + time', () {
      expect(Helpers.formatDateTime('2025-01-15 14:30:00'), '2025-01-15 14:30');
    });
  });

  group('Helpers.getRelativeTime', () {
    test('empty for null / empty', () {
      expect(Helpers.getRelativeTime(null), '');
      expect(Helpers.getRelativeTime(''), '');
    });
    test('minutes ago', () {
      final t = DateTime.now().subtract(const Duration(minutes: 5)).toIso8601String();
      expect(Helpers.getRelativeTime(t), contains('m ago'));
    });
    test('hours ago', () {
      final t = DateTime.now().subtract(const Duration(hours: 3)).toIso8601String();
      expect(Helpers.getRelativeTime(t), contains('h ago'));
    });
    test('days ago', () {
      final t = DateTime.now().subtract(const Duration(days: 2)).toIso8601String();
      expect(Helpers.getRelativeTime(t), contains('d ago'));
    });
    test('weeks ago', () {
      final t = DateTime.now().subtract(const Duration(days: 14)).toIso8601String();
      expect(Helpers.getRelativeTime(t), contains('w ago'));
    });
    test('Just now', () {
      final t = DateTime.now().subtract(const Duration(seconds: 5)).toIso8601String();
      expect(Helpers.getRelativeTime(t), 'Just now');
    });
  });
}
