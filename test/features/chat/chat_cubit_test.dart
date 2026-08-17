import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/chat/domain/models/chat_message.dart';
import 'package:flutter_instagram_clone/features/chat/domain/models/conversation.dart';
import 'package:flutter_instagram_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_instagram_clone/features/chat/presentation/bloc/chat_cubit.dart';
import 'package:flutter_instagram_clone/features/chat/presentation/bloc/chat_state.dart';

class MockIChatRepository extends Mock implements IChatRepository {}

final Conversation convo = Conversation(
  id: 'c1',
  otherUser: AppUser(uid: 'u2', email: 'b@c.d', username: 'bob'),
);
final ChatMessage m1 = ChatMessage(
  id: 'm1',
  conversationId: 'c1',
  senderId: 'me',
  text: 'hello',
  createdAt: DateTime(2026, 1, 1, 10),
);
final ChatMessage m2 = ChatMessage(
  id: 'm2',
  conversationId: 'c1',
  senderId: 'u2',
  text: 'hey',
  createdAt: DateTime(2026, 1, 1, 11),
);

ChatCubit buildCubit(MockIChatRepository repo) {
  when(
    () => repo.watchMessages(conversationId: 'c1'),
  ).thenAnswer((_) => const Stream<List<ChatMessage>>.empty());
  return ChatCubit(repo, conversation: convo, myUid: 'me');
}

void main() {
  late MockIChatRepository repo;

  setUp(() {
    repo = MockIChatRepository();
  });

  blocTest<ChatCubit, ChatState>(
    'hydrates messages from stream',
    build: () {
      when(() => repo.watchMessages(conversationId: 'c1')).thenAnswer(
        (_) => Stream<List<ChatMessage>>.value(<ChatMessage>[m1, m2]),
      );
      return ChatCubit(repo, conversation: convo, myUid: 'me');
    },
    expect: () => <ChatState>[
      ChatState(conversation: convo, messages: <ChatMessage>[m1, m2]),
    ],
  );

  blocTest<ChatCubit, ChatState>(
    'empty text never calls sendMessage',
    build: () => buildCubit(repo),
    act: (ChatCubit cubit) => cubit.send('   '),
    verify: (_) {
      verifyNever(
        () => repo.sendMessage(
          conversationId: any(named: 'conversationId'),
          myUid: any(named: 'myUid'),
          otherUid: any(named: 'otherUid'),
          text: any(named: 'text'),
        ),
      );
    },
    expect: () => <ChatState>[],
  );

  blocTest<ChatCubit, ChatState>(
    'send success toggles sending, no optimistic append',
    build: () {
      when(
        () => repo.watchMessages(conversationId: 'c1'),
      ).thenAnswer((_) => const Stream<List<ChatMessage>>.empty());
      when(
        () => repo.sendMessage(
          conversationId: 'c1',
          myUid: 'me',
          otherUid: 'u2',
          text: 'hello',
        ),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      return ChatCubit(repo, conversation: convo, myUid: 'me');
    },
    act: (ChatCubit cubit) => cubit.send(' hello '),
    expect: () => <ChatState>[
      ChatState(conversation: convo, sending: true),
      ChatState(conversation: convo, sending: false),
    ],
  );

  blocTest<ChatCubit, ChatState>(
    'send failure sets error and stops sending',
    build: () {
      when(
        () => repo.watchMessages(conversationId: 'c1'),
      ).thenAnswer((_) => const Stream<List<ChatMessage>>.empty());
      when(
        () => repo.sendMessage(
          conversationId: 'c1',
          myUid: 'me',
          otherUid: 'u2',
          text: 'hello',
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return ChatCubit(repo, conversation: convo, myUid: 'me');
    },
    act: (ChatCubit cubit) => cubit.send('hello'),
    expect: () => <ChatState>[
      ChatState(conversation: convo, sending: true),
      ChatState(conversation: convo, sending: false, error: 'boom'),
    ],
  );
}
