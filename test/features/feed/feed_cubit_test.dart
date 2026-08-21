import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/core/models/post.dart';
import 'package:flutter_instagram_clone/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/feed_cubit.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/feed_state.dart';
import 'package:flutter_instagram_clone/features/profile/domain/repositories/profile_repository.dart';

class MockIFeedRepository extends Mock implements IFeedRepository {}

class MockIProfileRepository extends Mock implements IProfileRepository {}

final Post p1 = Post(
  id: 'p1',
  authorId: 'u1',
  authorUsername: 'yo',
  imageUrls: <String>['http://img/p1'],
  createdAt: DateTime(2026, 1, 1),
  likeCount: 5,
);
final Post p2 = Post(
  id: 'p2',
  authorId: 'u1',
  authorUsername: 'yo',
  imageUrls: <String>['http://img/p2'],
  createdAt: DateTime(2026, 1, 1),
);
final List<Post> manyPosts = List<Post>.generate(
  12,
  (int i) => Post(
    id: 'p$i',
    authorId: 'u1',
    authorUsername: 'yo',
    imageUrls: <String>['http://img/p$i'],
    createdAt: DateTime(2026, 1, 1),
  ),
);
final Post mine = Post(
  id: 'pm',
  authorId: 'me',
  authorUsername: 'me',
  imageUrls: <String>['http://img/pm'],
  createdAt: DateTime(2026, 1, 1),
);
final Post followedPost = Post(
  id: 'pf',
  authorId: 'u2',
  authorUsername: 'followed',
  imageUrls: <String>['http://img/pf'],
  createdAt: DateTime(2026, 1, 1),
);
final Post stranger = Post(
  id: 'ps',
  authorId: 'u9',
  authorUsername: 'stranger',
  imageUrls: <String>['http://img/ps'],
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  late MockIFeedRepository repo;
  late MockIProfileRepository profileRepo;
  late StreamController<List<Post>> postsController;
  late StreamController<List<String>> followingController;
  late Completer<Either<Failure, Set<String>>> likedGate;

  setUp(() {
    repo = MockIFeedRepository();
    profileRepo = MockIProfileRepository();
    likedGate = Completer<Either<Failure, Set<String>>>();
    registerFallbackValue(p1);
    registerFallbackValue(<String>[]);
    // existing fixtures are authored by 'u1' — keep them visible via myUid
    when(
      () => profileRepo.watchFollowingIds(uid: any(named: 'uid')),
    ).thenAnswer((_) => const Stream<List<String>>.empty());
    when(
      () => repo.fetchSavedPostIds(postIds: any(named: 'postIds')),
    ).thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));
  });

  blocTest<FeedCubit, FeedState>(
    'initial load hydrates liked ids',
    build: () {
      when(
        () => repo.watchFeed(limit: any(named: 'limit')),
      ).thenAnswer((_) => Stream<List<Post>>.value(<Post>[p1, p2]));
      when(
        () => repo.fetchLikedPostIds(postIds: any(named: 'postIds')),
      ).thenAnswer(
        (_) async => const Right<Failure, Set<String>>(<String>{'p1'}),
      );
      return FeedCubit(repo, profileRepo, myUid: 'u1');
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
      final List<Either<Failure, Set<String>>> answers =
          <Either<Failure, Set<String>>>[
            const Right<Failure, Set<String>>(<String>{'p1'}),
            const Left<Failure, Set<String>>(
              Failure.serverError(message: 'boom'),
            ),
          ];
      when(
        () => repo.watchFeed(limit: any(named: 'limit')),
      ).thenAnswer((_) => controller.stream);
      when(
        () => repo.fetchLikedPostIds(postIds: any(named: 'postIds')),
      ).thenAnswer((_) async => answers.removeAt(0));
      controller
        ..add(<Post>[p1, p2])
        ..add(<Post>[p1]);
      return FeedCubit(repo, profileRepo, myUid: 'u1');
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
      when(
        () => repo.watchFeed(limit: any(named: 'limit')),
      ).thenAnswer((_) => controller.stream);
      controller.addError(Exception('db down'));
      return FeedCubit(repo, profileRepo, myUid: 'u1');
    },
    expect: () => <FeedState>[FeedState(error: 'Failed to load feed')],
  );

  blocTest<FeedCubit, FeedState>(
    'toggleLike optimistic flip on success',
    build: () {
      when(
        () => repo.watchFeed(limit: any(named: 'limit')),
      ).thenAnswer((_) => const Stream<List<Post>>.empty());
      when(
        () => repo.toggleLike(
          post: any(named: 'post'),
          currentlyLiked: any(named: 'currentlyLiked'),
        ),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      return FeedCubit(repo, profileRepo, myUid: 'u1');
    },
    seed: () =>
        FeedState(status: FeedStatus.ready, posts: <Post>[p1], hasMore: true),
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
      when(
        () => repo.watchFeed(limit: any(named: 'limit')),
      ).thenAnswer((_) => const Stream<List<Post>>.empty());
      when(
        () => repo.toggleLike(
          post: any(named: 'post'),
          currentlyLiked: any(named: 'currentlyLiked'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return FeedCubit(repo, profileRepo, myUid: 'u1');
    },
    seed: () =>
        FeedState(status: FeedStatus.ready, posts: <Post>[p1], hasMore: true),
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
      when(
        () => repo.watchFeed(limit: any(named: 'limit')),
      ).thenAnswer((_) => Stream<List<Post>>.value(manyPosts));
      when(
        () => repo.fetchLikedPostIds(postIds: any(named: 'postIds')),
      ).thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));
      return FeedCubit(repo, profileRepo, myUid: 'u1');
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
      when(
        () => repo.watchFeed(limit: any(named: 'limit')),
      ).thenAnswer((_) => const Stream<List<Post>>.empty());
      return FeedCubit(repo, profileRepo, myUid: 'u1');
    },
    seed: () => FeedState(status: FeedStatus.ready, hasMore: false),
    act: (FeedCubit cubit) => cubit.loadMore(),
    verify: (FeedCubit cubit) {
      verify(() => repo.watchFeed(limit: any(named: 'limit'))).called(1);
    },
    expect: () => const <FeedState>[],
  );

  blocTest<FeedCubit, FeedState>(
    'auto-loadMore when a raw page has zero followed authors',
    build: () {
      final List<Post> strangers = List<Post>.generate(
        10,
        (int i) => Post(
          id: 'x$i',
          authorId: 'u9',
          authorUsername: 'stranger',
          imageUrls: <String>['http://img/x$i'],
          createdAt: DateTime(2026, 1, 1),
        ),
      );
      when(
        () => repo.fetchLikedPostIds(postIds: any(named: 'postIds')),
      ).thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));
      when(
        () => repo.watchFeed(limit: 10),
      ).thenAnswer((_) => Stream<List<Post>>.value(strangers));
      when(
        () => repo.watchFeed(limit: 20),
      ).thenAnswer((_) => Stream<List<Post>>.value(<Post>[...strangers, mine]));
      return FeedCubit(repo, profileRepo, myUid: 'me');
    },
    // page one is all strangers -> empty visible feed triggers loadMore
    // automatically; page two finally contains a visible post
    expect: () => <FeedState>[
      FeedState(status: FeedStatus.ready, posts: <Post>[], hasMore: true),
      FeedState(
        status: FeedStatus.ready,
        posts: <Post>[mine],
        likedIds: const <String>{},
        hasMore: false,
      ),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    'initial load hydrates saved ids alongside liked ids',
    build: () {
      when(
        () => repo.watchFeed(limit: any(named: 'limit')),
      ).thenAnswer((_) => Stream<List<Post>>.value(<Post>[p1]));
      when(
        () => repo.fetchLikedPostIds(postIds: any(named: 'postIds')),
      ).thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));
      when(
        () => repo.fetchSavedPostIds(postIds: any(named: 'postIds')),
      ).thenAnswer(
        (_) async => const Right<Failure, Set<String>>(<String>{'p1'}),
      );
      return FeedCubit(repo, profileRepo, myUid: 'u1');
    },
    expect: () => <FeedState>[
      FeedState(
        status: FeedStatus.ready,
        posts: <Post>[p1],
        savedIds: const <String>{'p1'},
        hasMore: false,
      ),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    'toggleSave optimistic flip on success',
    build: () {
      when(
        () => repo.watchFeed(limit: any(named: 'limit')),
      ).thenAnswer((_) => const Stream<List<Post>>.empty());
      when(
        () => repo.toggleSave(
          post: any(named: 'post'),
          currentlySaved: any(named: 'currentlySaved'),
        ),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      return FeedCubit(repo, profileRepo, myUid: 'u1');
    },
    seed: () =>
        FeedState(status: FeedStatus.ready, posts: <Post>[p1], hasMore: true),
    act: (FeedCubit cubit) => cubit.toggleSave(p1),
    expect: () => <FeedState>[
      FeedState(
        status: FeedStatus.ready,
        posts: <Post>[p1],
        savedIds: const <String>{'p1'},
        hasMore: true,
      ),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    'toggleSave rolls back on failure',
    build: () {
      when(
        () => repo.watchFeed(limit: any(named: 'limit')),
      ).thenAnswer((_) => const Stream<List<Post>>.empty());
      when(
        () => repo.toggleSave(
          post: any(named: 'post'),
          currentlySaved: any(named: 'currentlySaved'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return FeedCubit(repo, profileRepo, myUid: 'u1');
    },
    seed: () => FeedState(
      status: FeedStatus.ready,
      posts: <Post>[p1],
      savedIds: const <String>{'p1'},
      hasMore: true,
    ),
    act: (FeedCubit cubit) => cubit.toggleSave(p1),
    expect: () => <FeedState>[
      FeedState(status: FeedStatus.ready, posts: <Post>[p1], hasMore: true),
      FeedState(
        status: FeedStatus.ready,
        posts: <Post>[p1],
        savedIds: const <String>{'p1'},
        hasMore: true,
        error: 'boom',
      ),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    'loadMore ignored while the previous page hydration is in flight',
    build: () {
      when(
        () => repo.watchFeed(limit: any(named: 'limit')),
      ).thenAnswer((_) => Stream<List<Post>>.value(manyPosts));
      when(
        () => repo.fetchLikedPostIds(postIds: any(named: 'postIds')),
      ).thenAnswer((_) => likedGate.future);
      when(
        () => profileRepo.watchFollowingIds(uid: any(named: 'uid')),
      ).thenAnswer((_) => const Stream<List<String>>.empty());
      return FeedCubit(repo, profileRepo, myUid: 'u1');
    },
    act: (FeedCubit cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.loadMore();
      cubit.loadMore(); // in flight — must be swallowed by the guard
      await Future<void>.delayed(Duration.zero);
      likedGate.complete(const Right<Failure, Set<String>>(<String>{}));
      await Future<void>.delayed(Duration.zero);
    },
    verify: (FeedCubit cubit) {
      verify(() => repo.watchFeed(limit: 20)).called(1);
      verifyNever(() => repo.watchFeed(limit: 30));
    },
    // the stale limit-10 hydration is dropped by the generation guard, so
    // only the final limit-20 emission surfaces
    expect: () => <FeedState>[
      FeedState(status: FeedStatus.ready, posts: manyPosts, hasMore: false),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    'refresh resets to page one and completes once the stream emits',
    build: () {
      when(
        () => repo.watchFeed(limit: any(named: 'limit')),
      ).thenAnswer((_) => Stream<List<Post>>.value(manyPosts));
      when(
        () => repo.fetchLikedPostIds(postIds: any(named: 'postIds')),
      ).thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));
      when(
        () => profileRepo.watchFollowingIds(uid: any(named: 'uid')),
      ).thenAnswer((_) => const Stream<List<String>>.empty());
      return FeedCubit(repo, profileRepo, myUid: 'u1');
    },
    act: (FeedCubit cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.loadMore();
      await Future<void>.delayed(Duration.zero);
      await cubit.refresh();
    },
    verify: (FeedCubit cubit) {
      verifyInOrder(<dynamic Function()>[
        () => repo.watchFeed(limit: 10),
        () => repo.watchFeed(limit: 20),
        () => repo.watchFeed(limit: 10), // back to page one
      ]);
    },
    expect: () => <FeedState>[
      FeedState(status: FeedStatus.ready, posts: manyPosts, hasMore: true),
      FeedState(status: FeedStatus.ready, posts: manyPosts, hasMore: false),
      FeedState(status: FeedStatus.ready, posts: manyPosts, hasMore: true),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    'feed filters to self + followed',
    build: () {
      when(() => repo.watchFeed(limit: any(named: 'limit'))).thenAnswer(
        (_) => Stream<List<Post>>.value(<Post>[mine, followedPost, stranger]),
      );
      when(
        () => repo.fetchLikedPostIds(postIds: any(named: 'postIds')),
      ).thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));
      when(
        () => profileRepo.watchFollowingIds(uid: any(named: 'uid')),
      ).thenAnswer((_) => Stream<List<String>>.value(<String>['u2']));
      return FeedCubit(repo, profileRepo, myUid: 'me');
    },
    expect: () => <FeedState>[
      // stream race: posts may land before following ids arrive — starts
      // narrow, widens; stranger ('u9') never appears in either state
      FeedState(
        status: FeedStatus.ready,
        posts: <Post>[mine],
        likedIds: const <String>{},
        hasMore: false,
      ),
      FeedState(
        status: FeedStatus.ready,
        posts: <Post>[mine, followedPost],
        likedIds: const <String>{},
        hasMore: false,
      ),
    ],
  );

  blocTest<FeedCubit, FeedState>(
    'follow change re-filters live',
    build: () {
      postsController = StreamController<List<Post>>();
      addTearDown(postsController.close);
      followingController = StreamController<List<String>>();
      addTearDown(followingController.close);
      when(
        () => repo.watchFeed(limit: any(named: 'limit')),
      ).thenAnswer((_) => postsController.stream);
      when(
        () => repo.fetchLikedPostIds(postIds: any(named: 'postIds')),
      ).thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));
      when(
        () => profileRepo.watchFollowingIds(uid: any(named: 'uid')),
      ).thenAnswer((_) => followingController.stream);
      return FeedCubit(repo, profileRepo, myUid: 'me');
    },
    act: (FeedCubit cubit) async {
      await Future<void>.delayed(Duration.zero);
      postsController.add(<Post>[
        mine,
        followedPost,
      ]); // following empty -> only mine
      await Future<void>.delayed(Duration.zero);
      followingController.add(<String>['u2']); // widen -> mine + followed
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => <FeedState>[
      FeedState(
        status: FeedStatus.ready,
        posts: <Post>[mine],
        likedIds: const <String>{},
        hasMore: false,
      ),
      FeedState(
        status: FeedStatus.ready,
        posts: <Post>[mine, followedPost],
        likedIds: const <String>{},
        hasMore: false,
      ),
    ],
  );
}
