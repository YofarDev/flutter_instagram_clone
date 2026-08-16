import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/feed/domain/models/post.dart';
import 'package:flutter_instagram_clone/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/feed_cubit.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/feed_state.dart';

class MockIFeedRepository extends Mock implements IFeedRepository {}

final Post p1 = Post(
  id: 'p1',
  authorId: 'u1',
  authorUsername: 'yo',
  imageUrl: 'http://img/p1',
  createdAt: DateTime(2026, 1, 1),
  likeCount: 5,
);
final Post p2 = Post(
  id: 'p2',
  authorId: 'u1',
  authorUsername: 'yo',
  imageUrl: 'http://img/p2',
  createdAt: DateTime(2026, 1, 1),
);
final List<Post> manyPosts = List<Post>.generate(
  12,
  (int i) => Post(
    id: 'p$i',
    authorId: 'u1',
    authorUsername: 'yo',
    imageUrl: 'http://img/p$i',
    createdAt: DateTime(2026, 1, 1),
  ),
);

void main() {
  late MockIFeedRepository repo;

  setUp(() {
    repo = MockIFeedRepository();
    registerFallbackValue(p1);
    registerFallbackValue(<String>[]);
  });

  blocTest<FeedCubit, FeedState>(
    'initial load hydrates liked ids',
    build: () {
      when(() => repo.watchFeed(limit: any(named: 'limit')))
          .thenAnswer((_) => Stream<List<Post>>.value(<Post>[p1, p2]));
      when(() => repo.fetchLikedPostIds(postIds: any(named: 'postIds')))
          .thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{'p1'}));
      return FeedCubit(repo);
    },
    expect: () => <FeedState>[
      FeedState(
        status: FeedStatus.ready,
        posts: <Post>[p1, p2],
        likedIds: const <String>{'p1'},
        hasMore: false,
      ),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    'liked-hydration failure keeps stale likedIds',
    build: () {
      final StreamController<List<Post>> controller =
          StreamController<List<Post>>();
      addTearDown(controller.close);
      final List<Either<Failure, Set<String>>> answers = <
          Either<Failure, Set<String>>>[
        const Right<Failure, Set<String>>(<String>{'p1'}),
        const Left<Failure, Set<String>>(Failure.serverError(message: 'boom')),
      ];
      when(() => repo.watchFeed(limit: any(named: 'limit')))
          .thenAnswer((_) => controller.stream);
      when(() => repo.fetchLikedPostIds(postIds: any(named: 'postIds')))
          .thenAnswer((_) async => answers.removeAt(0));
      controller
        ..add(<Post>[p1, p2])
        ..add(<Post>[p1]);
      return FeedCubit(repo);
    },
    expect: () => <FeedState>[
      FeedState(
        status: FeedStatus.ready,
        posts: <Post>[p1, p2],
        likedIds: const <String>{'p1'},
        hasMore: false,
      ),
      FeedState(
        status: FeedStatus.ready,
        posts: <Post>[p1],
        likedIds: const <String>{'p1'},
        hasMore: false,
      ),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    'watchFeed error sets error message',
    build: () {
      final StreamController<List<Post>> controller =
          StreamController<List<Post>>();
      addTearDown(controller.close);
      when(() => repo.watchFeed(limit: any(named: 'limit')))
          .thenAnswer((_) => controller.stream);
      controller.addError(Exception('db down'));
      return FeedCubit(repo);
    },
    expect: () => <FeedState>[
      FeedState(error: 'Failed to load feed'),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    'toggleLike optimistic flip on success',
    build: () {
      when(() => repo.watchFeed(limit: any(named: 'limit')))
          .thenAnswer((_) => const Stream<List<Post>>.empty());
      when(
        () => repo.toggleLike(
          post: any(named: 'post'),
          currentlyLiked: any(named: 'currentlyLiked'),
        ),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      return FeedCubit(repo);
    },
    seed: () => FeedState(status: FeedStatus.ready, posts: <Post>[p1], hasMore: true),
    act: (FeedCubit cubit) => cubit.toggleLike(p1),
    verify: (FeedCubit cubit) {
      verify(() => repo.toggleLike(post: p1, currentlyLiked: false)).called(1);
    },
    expect: () => <FeedState>[
      FeedState(
        status: FeedStatus.ready,
        posts: <Post>[p1.copyWith(likeCount: 6)],
        likedIds: const <String>{'p1'},
        hasMore: true,
      ),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    'toggleLike rolls back on failure',
    build: () {
      when(() => repo.watchFeed(limit: any(named: 'limit')))
          .thenAnswer((_) => const Stream<List<Post>>.empty());
      when(
        () => repo.toggleLike(
          post: any(named: 'post'),
          currentlyLiked: any(named: 'currentlyLiked'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return FeedCubit(repo);
    },
    seed: () => FeedState(status: FeedStatus.ready, posts: <Post>[p1], hasMore: true),
    act: (FeedCubit cubit) => cubit.toggleLike(p1),
    expect: () => <FeedState>[
      FeedState(
        status: FeedStatus.ready,
        posts: <Post>[p1.copyWith(likeCount: 6)],
        likedIds: const <String>{'p1'},
        hasMore: true,
      ),
      FeedState(
        status: FeedStatus.ready,
        posts: <Post>[p1],
        hasMore: true,
        error: 'boom',
      ),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    'loadMore re-subscribes with grown limit',
    build: () {
      when(() => repo.watchFeed(limit: any(named: 'limit')))
          .thenAnswer((_) => Stream<List<Post>>.value(manyPosts));
      when(() => repo.fetchLikedPostIds(postIds: any(named: 'postIds')))
          .thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));
      return FeedCubit(repo);
    },
    act: (FeedCubit cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.loadMore();
    },
    verify: (FeedCubit cubit) {
      verifyInOrder(<dynamic Function()>[
        () => repo.watchFeed(limit: 10),
        () => repo.watchFeed(limit: 20),
      ]);
    },
    expect: () => <FeedState>[
      FeedState(status: FeedStatus.ready, posts: manyPosts, hasMore: true),
      FeedState(status: FeedStatus.ready, posts: manyPosts, hasMore: false),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    'loadMore blocked when hasMore false',
    build: () {
      when(() => repo.watchFeed(limit: any(named: 'limit')))
          .thenAnswer((_) => const Stream<List<Post>>.empty());
      return FeedCubit(repo);
    },
    seed: () => FeedState(status: FeedStatus.ready, hasMore: false),
    act: (FeedCubit cubit) => cubit.loadMore(),
    verify: (FeedCubit cubit) {
      verify(() => repo.watchFeed(limit: any(named: 'limit'))).called(1);
    },
    expect: () => const <FeedState>[],
  );
}
