import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/chat/domain/models/conversation.dart';
import 'package:flutter_instagram_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/features/stories/domain/models/story.dart';
import 'package:flutter_instagram_clone/features/stories/domain/models/story_tray.dart';
import 'package:flutter_instagram_clone/features/stories/domain/repositories/stories_repository.dart';
import 'package:flutter_instagram_clone/features/stories/presentation/bloc/story_viewer_cubit.dart';
import 'package:flutter_instagram_clone/features/stories/presentation/bloc/story_viewer_state.dart';

class MockIStoriesRepository extends Mock implements IStoriesRepository {}

class MockIChatRepository extends Mock implements IChatRepository {}

final Story a1 = Story(
  id: 'a1',
  uid: 'u1',
  authorUsername: 'alice',
  imageUrl: 'http://img/a1',
  createdAt: DateTime(2026, 1, 1, 10),
);
final Story a2 = Story(
  id: 'a2',
  uid: 'u1',
  authorUsername: 'alice',
  imageUrl: 'http://img/a2',
  createdAt: DateTime(2026, 1, 1, 11),
);
final Story b1 = Story(
  id: 'b1',
  uid: 'u2',
  authorUsername: 'bob',
  imageUrl: 'http://img/b1',
  createdAt: DateTime(2026, 1, 1, 12),
);
final List<StoryTray> trays = <StoryTray>[
  StoryTray(uid: 'u1', username: 'alice', stories: <Story>[a1, a2]),
  StoryTray(uid: 'u2', username: 'bob', stories: <Story>[b1]),
];

