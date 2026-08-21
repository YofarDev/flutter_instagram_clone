import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/post.dart';
import 'package:flutter_instagram_clone/features/explore/domain/repositories/explore_repository.dart';
import 'package:flutter_instagram_clone/features/explore/presentation/bloc/explore_cubit.dart';
import 'package:flutter_instagram_clone/features/explore/presentation/bloc/explore_state.dart';
import 'package:flutter_instagram_clone/features/profile/domain/repositories/profile_repository.dart';

class MockIExploreRepository extends Mock implements IExploreRepository {}

class MockIProfileRepository extends Mock implements IProfileRepository {}

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
final List<Post> manyPosts = List<Post>.generate(
  12,
  (int i) => Post(
    id: 'p$i',
    authorId: 'u9',
    authorUsername: 'stranger',
    imageUrls: <String>['http://img/p$i'],
    createdAt: DateTime(2026, 1, 1),
  ),
);

void main() {
  late MockIExploreRepository repo;
  late MockIProfileRepository profileRepo;
  late StreamController<List<Post>> postsController;
  late StreamController<List<String>> followingController;

  setUp(() {
    repo = MockIExploreRepository();
    profileRepo = MockIProfileRepository();
    registerFallbackValue(mine);
    registerFallbackValue(<String>[]);
    when(
      () => profileRepo.watchFollowingIds(uid: any(named: 'uid')),
    ).thenAnswer((_) => const Stream<List<String>>.empty());
  });

  blocTest<ExploreCubit, ExploreState>(
    'explore hides self and followed, shows strangers',
    build: () {
      when(() => repo.watchExplorePosts(limit: any(named: 'limit'))).thenAnswer(
        (_) => Stream<List<Post>>.value(<Post>[mine, followedPost, stranger]),
      );
      when(
        () => profileRepo.watchFollowingIds(uid: any(named: 'uid')),
      ).thenAnswer((_) => Stream<List<String>>.value(<String>['u2']));
      return ExploreCubit(repo, profileRepo, myUid: 'me');
    },
    expect: () => <ExploreState>[
      // stream race: posts may land before following ids arrive — starts
      // wide, narrows; self ('me') never appears in either state
      ExploreState(
        status: ExploreStatus.ready,
        posts: <Post>[followedPost, stranger],
        hasMore: false,
      ),
      ExploreState(
        status: ExploreStatus.ready,
        posts: <Post>[stranger],
        hasMore: false,
      ),
    ],
  );

  blocTest<ExploreCubit, ExploreState>(
    'follow change re-filters live',
    build: () {
      postsController = StreamController<List<Post>>();
      addTearDown(postsController.close);
      followingController = StreamController<List<String>>();
      addTearDown(followingController.close);
      when(
        () => repo.watchExplorePosts(limit: any(named: 'limit')),
      ).thenAnswer((_) => postsController.stream);
      when(
        () => profileRepo.watchFollowingIds(uid: any(named: 'uid')),
      ).thenAnswer((_) => followingController.stream);
      return ExploreCubit(repo, profileRepo, myUid: 'me');
    },
    act: (ExploreCubit cubit) async {
      await Future<void>.delayed(Duration.zero);
      // following empty -> followed + stranger visible
      postsController.add(<Post>[mine, followedPost, stranger]);
      await Future<void>.delayed(Duration.zero);
      followingController.add(<String>['u2']); // narrow -> stranger only
      await Future<void>.delayed(Duration.zero);
    },
    expect: () => <ExploreState>[
      ExploreState(
        status: ExploreStatus.ready,
        posts: <Post>[followedPost, stranger],
        hasMore: false,
      ),
      ExploreState(
        status: ExploreStatus.ready,
        posts: <Post>[stranger],
        hasMore: false,
      ),
    ],
  );

  blocTest<ExploreCubit, ExploreState>(
    'loadMore re-subscribes with grown limit',
    build: () {
      when(
        () => repo.watchExplorePosts(limit: any(named: 'limit')),
      ).thenAnswer((_) => Stream<List<Post>>.value(manyPosts));
      return ExploreCubit(repo, profileRepo, myUid: 'me');
    },
    act: (ExploreCubit cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.loadMore();
    },
    verify: (ExploreCubit cubit) {
      verifyInOrder(<dynamic Function()>[
        () => repo.watchExplorePosts(limit: 12),
        () => repo.watchExplorePosts(limit: 24),
      ]);
    },
    expect: () => <ExploreState>[
      ExploreState(
        status: ExploreStatus.ready,
        posts: manyPosts,
        hasMore: true,
      ),
      ExploreState(
        status: ExploreStatus.ready,
        posts: manyPosts,
        hasMore: false,
      ),
    ],
  );

  blocTest<ExploreCubit, ExploreState>(
    'watchExplorePosts error sets error message',
    build: () {
      final StreamController<List<Post>> controller =
          StreamController<List<Post>>();
      addTearDown(controller.close);
      when(
        () => repo.watchExplorePosts(limit: any(named: 'limit')),
      ).thenAnswer((_) => controller.stream);
      controller.addError(Exception('db down'));
      return ExploreCubit(repo, profileRepo, myUid: 'me');
    },
    expect: () => <ExploreState>[ExploreState(error: 'Failed to load explore')],
  );

  blocTest<ExploreCubit, ExploreState>(
    'loadMore blocked when hasMore false',
    build: () {
      when(
        () => repo.watchExplorePosts(limit: any(named: 'limit')),
      ).thenAnswer((_) => const Stream<List<Post>>.empty());
      return ExploreCubit(repo, profileRepo, myUid: 'me');
    },
    seed: () => ExploreState(status: ExploreStatus.ready, hasMore: false),
    act: (ExploreCubit cubit) => cubit.loadMore(),
    verify: (ExploreCubit cubit) {
      verify(
        () => repo.watchExplorePosts(limit: any(named: 'limit')),
      ).called(1);
    },
    expect: () => const <ExploreState>[],
  );
}
