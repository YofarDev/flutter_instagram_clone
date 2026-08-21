import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/core/models/post.dart';
import 'package:flutter_instagram_clone/features/profile/domain/models/user_profile.dart';
import 'package:flutter_instagram_clone/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_instagram_clone/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:flutter_instagram_clone/features/profile/presentation/bloc/profile_state.dart';

class MockIProfileRepository extends Mock implements IProfileRepository {}

final UserProfile profile = UserProfile(
  uid: 'u2',
  email: 't@x.io',
  username: 'target',
  followerCount: 3,
);

final Post p1 = Post(
  id: 'p1',
  authorId: 'u2',
  authorUsername: 'target',
  imageUrls: <String>['http://img/p1'],
  createdAt: DateTime(2026, 1, 1),
);
final Post p2 = Post(
  id: 'p2',
  authorId: 'u2',
  authorUsername: 'target',
  imageUrls: <String>['http://img/p2'],
  createdAt: DateTime(2026, 1, 1),
);
final List<Post> posts = <Post>[p1, p2];
final List<Post> manyPosts = List<Post>.generate(
  12,
  (int i) => Post(
    id: 'p$i',
    authorId: 'u2',
    authorUsername: 'target',
    imageUrls: <String>['http://img/p$i'],
    createdAt: DateTime(2026, 1, 1),
  ),
);

Stream<T> delayed<T>(Duration delay, T value) =>
    Future<T>.delayed(delay, () => value).asStream();

