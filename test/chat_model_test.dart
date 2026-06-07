// test/chat_model_test.dart — tests data/models/chat_model.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:career_navigator/data/models/chat_model.dart';

void main() {
  group('Conversation.fromJson', () {
    test('parses fields', () {
      final c = Conversation.fromJson({
        'id': 1, 'other_user_id': 2, 'other_name': 'Jane',
        'last_message': 'Hi', 'unread_count': 3,
      });
      expect(c.id, 1);
      expect(c.otherUserId, 2);
      expect(c.otherName, 'Jane');
      expect(c.unreadCount, 3);
    });
    test('defaults otherName to Unknown', () {
      final c = Conversation.fromJson({'id': 1, 'other_user_id': 2});
      expect(c.otherName, 'Unknown');
    });
    test('formattedTime empty when no date', () {
      expect(Conversation.fromJson({'id': 1, 'other_user_id': 2}).formattedTime, '');
    });
  });

  group('ChatMessage.fromJson', () {
    Map<String, dynamic> msgJson() => {
          'id': 1, 'conversation_id': 5, 'sender_id': 10,
          'sender_name': 'Bob', 'content': 'Hello',
          'is_read': 1, 'created_at': '2025-01-01 10:00:00',
        };
    test('parses fields', () {
      final m = ChatMessage.fromJson(msgJson());
      expect(m.id, 1);
      expect(m.conversationId, 5);
      expect(m.senderId, 10);
      expect(m.content, 'Hello');
      expect(m.isRead, isTrue);
    });
    test('isMine true for matching user', () {
      expect(ChatMessage.fromJson(msgJson()).isMine(10), isTrue);
      expect(ChatMessage.fromJson(msgJson()).isMine(99), isFalse);
    });
    test('defaults content to empty', () {
      final m = ChatMessage.fromJson({'id': 1, 'conversation_id': 1, 'sender_id': 1, 'is_read': 0});
      expect(m.content, '');
    });
  });
}
