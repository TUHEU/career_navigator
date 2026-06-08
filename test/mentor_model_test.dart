// test/mentor_model_test.dart — tests data/models/mentor_model.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:career_navigator/data/models/mentor_model.dart';

void main() {
  Map<String, dynamic> mJson() => {
        'id': 1, 'full_name': 'Jane Smith', 'headline': 'Senior Dev',
        'current_company': 'Acme', 'expertise_areas': ['Flutter', 'Dart'],
        'session_price': '50', 'rating': '4.5', 'total_sessions': 12,
        'is_accepting_mentees': 1,
      };

  group('MentorModel.fromJson', () {
    test('parses fields', () {
      final m = MentorModel.fromJson(mJson());
      expect(m.id, 1);
      expect(m.fullName, 'Jane Smith');
      expect(m.headline, 'Senior Dev');
      expect(m.expertiseAreas, contains('Flutter'));
      expect(m.totalSessions, 12);
      expect(m.isAcceptingMentees, isTrue);
    });
    test('parses price and rating as doubles', () {
      final m = MentorModel.fromJson(mJson());
      expect(m.sessionPrice, 50.0);
      expect(m.rating, 4.5);
    });
    test('expertise from single string', () {
      final m = MentorModel.fromJson({...mJson(), 'expertise_areas': 'Python'});
      expect(m.expertiseAreas, ['Python']);
    });
    test('defaults fullName to Unknown', () {
      final m = MentorModel.fromJson({'id': 1});
      expect(m.fullName, 'Unknown');
    });
  });

  group('MentorModel getters', () {
    test('initials', () => expect(MentorModel.fromJson(mJson()).initials, 'JS'));
    test('sessionPriceText paid', () {
      expect(MentorModel.fromJson(mJson()).sessionPriceText, contains('50'));
    });
    test('sessionPriceText free when 0', () {
      final m = MentorModel.fromJson({...mJson(), 'session_price': '0'});
      expect(m.sessionPriceText, 'Free');
    });
    test('ratingText', () => expect(MentorModel.fromJson(mJson()).ratingText, '4.5'));
    test('ratingText No rating when null', () {
      final m = MentorModel.fromJson({'id': 1, 'full_name': 'X Y'});
      expect(m.ratingText, 'No rating');
    });
  });
}
