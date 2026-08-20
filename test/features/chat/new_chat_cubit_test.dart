import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/chat/domain/models/conversation.dart';
import 'package:flutter_instagram_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_instagram_clone/features/chat/presentation/bloc/new_chat_cubit.dart';
import 'package:flutter_instagram_clone/features/chat/presentation/bloc/new_chat_state.dart';
import 'package:flutter_instagram_clone/features/explore/domain/repositories/explore_repository.dart';

class MockIChatRepository extends Mock implements IChatRepository {}

class MockIExploreRepository extends Mock implements IExploreRepository {}

final AppUser user = AppUser(uid: 'u1', email: 'a@b.c', username: 'alice');
final Conversation convo = Conversation(id: 'c1', otherUser: user);

void main() {
  late MockIChatRepository chatRepo;
  late MockIExploreRepository exploreRepo;

  setUp(() {
    chatRepo = MockIChatRepository();
    exploreRepo = MockIExploreRepository();
    when(
      () => exploreRepo.fetchSuggestedUsers(
        myUid: any(named: 'myUid'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => Completer<Either<Failure, List<AppUser>>>().future);
  });

  blocTest<NewChatCubit, NewChatState>(
    'debounces rapid keystrokes into a single search',
    build: () {
      when(
        () => exploreRepo.searchUsers(query: 'al'),
      ).thenAnswer((_) async => Right<Failure, List<AppUser>>(<AppUser>[user]));
      return NewChatCubit(exploreRepo, chatRepo, myUid: 'me');
    },
    act: (NewChatCubit cubit) {
      cubit.queryChanged('a');
      cubit.queryChanged('al');
    },
    wait: const Duration(milliseconds: 400),
    verify: (_) {
      verify(() => exploreRepo.searchUsers(query: 'al')).called(1);
      verifyNever(() => exploreRepo.searchUsers(query: 'a'));
    },
    expect: () => <NewChatState>[
      const NewChatState(query: 'a'),
      const NewChatState(query: 'al'),
      const NewChatState(query: 'al', searching: true),
      NewChatState(query: 'al', users: <AppUser>[user], searching: false),
    ],
  );

  blocTest<NewChatCubit, NewChatState>(
    'search failure sets error',
    build: () {
      when(() => exploreRepo.searchUsers(query: 'al')).thenAnswer(
        (_) async => const Left<Failure, List<AppUser>>(
          Failure.serverError(message: 'boom'),
        ),
      );
      return NewChatCubit(exploreRepo, chatRepo, myUid: 'me');
    },
    act: (NewChatCubit cubit) => cubit.queryChanged('al'),
    wait: const Duration(milliseconds: 400),
    expect: () => const <NewChatState>[
      NewChatState(query: 'al'),
      NewChatState(query: 'al', searching: true),
      NewChatState(query: 'al', searching: false, error: 'boom'),
    ],
  );

  blocTest<NewChatCubit, NewChatState>(
    'startConversation success emits opened, failure sets error',
    build: () {
      final List<Either<Failure, Conversation>> answers =
          <Either<Failure, Conversation>>[
            Right<Failure, Conversation>(convo),
            const Left<Failure, Conversation>(
              Failure.serverError(message: 'boom'),
            ),
          ];
      when(
        () => chatRepo.getOrCreateConversation(myUid: 'me', otherUid: 'u1'),
      ).thenAnswer((_) async => answers.removeAt(0));
      return NewChatCubit(exploreRepo, chatRepo, myUid: 'me');
    },
    act: (NewChatCubit cubit) async {
      await cubit.startConversation(user);
      await cubit.startConversation(user);
    },
    expect: () => <NewChatState>[
      const NewChatState(opening: true),
      NewChatState(opened: convo),
      NewChatState(opening: true, opened: convo),
      NewChatState(opened: convo, error: 'boom'),
    ],
  );

  blocTest<NewChatCubit, NewChatState>(
    'ctor loads suggestions once ready',
    build: () {
      when(
        () => exploreRepo.fetchSuggestedUsers(myUid: 'me', limit: 12),
      ).thenAnswer(
        (_) async => Right<Failure, List<AppUser>>(<AppUser>[user]),
      );
      return NewChatCubit(exploreRepo, chatRepo, myUid: 'me');
    },
    expect: () => <NewChatState>[
      NewChatState(suggestions: <AppUser>[user], suggestionsLoading: false),
    ],
  );

  blocTest<NewChatCubit, NewChatState>(
    'suggestion failure falls back to the empty state silently',
    build: () {
      when(
        () => exploreRepo.fetchSuggestedUsers(
          myUid: any(named: 'myUid'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) async => const Left<Failure, List<AppUser>>(
          Failure.serverError(message: 'boom'),
        ),
      );
      return NewChatCubit(exploreRepo, chatRepo, myUid: 'me');
    },
    expect: () => const <NewChatState>[NewChatState(suggestionsLoading: false)],
  );
}
