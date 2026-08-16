import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/stories/domain/models/story.dart';
import 'package:flutter_instagram_clone/features/stories/domain/models/story_tray.dart';
import 'package:flutter_instagram_clone/features/stories/domain/repositories/stories_repository.dart';
import 'package:flutter_instagram_clone/features/stories/presentation/bloc/stories_cubit.dart';
import 'package:flutter_instagram_clone/features/stories/presentation/bloc/stories_state.dart';

class MockIStoriesRepository extends Mock implements IStoriesRepository {}

final Story mineOld = Story(
  id: 'sm1',
  uid: 'me',
  authorUsername: 'me-old',
  imageUrl: 'http://img/sm1',
  createdAt: DateTime(2026, 1, 1, 10),
);
final Story mineNew = Story(
  id: 'sm2',
  uid: 'me',
  authorUsername: 'me',
  authorAvatarUrl: 'http://img/av-me',
  imageUrl: 'http://img/sm2',
  createdAt: DateTime(2026, 1, 1, 11),
);
final Story aliceOld = Story(
  id: 'sa1',
  uid: 'u1',
  authorUsername: 'alice',
  imageUrl: 'http://img/sa1',
  createdAt: DateTime(2026, 1, 2, 10),
);
final Story aliceNew = Story(
  id: 'sa2',
  uid: 'u1',
  authorUsername: 'alice',
  imageUrl: 'http://img/sa2',
  createdAt: DateTime(2026, 1, 2, 11),
);
final Story bobStory = Story(
  id: 'sb1',
  uid: 'u2',
  authorUsername: 'bob',
  imageUrl: 'http://img/sb1',
  createdAt: DateTime(2026, 1, 1, 9),
);

void main() {
  late MockIStoriesRepository repo;

  setUp(() {
    repo = MockIStoriesRepository();
    registerFallbackValue(<String>[]);
  });

  blocTest<StoriesCubit, StoriesState>(
    'groups by user: own tray first, others by recency, stories asc',
    build: () {
      when(() => repo.watchStories()).thenAnswer(
        (_) => Stream<List<Story>>.value(
          <Story>[mineNew, mineOld, aliceNew, aliceOld, bobStory],
        ),
      );
      when(() => repo.fetchViewedStoryIds(storyIds: any(named: 'storyIds')))
          .thenAnswer(
              (_) async => const Right<Failure, Set<String>>(<String>{'sm1'}));
      return StoriesCubit(repo, myUid: 'me');
    },
    expect: () => <StoriesState>[
      StoriesState(
        status: StoriesStatus.ready,
        trays: <StoryTray>[
          StoryTray(
            uid: 'me',
            username: 'me',
            avatarUrl: 'http://img/av-me',
            stories: <Story>[mineOld, mineNew],
          ),
          StoryTray(uid: 'u1', username: 'alice', stories: <Story>[aliceOld, aliceNew]),
          StoryTray(uid: 'u2', username: 'bob', stories: <Story>[bobStory]),
        ],
        viewedIds: const <String>{'sm1'},
      ),
    ],
  );

  blocTest<StoriesCubit, StoriesState>(
    'no own stories means no own tray',
    build: () {
      when(() => repo.watchStories()).thenAnswer(
        (_) => Stream<List<Story>>.value(<Story>[aliceNew, bobStory]),
      );
      when(() => repo.fetchViewedStoryIds(storyIds: any(named: 'storyIds')))
          .thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));
      return StoriesCubit(repo, myUid: 'me');
    },
    expect: () => <StoriesState>[
      StoriesState(
        status: StoriesStatus.ready,
        trays: <StoryTray>[
          StoryTray(uid: 'u1', username: 'alice', stories: <Story>[aliceNew]),
          StoryTray(uid: 'u2', username: 'bob', stories: <Story>[bobStory]),
        ],
      ),
    ],
  );

  blocTest<StoriesCubit, StoriesState>(
    'viewed-hydration failure keeps stale viewedIds silently',
    build: () {
      final StreamController<List<Story>> controller =
          StreamController<List<Story>>();
      addTearDown(controller.close);
      final List<Either<Failure, Set<String>>> answers = <
          Either<Failure, Set<String>>>[
        const Right<Failure, Set<String>>(<String>{'sm1'}),
        const Left<Failure, Set<String>>(Failure.serverError(message: 'boom')),
      ];
      when(() => repo.watchStories()).thenAnswer((_) => controller.stream);
      when(() => repo.fetchViewedStoryIds(storyIds: any(named: 'storyIds')))
          .thenAnswer((_) async => answers.removeAt(0));
      controller
        ..add(<Story>[mineNew, mineOld, bobStory])
        ..add(<Story>[bobStory]);
      return StoriesCubit(repo, myUid: 'me');
    },
    expect: () => <StoriesState>[
      StoriesState(
        status: StoriesStatus.ready,
        trays: <StoryTray>[
          StoryTray(
            uid: 'me',
            username: 'me',
            avatarUrl: 'http://img/av-me',
            stories: <Story>[mineOld, mineNew],
          ),
          StoryTray(uid: 'u2', username: 'bob', stories: <Story>[bobStory]),
        ],
        viewedIds: const <String>{'sm1'},
      ),
      StoriesState(
        status: StoriesStatus.ready,
        trays: <StoryTray>[StoryTray(uid: 'u2', username: 'bob', stories: <Story>[bobStory])],
        viewedIds: const <String>{'sm1'},
      ),
    ],
  );

  blocTest<StoriesCubit, StoriesState>(
    'watchStories error sets error message',
    build: () {
      final StreamController<List<Story>> controller =
          StreamController<List<Story>>();
      addTearDown(controller.close);
      when(() => repo.watchStories()).thenAnswer((_) => controller.stream);
      controller.addError(Exception('db down'));
      return StoriesCubit(repo, myUid: 'me');
    },
    expect: () => <StoriesState>[
      StoriesState(error: 'Failed to load stories'),
    ],
  );

  test('close cancels stream subscription', () async {
    final StreamController<List<Story>> controller =
        StreamController<List<Story>>();
    addTearDown(controller.close);
    when(() => repo.watchStories()).thenAnswer((_) => controller.stream);
    final StoriesCubit cubit = StoriesCubit(repo, myUid: 'me');
    await cubit.close();
    controller.add(<Story>[mineNew]);
    await Future<void>.delayed(Duration.zero);
    verifyNever(
        () => repo.fetchViewedStoryIds(storyIds: any(named: 'storyIds')));
  });
}