void main() {
  late MockIProfileRepository repo;

  setUp(() {
    repo = MockIProfileRepository();
    when(
      () => repo.watchSavedPosts(uid: any(named: 'uid')),
    ).thenAnswer((_) => const Stream<List<Post>>.empty());
  });

  void stubIdleProfile() {
    when(
      () => repo.getProfile(uid: any(named: 'uid')),
    ).thenAnswer((_) => Completer<Either<Failure, UserProfile>>().future);
    when(
      () => repo.watchUserPosts(
        uid: any(named: 'uid'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => const Stream<List<Post>>.empty());
    when(
      () => repo.watchIsFollowing(uid: any(named: 'uid')),
    ).thenAnswer((_) => const Stream<bool>.empty());
    when(
      () => repo.watchSavedPosts(uid: any(named: 'uid')),
    ).thenAnswer((_) => const Stream<List<Post>>.empty());
  }

  test('own profile hydrates saved posts live', () async {
    when(
      () => repo.getProfile(uid: 'u2'),
    ).thenAnswer((_) async => Right<Failure, UserProfile>(profile));
    when(
      () => repo.watchUserPosts(
        uid: 'u2',
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => const Stream<List<Post>>.empty());
    when(
      () => repo.watchSavedPosts(uid: 'u2'),
    ).thenAnswer((_) => Stream<List<Post>>.value(<Post>[p1]));

    final ProfileCubit cubit = ProfileCubit(repo, uid: 'u2', isMe: true);
    addTearDown(cubit.close);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(cubit.state.savedPosts, <Post>[p1]);
    expect(cubit.state.savedLoading, isFalse);
  });

  blocTest<ProfileCubit, ProfileState>(
    'ctor hydrates posts, following, then profile',
    wait: const Duration(milliseconds: 200),
    build: () {
      when(() => repo.getProfile(uid: 'u2')).thenAnswer(
        (_) => Future<Either<Failure, UserProfile>>.delayed(
          const Duration(milliseconds: 30),
          () => Right<Failure, UserProfile>(profile),
        ),
      );
      when(
        () => repo.watchUserPosts(
          uid: 'u2',
          limit: any(named: 'limit'),
        ),
      ).thenAnswer(
        (_) => delayed<List<Post>>(const Duration(milliseconds: 10), posts),
      );
      when(() => repo.watchIsFollowing(uid: 'u2')).thenAnswer(
        (_) => delayed<bool>(const Duration(milliseconds: 20), true),
      );
      return ProfileCubit(repo, uid: 'u2', isMe: false);
    },
    expect: () => <ProfileState>[
      ProfileState(status: ProfileStatus.ready, posts: posts, hasMore: false),
      ProfileState(
        status: ProfileStatus.ready,
        posts: posts,
        isFollowing: true,
        hasMore: false,
      ),
      ProfileState(
        status: ProfileStatus.ready,
        posts: posts,
        isFollowing: true,
        profile: profile,
        hasMore: false,
      ),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'toggleFollow optimistic flip then rollback on failure (3->4->3)',
    build: () {
      stubIdleProfile();
      when(
        () => repo.toggleFollow(
          uid: any(named: 'uid'),
          currentlyFollowing: any(named: 'currentlyFollowing'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return ProfileCubit(repo, uid: 'u2', isMe: false);
    },
    seed: () => ProfileState(
      status: ProfileStatus.ready,
      profile: profile,
      isFollowing: false,
      hasMore: false,
    ),
    act: (ProfileCubit cubit) => cubit.toggleFollow(),
    verify: (ProfileCubit cubit) {
      verify(
        () => repo.toggleFollow(uid: 'u2', currentlyFollowing: false),
      ).called(1);
    },
    expect: () => <ProfileState>[
      ProfileState(
        status: ProfileStatus.ready,
        profile: profile.copyWith(followerCount: 4),
        isFollowing: true,
        hasMore: false,
      ),
      ProfileState(
        status: ProfileStatus.ready,
        profile: profile,
        isFollowing: false,
        hasMore: false,
        error: 'boom',
      ),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'toggleFollow is a no-op on own profile',
    build: () {
      stubIdleProfile();
      return ProfileCubit(repo, uid: 'u2', isMe: true);
    },
    seed: () => ProfileState(
      status: ProfileStatus.ready,
      profile: profile,
      hasMore: false,
    ),
    act: (ProfileCubit cubit) => cubit.toggleFollow(),
    verify: (ProfileCubit cubit) {
      verifyNever(
        () => repo.toggleFollow(
          uid: any(named: 'uid'),
          currentlyFollowing: any(named: 'currentlyFollowing'),
        ),
      );
    },
    expect: () => const <ProfileState>[],
  );

  blocTest<ProfileCubit, ProfileState>(
    'loadMore re-subscribes with grown limit',
    build: () {
      when(
        () => repo.getProfile(uid: any(named: 'uid')),
      ).thenAnswer((_) => Completer<Either<Failure, UserProfile>>().future);
      when(
        () => repo.watchUserPosts(
          uid: 'u2',
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => Stream<List<Post>>.value(manyPosts));
      return ProfileCubit(repo, uid: 'u2', isMe: true);
    },
    act: (ProfileCubit cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.loadMore();
    },
    verify: (ProfileCubit cubit) {
      verifyInOrder(<dynamic Function()>[
        () => repo.watchUserPosts(uid: 'u2', limit: 12),
        () => repo.watchUserPosts(uid: 'u2', limit: 24),
      ]);
    },
    expect: () => <ProfileState>[
      ProfileState(
        status: ProfileStatus.ready,
        posts: manyPosts,
        hasMore: true,
        isMe: true,
      ),
      ProfileState(
        status: ProfileStatus.ready,
        posts: manyPosts,
        hasMore: false,
        isMe: true,
      ),
    ],
  );

  blocTest<ProfileCubit, ProfileState>(
    'posts stream error sets error message',
    build: () {
      when(
        () => repo.getProfile(uid: any(named: 'uid')),
      ).thenAnswer((_) => Completer<Either<Failure, UserProfile>>().future);
      final StreamController<List<Post>> controller =
          StreamController<List<Post>>();
      addTearDown(controller.close);
      when(
        () => repo.watchUserPosts(
          uid: any(named: 'uid'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) => controller.stream);
      controller.addError(Exception('db down'));
      return ProfileCubit(repo, uid: 'u2', isMe: true);
    },
    expect: () => <ProfileState>[
      ProfileState(error: 'Failed to load posts', isMe: true),
    ],
  );
}
