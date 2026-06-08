// test/feedback_model_test.dart — tests data/models/feedback_model.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:career_navigator/data/models/feedback_model.dart';

void main() {
  Map<String, dynamic> fbJson() => {
        'id': 1, 'user_id': 2, 'subject': 'Bug', 'message': 'Found a bug',
        'category': 'Technical', 'rating': 4, 'status': 'pending',
        'created_at': '2025-01-01 10:00:00', 'full_name': 'John', 'email': 'j@x.com',
      };

  group('FeedbackModel.fromJson', () {
    test('parses all fields', () {
      final f = FeedbackModel.fromJson(fbJson());
      expect(f.id, 1);
      expect(f.userId, 2);
      expect(f.subject, 'Bug');
      expect(f.category, 'Technical');
      expect(f.rating, 4);
      expect(f.userName, 'John');
      expect(f.userEmail, 'j@x.com');
    });
    test('handles String id from PyMySQL', () {
      final f = FeedbackModel.fromJson({...fbJson(), 'id': '55', 'user_id': '66'});
      expect(f.id, 55);
      expect(f.userId, 66);
    });
    test('defaults category and status', () {
      final f = FeedbackModel.fromJson({'id': 1, 'user_id': 2, 'subject': 's', 'message': 'm'});
      expect(f.category, 'General');
      expect(f.status, 'pending');
    });
  });

  group('FeedbackModel status helpers', () {
    test('isPending', () => expect(FeedbackModel.fromJson(fbJson()).isPending, isTrue));
    test('isReviewed', () {
      expect(FeedbackModel.fromJson({...fbJson(), 'status': 'reviewed'}).isReviewed, isTrue);
    });
    test('isResolved', () {
      expect(FeedbackModel.fromJson({...fbJson(), 'status': 'resolved'}).isResolved, isTrue);
    });
  });

  group('FeedbackModel.ratingText', () {
    test('stars for rating', () {
      expect(FeedbackModel.fromJson(fbJson()).ratingText, '⭐⭐⭐⭐');
    });
    test('No rating when null', () {
      final f = FeedbackModel.fromJson({'id': 1, 'user_id': 2, 'subject': 's', 'message': 'm'});
      expect(f.ratingText, 'No rating');
    });
  });
}
