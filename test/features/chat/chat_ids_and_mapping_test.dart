import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_instagram_clone/features/chat/data/datasources/chat_firebase_datasource.dart';
import 'package:flutter_instagram_clone/features/chat/data/models/chat_message_dto.dart';
import 'package:flutter_instagram_clone/features/chat/data/models/conversation_dto.dart';
import 'package:flutter_instagram_clone/features/chat/domain/models/chat_message.dart';
import 'package:flutter_instagram_clone/features/chat/domain/models/conversation.dart';

void main() {
  group('conversationIdFor', () {
    test('same id for both argument orders', () {
      expect(conversationIdFor('a', 'b'), conversationIdFor('b', 'a'));
    });

    test('joins uids in sorted order', () {
      expect(conversationIdFor('a', 'b'), 'a_b');
      expect(conversationIdFor('b', 'a'), 'a_b');
    });
  });

  group('ConversationDto.fromMap', () {
    test('resolves the other participant and last message', () {
      final Conversation conv = ConversationDto.fromMap('c1', <String, dynamic>{
        'participants': <String>['u1', 'u2'],
        'participantMeta': <String, dynamic>{
          'u2': <String, dynamic>{'username': 'bob', 'avatarUrl': 'http://a'},
        },
        'lastMessage': <String, dynamic>{
          'text': 'hi',
          'senderId': 'u1',
          'createdAt': 42,
        },
        'updatedAt': 42,
      }, 'u1');

      expect(conv.id, 'c1');
      expect(conv.otherUser.uid, 'u2');
      expect(conv.otherUser.username, 'bob');
      expect(conv.otherUser.avatarUrl, 'http://a');
      expect(conv.lastMessageText, 'hi');
      expect(conv.lastMessageSenderId, 'u1');
      expect(conv.lastMessageAt, DateTime.fromMillisecondsSinceEpoch(42));
    });

    test('missing meta and lastMessage fall back to empty defaults', () {
      final Conversation conv = ConversationDto.fromMap('c2', <String, dynamic>{
        'participants': <String>['u1', 'u2'],
        'updatedAt': 1,
      }, 'u1');

      expect(conv.otherUser.uid, 'u2');
      expect(conv.otherUser.username, '');
      expect(conv.otherUser.avatarUrl, isNull);
      expect(conv.lastMessageText, '');
      expect(conv.lastMessageSenderId, isNull);
      expect(conv.lastMessageAt, isNull);
    });

    test('image lastMessage parses the type and empty preview text', () {
      final Conversation conv = ConversationDto.fromMap('c3', <String, dynamic>{
        'participants': <String>['u1', 'u2'],
        'lastMessage': <String, dynamic>{
          'text': '',
          'type': 'image',
          'senderId': 'u2',
          'createdAt': 7,
        },
        'updatedAt': 7,
      }, 'u1');

      expect(conv.lastMessageIsImage, true);
      expect(conv.lastMessageText, '');
    });
  });

  group('ChatMessageDto', () {
    test('image message round-trips type and imageUrl', () {
      final ChatMessageDto dto = ChatMessageDto.fromMap(<String, dynamic>{
        'senderId': 'u1',
        'text': '',
        'createdAt': 5,
        'type': 'image',
        'imageUrl': 'http://img',
      });
      final Map<String, dynamic> map = dto.toMap();

      expect(map['type'], 'image');
      expect(map['imageUrl'], 'http://img');

      final ChatMessage domain = dto.toDomain('m1', 'c1');
      expect(domain.isImage, true);
      expect(domain.imageUrl, 'http://img');
    });

    test('legacy text-only docs default to type text without imageUrl', () {
      final ChatMessageDto dto = ChatMessageDto.fromMap(<String, dynamic>{
        'senderId': 'u1',
        'text': 'hi',
        'createdAt': 5,
      });

      expect(dto.type, 'text');
      expect(dto.toMap().containsKey('imageUrl'), false);
      expect(dto.toDomain('m1', 'c1').isImage, false);
    });
  });
}