void main() {
  late MockIStoriesRepository repo;
  late MockIChatRepository chatRepo;

  setUp(() {
    repo = MockIStoriesRepository();
    chatRepo = MockIChatRepository();
    when(
      () => repo.markViewed(storyId: any(named: 'storyId')),
    ).thenAnswer((_) async => const Right<Failure, void>(null));
  });

  blocTest<StoryViewerCubit, StoryViewerState>(
    'init marks current story viewed',
    build: () => StoryViewerCubit(repo, chatRepo, trays: trays, initialTrayIndex: 0, myUid: 'me'),
    act: (StoryViewerCubit cubit) => cubit.init(),
    verify: (_) {
      verify(() => repo.markViewed(storyId: 'a1')).called(1);
    },
    expect: () => <StoryViewerState>[
      StoryViewerState(trays: trays, viewedIds: const <String>{'a1'}),
    ],
  );

  blocTest<StoryViewerCubit, StoryViewerState>(
    'next advances within tray',
    build: () => StoryViewerCubit(repo, chatRepo, trays: trays, initialTrayIndex: 0, myUid: 'me'),
    act: (StoryViewerCubit cubit) => cubit.next(),
    expect: () => <StoryViewerState>[
      StoryViewerState(trays: trays, viewedIds: const <String>{'a1'}),
      StoryViewerState(
        trays: trays,
        storyIndex: 1,
        viewedIds: const <String>{'a1'},
      ),
    ],
  );

  blocTest<StoryViewerCubit, StoryViewerState>(
    'next at tray end wraps to next tray',
    build: () => StoryViewerCubit(repo, chatRepo, trays: trays, initialTrayIndex: 0, myUid: 'me'),
    seed: () => StoryViewerState(trays: trays, storyIndex: 1),
    act: (StoryViewerCubit cubit) => cubit.next(),
    expect: () => <StoryViewerState>[
      StoryViewerState(
        trays: trays,
        storyIndex: 1,
        viewedIds: const <String>{'a2'},
      ),
      StoryViewerState(
        trays: trays,
        trayIndex: 1,
        viewedIds: const <String>{'a2'},
      ),
    ],
  );

  blocTest<StoryViewerCubit, StoryViewerState>(
    'next at very end finishes',
    build: () => StoryViewerCubit(repo, chatRepo, trays: trays, initialTrayIndex: 1, myUid: 'me'),
    act: (StoryViewerCubit cubit) => cubit.next(),
    expect: () => <StoryViewerState>[
      StoryViewerState(
        trays: trays,
        trayIndex: 1,
        viewedIds: const <String>{'b1'},
      ),
      StoryViewerState(
        trays: trays,
        trayIndex: 1,
        viewedIds: const <String>{'b1'},
        finished: true,
      ),
    ],
  );

  blocTest<StoryViewerCubit, StoryViewerState>(
    'previous at tray start wraps to previous tray last story',
    build: () => StoryViewerCubit(repo, chatRepo, trays: trays, initialTrayIndex: 1, myUid: 'me'),
    act: (StoryViewerCubit cubit) => cubit.previous(),
    expect: () => <StoryViewerState>[
      StoryViewerState(trays: trays, storyIndex: 1),
    ],
  );

  blocTest<StoryViewerCubit, StoryViewerState>(
    'previous at very start stays',
    build: () => StoryViewerCubit(repo, chatRepo, trays: trays, initialTrayIndex: 0, myUid: 'me'),
    act: (StoryViewerCubit cubit) => cubit.previous(),
    verify: (_) {
      verifyNever(() => repo.markViewed(storyId: any(named: 'storyId')));
    },
    expect: () => const <StoryViewerState>[],
  );

  blocTest<StoryViewerCubit, StoryViewerState>(
    'viewedIds accumulate across nexts',
    build: () => StoryViewerCubit(repo, chatRepo, trays: trays, initialTrayIndex: 0, myUid: 'me'),
    act: (StoryViewerCubit cubit) {
      cubit.next();
      cubit.next();
    },
    expect: () => <StoryViewerState>[
      StoryViewerState(trays: trays, viewedIds: const <String>{'a1'}),
      StoryViewerState(
        trays: trays,
        storyIndex: 1,
        viewedIds: const <String>{'a1'},
      ),
      StoryViewerState(
        trays: trays,
        storyIndex: 1,
        viewedIds: const <String>{'a1', 'a2'},
      ),
      StoryViewerState(
        trays: trays,
        trayIndex: 1,
        viewedIds: const <String>{'a1', 'a2'},
      ),
    ],
  );

  final Conversation convo = Conversation(
    id: 'c1',
    otherUser: AppUser(uid: 'u1', email: 'a@b.c', username: 'alice'),
  );

  blocTest<StoryViewerCubit, StoryViewerState>(
    'reply sends the story quote to its author',
    build: () {
      when(
        () => chatRepo.getOrCreateConversation(myUid: 'me', otherUid: 'u1'),
      ).thenAnswer((_) async => Right<Failure, Conversation>(convo));
      when(
        () => chatRepo.sendStoryReply(
          conversationId: 'c1',
          myUid: 'me',
          otherUid: 'u1',
          text: 'sick shot',
          storyId: 'a1',
          imageUrl: 'http://img/a1',
        ),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      return StoryViewerCubit(repo, chatRepo, trays: trays, initialTrayIndex: 0, myUid: 'me');
    },
    act: (StoryViewerCubit cubit) => cubit.reply('sick shot'),
    expect: () => <StoryViewerState>[
      StoryViewerState(trays: trays, replySent: true),
    ],
    verify: (_) {
      verify(
        () => chatRepo.sendStoryReply(
          conversationId: 'c1',
          myUid: 'me',
          otherUid: 'u1',
          text: 'sick shot',
          storyId: 'a1',
          imageUrl: 'http://img/a1',
        ),
      ).called(1);
    },
  );

  blocTest<StoryViewerCubit, StoryViewerState>(
    'reply failure surfaces the error, no replySent',
    build: () {
      when(
        () => chatRepo.getOrCreateConversation(myUid: 'me', otherUid: 'u1'),
      ).thenAnswer((_) async => Right<Failure, Conversation>(convo));
      when(
        () => chatRepo.sendStoryReply(
          conversationId: any(named: 'conversationId'),
          myUid: any(named: 'myUid'),
          otherUid: any(named: 'otherUid'),
          text: any(named: 'text'),
          storyId: any(named: 'storyId'),
          imageUrl: any(named: 'imageUrl'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return StoryViewerCubit(repo, chatRepo, trays: trays, initialTrayIndex: 0, myUid: 'me');
    },
    act: (StoryViewerCubit cubit) => cubit.reply('sick shot'),
    expect: () => <StoryViewerState>[
      StoryViewerState(trays: trays, error: 'boom'),
    ],
  );
}
