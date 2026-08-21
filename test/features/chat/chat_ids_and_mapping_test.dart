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

    test('post lastMessage flags lastMessageIsPost', () {
      final Conversation conv = ConversationDto.fromMap('c7', <String, dynamic>{
        'participants': <String>['u1', 'u2'],
        'lastMessage': <String, dynamic>{
          'text': '',
          'type': 'post',
          'senderId': 'u2',
          'createdAt': 9,
        },
        'updatedAt': 9,
      }, 'u1');

      expect(conv.lastMessageIsPost, true);
      expect(conv.lastMessageIsImage, false);
    });

    test('story reply round-trips type, storyId on postId and text', () {
      final ChatMessageDto dto = ChatMessageDto.fromMap(<String, dynamic>{
        'senderId': 'u1',
        'text': 'sick wave',
        'createdAt': 11,
        'type': 'story',
        'postId': 'seed_story_5',
        'imageUrl': 'http://story',
      });

      final ChatMessage domain = dto.toDomain('m1', 'c1');
      expect(domain.isStory, true);
      expect(domain.isPost, false);
      expect(domain.text, 'sick wave');
      expect(domain.postId, 'seed_story_5');
      expect(domain.imageUrl, 'http://story');
      expect(dto.toMap()['postId'], 'seed_story_5');
    });

    test('unread counter maps per-participant and defaults to 0', () {
      final Map<String, dynamic> base = <String, dynamic>{
        'participants': <String>['u1', 'u2'],
        'unread': <String, dynamic>{'u1': 4},
      };
      expect(
        ConversationDto.fromMap('c4', base, 'u1').unreadCount,
        4,
      );
      expect(
        ConversationDto.fromMap('c5', <String, dynamic>{
          'participants': <String>['u1', 'u2'],
        }, 'u1').unreadCount,
        0,
      );
      // partner's counter, not mine
      expect(
        ConversationDto.fromMap('c6', base, 'u2').unreadCount,
        0,
      );
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

    test('shared-post message round-trips type, postId and cover', () {
      final ChatMessageDto dto = ChatMessageDto.fromMap(<String, dynamic>{
        'senderId': 'u1',
        'text': '',
        'createdAt': 9,
        'type': 'post',
        'postId': 'p_9',
        'imageUrl': 'http://cover',
      });
      final Map<String, dynamic> map = dto.toMap();

      expect(map['type'], 'post');
      expect(map['postId'], 'p_9');
      expect(map['imageUrl'], 'http://cover');

      final ChatMessage domain = dto.toDomain('m1', 'c1');
      expect(domain.isPost, true);
      expect(domain.isImage, false);
      expect(domain.postId, 'p_9');
      expect(domain.imageUrl, 'http://cover');
    });
  });
}
