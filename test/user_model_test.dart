// test/user_model_test.dart — tests data/models/user_model.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:career_navigator/data/models/user_model.dart';

void main() {
  group('User.fromJson', () {
    test('parses basic fields', () {
      final u = User.fromJson({
        'id': 1, 'email': 'a@b.com', 'full_name': 'John Doe',
        'role': 'job_seeker', 'is_verified': 1,
      });
      expect(u.id, 1);
      expect(u.email, 'a@b.com');
      expect(u.fullName, 'John Doe');
      expect(u.isVerified, isTrue);
    });
    test('handles String id from PyMySQL', () {
      final u = User.fromJson({'id': '42', 'email': 'x@y.com', 'role': 'mentor', 'is_verified': 0});
      expect(u.id, 42);
      expect(u.isVerified, isFalse);
    });
    test('defaults role to job_seeker', () {
      final u = User.fromJson({'id': 1, 'email': 'a@b.com', 'is_verified': true});
      expect(u.role, 'job_seeker');
    });
  });

  group('User.displayName', () {
    test('uses fullName when present', () {
      final u = User.fromJson({'id': 1, 'email': 'a@b.com', 'full_name': 'Jane', 'role': 'mentor', 'is_verified': 1});
      expect(u.displayName, 'Jane');
    });
    test('falls back to email prefix', () {
      final u = User.fromJson({'id': 1, 'email': 'john@b.com', 'role': 'mentor', 'is_verified': 1});
      expect(u.displayName, 'john');
    });
  });

  group('User.initials', () {
    test('two names', () {
      final u = User.fromJson({'id': 1, 'email': 'a@b.com', 'full_name': 'John Doe', 'role': 'mentor', 'is_verified': 1});
      expect(u.initials, 'JD');
    });
  });

  group('Education', () {
    test('fromJson + yearsRange (current)', () {
      final e = Education.fromJson({'institution': 'MIT', 'degree': 'BSc', 'field_of_study': 'CS', 'start_year': 2018, 'is_current': 1});
      expect(e.institution, 'MIT');
      expect(e.yearsRange, '2018 - Present');
    });
    test('yearsRange with end year', () {
      final e = Education.fromJson({'institution': 'MIT', 'degree': 'BSc', 'field_of_study': 'CS', 'start_year': 2018, 'end_year': 2022});
      expect(e.yearsRange, '2018 - 2022');
    });
    test('toJson round-trip', () {
      final e = Education(institution: 'X', degree: 'Y', fieldOfStudy: 'Z', startYear: 2020);
      final j = e.toJson();
      expect(j['institution'], 'X');
      expect(j['start_year'], 2020);
    });
  });

  group('WorkExperience', () {
    test('default employmentType', () {
      final w = WorkExperience(company: 'A', jobTitle: 'Dev', startDate: '2020-01-01');
      expect(w.employmentType, 'full_time');
    });
    test('employmentTypeDisplay uppercases', () {
      final w = WorkExperience(company: 'A', jobTitle: 'Dev', startDate: '2020', employmentType: 'part_time');
      expect(w.employmentTypeDisplay, 'PART TIME');
    });
    test('dateRange current', () {
      final w = WorkExperience(company: 'A', jobTitle: 'Dev', startDate: '2020', isCurrent: true);
      expect(w.dateRange, '2020 - Present');
    });
  });
}
