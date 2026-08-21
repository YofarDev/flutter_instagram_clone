import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/chat/data/datasources/chat_firebase_datasource.dart';
import 'package:flutter_instagram_clone/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:flutter_instagram_clone/features/chat/domain/models/chat_message.dart';
import 'package:flutter_instagram_clone/features/chat/domain/models/conversation.dart';

class MockChatDataSource extends Mock implements IChatDataSource {}

final Conversation conversation = Conversation(
  id: 'u1_u2',
  otherUser: const AppUser(uid: 'u2', email: '', username: 'bob'),
);

final ChatMessage message = ChatMessage(
  id: 'm1',
  conversationId: 'u1_u2',
  senderId: 'u1',
  text: 'hi',
  createdAt: DateTime.fromMillisecondsSinceEpoch(0),
);

void main() {
  late MockChatDataSource ds;
  late ChatRepositoryImpl repo;

  setUp(() {
    ds = MockChatDataSource();
    repo = ChatRepositoryImpl(ds);
  });

  group('watchConversations', () {
    test('passes datasource stream through unchanged', () async {
      when(() => ds.watchConversations(myUid: 'u1')).thenAnswer(
        (_) => Stream<List<Conversation>>.value(<Conversation>[conversation]),
      );

      final List<List<Conversation>> emitted = await repo
          .watchConversations(myUid: 'u1')
          .toList();

      expect(emitted, <List<Conversation>>[
        <Conversation>[conversation],
      ]);
      verify(() => ds.watchConversations(myUid: 'u1')).called(1);
    });
  });

  group('watchMessages', () {
    test('passes datasource stream through unchanged', () async {
      when(() => ds.watchMessages(conversationId: 'u1_u2')).thenAnswer(
        (_) => Stream<List<ChatMessage>>.value(<ChatMessage>[message]),
      );

      final List<List<ChatMessage>> emitted = await repo
          .watchMessages(conversationId: 'u1_u2')
          .toList();

      expect(emitted, <List<ChatMessage>>[
        <ChatMessage>[message],
      ]);
      verify(() => ds.watchMessages(conversationId: 'u1_u2')).called(1);
    });
  });

  group('getOrCreateConversation', () {
    test('returns Right with conversation from datasource', () async {
      when(
        () => ds.getOrCreateConversation(myUid: 'u1', otherUid: 'u2'),
      ).thenAnswer((_) async => conversation);

      final Either<Failure, Conversation> result = await repo
          .getOrCreateConversation(myUid: 'u1', otherUid: 'u2');

      final Conversation? resolved = result.fold(
        (_) => null,
        (Conversation c) => c,
      );
      expect(resolved, conversation);
    });

    test('forwards myUid and otherUid to datasource', () async {
      when(
        () => ds.getOrCreateConversation(myUid: 'u1', otherUid: 'u2'),
      ).thenAnswer((_) async => conversation);

      await repo.getOrCreateConversation(myUid: 'u1', otherUid: 'u2');

      verify(
        () => ds.getOrCreateConversation(myUid: 'u1', otherUid: 'u2'),
      ).called(1);
    });

    test('returns Left(Failure.serverError) when datasource throws', () async {
      when(
        () => ds.getOrCreateConversation(myUid: 'u1', otherUid: 'u2'),
      ).thenThrow(Exception('nope'));

      final Either<Failure, Conversation> result = await repo
          .getOrCreateConversation(myUid: 'u1', otherUid: 'u2');

      final Failure? failure = result.fold((Failure f) => f, (_) => null);
      expect(failure, isNotNull);
      expect(failure!.message, contains('nope'));
    });
  });

  group('sendMessage', () {
    test('returns Right(null) on success', () async {
      when(
        () => ds.sendMessage(
          conversationId: 'u1_u2',
          myUid: 'u1',
          otherUid: 'u2',
          text: 'hi',
        ),
      ).thenAnswer((_) async {});

      final Either<Failure, void> result = await repo.sendMessage(
        conversationId: 'u1_u2',
        myUid: 'u1',
        otherUid: 'u2',
        text: 'hi',
      );

      expect(result, const Right<Failure, void>(null));
    });

    test('forwards all params to datasource', () async {
      when(
        () => ds.sendMessage(
          conversationId: 'u1_u2',
          myUid: 'u1',
          otherUid: 'u2',
          text: 'hi',
        ),
      ).thenAnswer((_) async {});

      await repo.sendMessage(
        conversationId: 'u1_u2',
        myUid: 'u1',
        otherUid: 'u2',
        text: 'hi',
      );

      verify(
        () => ds.sendMessage(
          conversationId: 'u1_u2',
          myUid: 'u1',
          otherUid: 'u2',
          text: 'hi',
        ),
      ).called(1);
    });

    test('returns Left when datasource throws', () async {
      when(
        () => ds.sendMessage(
          conversationId: 'u1_u2',
          myUid: 'u1',
          otherUid: 'u2',
          text: 'hi',
        ),
      ).thenThrow(Exception('send failed'));

      final Either<Failure, void> result = await repo.sendMessage(
        conversationId: 'u1_u2',
        myUid: 'u1',
        otherUid: 'u2',
        text: 'hi',
      );

      expect(result.isLeft(), true);
    });
  });

  group('sendImageMessage', () {
    test('returns Right(null) and forwards the file path', () async {
      when(
        () => ds.sendImageMessage(
          conversationId: 'u1_u2',
          myUid: 'u1',
          otherUid: 'u2',
          filePath: '/tmp/img.jpg',
        ),
      ).thenAnswer((_) async {});

      final Either<Failure, void> result = await repo.sendImageMessage(
        conversationId: 'u1_u2',
        myUid: 'u1',
        otherUid: 'u2',
        filePath: '/tmp/img.jpg',
      );

      expect(result, const Right<Failure, void>(null));
      verify(
        () => ds.sendImageMessage(
          conversationId: 'u1_u2',
          myUid: 'u1',
          otherUid: 'u2',
          filePath: '/tmp/img.jpg',
        ),
      ).called(1);
    });

    test('returns Left when datasource throws', () async {
      when(
        () => ds.sendImageMessage(
          conversationId: 'u1_u2',
          myUid: 'u1',
          otherUid: 'u2',
          filePath: any(named: 'filePath'),
        ),
      ).thenThrow(Exception('upload failed'));

      final Either<Failure, void> result = await repo.sendImageMessage(
        conversationId: 'u1_u2',
        myUid: 'u1',
        otherUid: 'u2',
        filePath: '/tmp/img.jpg',
      );

      final Failure? failure = result.fold((Failure f) => f, (_) => null);
      expect(failure, isNotNull);
      expect(failure!.message, contains('upload failed'));
    });
  });
}
