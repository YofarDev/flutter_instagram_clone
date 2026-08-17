import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/features/chat/domain/models/conversation.dart';
import 'package:flutter_instagram_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_instagram_clone/features/chat/presentation/bloc/conversations_cubit.dart';
import 'package:flutter_instagram_clone/features/chat/presentation/bloc/conversations_state.dart';

class MockIChatRepository extends Mock implements IChatRepository {}

final Conversation c1 = Conversation(
  id: 'c1',
  otherUser: AppUser(uid: 'u1', email: 'a@b.c', username: 'alice'),
  lastMessageText: 'hi',
);
final Conversation c2 = Conversation(
  id: 'c2',
  otherUser: AppUser(uid: 'u2', email: 'd@e.f', username: 'bob'),
);

void main() {
  late MockIChatRepository repo;

  setUp(() {
    repo = MockIChatRepository();
  });

  blocTest<ConversationsCubit, ConversationsState>(
    'hydrates conversations from stream',
    build: () {
      when(() => repo.watchConversations(myUid: 'me')).thenAnswer(
        (_) => Stream<List<Conversation>>.value(<Conversation>[c1, c2]),
      );
      return ConversationsCubit(repo, myUid: 'me');
    },
    expect: () => <ConversationsState>[
      ConversationsState(
        status: ConversationsStatus.ready,
        conversations: <Conversation>[c1, c2],
      ),
    ],
  );

  blocTest<ConversationsCubit, ConversationsState>(
    'watch error sets error message',
    build: () {
      final StreamController<List<Conversation>> controller =
          StreamController<List<Conversation>>();
      addTearDown(controller.close);
      when(() => repo.watchConversations(myUid: 'me'))
          .thenAnswer((_) => controller.stream);
      controller.addError(Exception('db down'));
      return ConversationsCubit(repo, myUid: 'me');
    },
    expect: () => <ConversationsState>[
      const ConversationsState(error: 'Failed to load conversations'),
    ],
  );
}
