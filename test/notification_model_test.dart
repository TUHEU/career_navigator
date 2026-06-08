// test/notification_model_test.dart — tests data/models/notification_model.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:career_navigator/data/models/notification_model.dart';

void main() {
  Map<String, dynamic> nJson() => {
        'id': 1, 'type': 'new_message', 'title': 'New message',
        'body': 'You have a message', 'is_read': 0,
        'created_at': '2025-01-01 10:00:00',
      };

  group('NotificationModel.fromJson', () {
    test('parses fields', () {
      final n = NotificationModel.fromJson(nJson());
      expect(n.id, 1);
      expect(n.type, 'new_message');
      expect(n.title, 'New message');
      expect(n.isRead, isFalse);
    });
    test('defaults type to system', () {
      final n = NotificationModel.fromJson({'id': 1, 'title': 't', 'is_read': 0});
      expect(n.type, 'system');
    });
    test('isRead true when 1', () {
      final n = NotificationModel.fromJson({...nJson(), 'is_read': 1});
      expect(n.isRead, isTrue);
    });
  });

  group('NotificationModel icon/color', () {
    test('icon is an IconData', () {
      expect(NotificationModel.fromJson(nJson()).icon, isA<IconData>());
    });
    test('iconColor is a Color', () {
      expect(NotificationModel.fromJson(nJson()).iconColor, isA<Color>());
    });
    test('different types give different icons', () {
      final msg = NotificationModel.fromJson({...nJson(), 'type': 'new_message'});
      final job = NotificationModel.fromJson({...nJson(), 'type': 'job_alert'});
      expect(msg.icon, isNot(equals(job.icon)));
    });
  });

  test('isRead is mutable', () {
    final n = NotificationModel.fromJson(nJson());
    n.isRead = true;
    expect(n.isRead, isTrue);
  });
}
