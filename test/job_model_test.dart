// test/job_model_test.dart — tests data/models/job_model.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:career_navigator/data/models/job_model.dart';

void main() {
  Map<String, dynamic> baseJson() => {
    'id': 1,
    'title': 'Dev',
    'company': 'Acme',
    'location': 'NYC',
    'description': 'd',
    'requirements': 'r',
    'responsibilities': 'x',
    'created_at': '2025-01-01 10:00:00',
  };

  group('JobListing.fromJson', () {
    test('parses required fields', () {
      final j = JobListing.fromJson(baseJson());
      expect(j.id, 1);
      expect(j.title, 'Dev');
      expect(j.company, 'Acme');
    });
    test('handles String id', () {
      final j = JobListing.fromJson({...baseJson(), 'id': '99'});
      expect(j.id, 99);
    });
    test('parses skills from list', () {
      final j = JobListing.fromJson({
        ...baseJson(),
        'skills_required': ['Dart', 'Flutter'],
      });
      expect(j.skillsRequired, contains('Dart'));
    });
    test('parses skills from comma string', () {
      final j = JobListing.fromJson({
        ...baseJson(),
        'skills_required': 'Dart, Flutter',
      });
      expect(j.skillsRequired, contains('Flutter'));
    });
  });

  group('JobListing boolean helpers', () {
    test('isRemote / isHybrid / isFullTime', () {
      final r = JobListing.fromJson({...baseJson(), 'location_type': 'remote'});
      expect(r.isRemote, isTrue);
      final h = JobListing.fromJson({...baseJson(), 'location_type': 'hybrid'});
      expect(h.isHybrid, isTrue);
      final f = JobListing.fromJson({
        ...baseJson(),
        'employment_type': 'full_time',
      });
      expect(f.isFullTime, isTrue);
    });
    test('hasLocation', () {
      final j = JobListing.fromJson({
        ...baseJson(),
        'latitude': 4.05,
        'longitude': 9.7,
      });
      expect(j.hasLocation, isTrue);
    });
    test('hasContact', () {
      final j = JobListing.fromJson({
        ...baseJson(),
        'contact_email': 'a@b.com',
      });
      expect(j.hasContact, isTrue);
    });
    test('hasSalary', () {
      final j = JobListing.fromJson({...baseJson(), 'salary_min': 50000});
      expect(j.hasSalary, isTrue);
    });
  });

  group('JobListing.salaryText', () {
    test('not specified', () {
      expect(
        JobListing.fromJson(baseJson()).salaryText,
        'Salary not specified',
      );
    });
    test('range with K formatting', () {
      final j = JobListing.fromJson({
        ...baseJson(),
        'salary_min': 50000,
        'salary_max': 80000,
      });
      expect(j.salaryText, contains('50K'));
      expect(j.salaryText, contains('80K'));
    });
    test('millions formatting', () {
      final j = JobListing.fromJson({...baseJson(), 'salary_min': 1500000});
      expect(j.salaryText, contains('1.5M'));
    });
  });

  group('JobListing display getters', () {
    test('experienceLevelDisplay maps', () {
      final j = JobListing.fromJson({
        ...baseJson(),
        'experience_level': 'entry',
      });
      expect(j.experienceLevelDisplay, 'Entry Level');
    });
    test('employmentTypeDisplay title-cases', () {
      final j = JobListing.fromJson({
        ...baseJson(),
        'employment_type': 'full_time',
      });
      expect(j.employmentTypeDisplay, 'Full Time');
    });
  });

  group('JobListing equality', () {
    test('equal by id', () {
      expect(
        JobListing.fromJson(baseJson()),
        equals(JobListing.fromJson(baseJson())),
      );
    });
    test('toString contains id/title/company', () {
      expect(
        JobListing.fromJson(baseJson()).toString(),
        'JobListing(1: Dev @ Acme)',
      );
    });
  });

  group('JobApplication', () {
    Map<String, dynamic> appJson() => {
      'id': 1,
      'job_id': 2,
      'status': 'pending',
      'applied_at': '2025-01-01 10:00:00',
      'title': 'Dev',
      'company': 'Acme',
    };
    test('fromJson parses', () {
      final a = JobApplication.fromJson(appJson());
      expect(a.id, 1);
      expect(a.jobId, 2);
      expect(a.isPending, isTrue);
    });
    test('statusDisplay maps', () {
      expect(
        JobApplication.fromJson(appJson()).statusDisplay,
        'Pending Review',
      );
      final hired = JobApplication.fromJson({...appJson(), 'status': 'hired'});
      expect(hired.isHired, isTrue);
    });
  });
}
