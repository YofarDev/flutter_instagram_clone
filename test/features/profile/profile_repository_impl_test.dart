import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/core/models/post.dart';
import 'package:flutter_instagram_clone/features/profile/data/datasources/profile_firebase_datasource.dart';
import 'package:flutter_instagram_clone/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_instagram_clone/features/profile/domain/models/user_profile.dart';

class MockProfileDataSource extends Mock implements IProfileDataSource {}

void main() {
  late MockProfileDataSource ds;
  late ProfileRepositoryImpl repo;

  const UserProfile profile = UserProfile(
    uid: 'u1',
    email: 'a@b.c',
    username: 'yo',
  );
  const AppUser followerA = AppUser(uid: 'u2', email: '', username: 'aa');
  const AppUser followerB = AppUser(uid: 'u3', email: '', username: 'bb');
  final Post postA = Post(
    id: 'p1',
    authorId: 'u1',
    authorUsername: 'yo',
    imageUrl: 'http://x/1.jpg',
    createdAt: DateTime(2026, 1, 1),
  );
  final Post postB = Post(
    id: 'p2',
    authorId: 'u1',
    authorUsername: 'yo',
    imageUrl: 'http://x/2.jpg',
    createdAt: DateTime(2026, 1, 2),
  );

  setUp(() {
    ds = MockProfileDataSource();
    repo = ProfileRepositoryImpl(ds);
  });

  group('getProfile', () {
    test('success returns Right(profile)', () async {
      when(() => ds.getProfile(uid: 'u1')).thenAnswer((_) async => profile);

      final Either<Failure, UserProfile> result =
          await repo.getProfile(uid: 'u1');

      expect(result, const Right<Failure, UserProfile>(profile));
    });

    test('datasource throw returns Left(serverError)', () async {
      when(() => ds.getProfile(uid: 'u1'))
          .thenThrow(Exception('firebase down'));

      final Either<Failure, UserProfile> result =
          await repo.getProfile(uid: 'u1');

      expect(
        result.getLeft().toNullable(),
        isA<Failure>().having(
          (Failure f) => f.maybeWhen(
            serverError: (_) => true,
            orElse: () => false,
          ),
          'is server error',
          isTrue,
        ),
      );
    });

    test('StateError maps to bare message', () async {
      when(() => ds.getProfile(uid: 'u1'))
          .thenThrow(StateError('Profile not found'));

      final Either<Failure, UserProfile> result =
          await repo.getProfile(uid: 'u1');

      expect(result.getLeft().toNullable()?.message, 'Profile not found');
    });
  });

  group('stream pass-throughs', () {
    test('watchFollowingIds emits datasource values', () async {
      when(() => ds.watchFollowingIds(uid: 'u1'))
          .thenAnswer((_) => Stream<List<String>>.value(<String>['u2']));

      await expectLater(
        repo.watchFollowingIds(uid: 'u1'),
        emitsInOrder(<List<String>>[
          <String>['u2'],
        ]),
      );
      verify(() => ds.watchFollowingIds(uid: 'u1')).called(1);
    });

    test('watchIsFollowing emits datasource values', () async {
      when(() => ds.watchIsFollowing(uid: 'u1'))
          .thenAnswer((_) => Stream<bool>.value(true));

      await expectLater(repo.watchIsFollowing(uid: 'u1'), emits(true));
      verify(() => ds.watchIsFollowing(uid: 'u1')).called(1);
    });

    test('watchUserPosts forwards uid and limit', () async {
      when(() => ds.watchUserPosts(uid: 'u1', limit: 10)).thenAnswer(
        (_) => Stream<List<Post>>.value(<Post>[postA, postB]),
      );

      await expectLater(
        repo.watchUserPosts(uid: 'u1', limit: 10),
        emitsInOrder(<List<Post>>[
          <Post>[postA, postB],
        ]),
      );
      verify(() => ds.watchUserPosts(uid: 'u1', limit: 10)).called(1);
    });
  });

  group('toggleFollow', () {
    test('success returns Right(null)', () async {
      when(() => ds.toggleFollow(uid: 'u2', currentlyFollowing: false))
          .thenAnswer((_) async {});

      final Either<Failure, void> result =
          await repo.toggleFollow(uid: 'u2', currentlyFollowing: false);

      expect(result, const Right<Failure, void>(null));
    });

    test('throw returns Left(serverError)', () async {
      when(() => ds.toggleFollow(uid: 'u2', currentlyFollowing: true))
          .thenThrow(Exception('boom'));

      final Either<Failure, void> result =
          await repo.toggleFollow(uid: 'u2', currentlyFollowing: true);

      expect(result.isLeft(), isTrue);
    });
  });

  group('fetchFollowers', () {
    test('success returns Right(list)', () async {
      when(() => ds.fetchFollowers(uid: 'u1')).thenAnswer(
        (_) async => <AppUser>[followerA, followerB],
      );

      final Either<Failure, List<AppUser>> result =
          await repo.fetchFollowers(uid: 'u1');

      // ponytail: fpdart Right== is identity-based for List payloads
      expect(result.getRight().toNullable(), <AppUser>[followerA, followerB]);
      expect(result.isLeft(), isFalse);
    });

    test('throw returns Left(serverError)', () async {
      when(() => ds.fetchFollowers(uid: 'u1'))
          .thenThrow(Exception('boom'));

      final Either<Failure, List<AppUser>> result =
          await repo.fetchFollowers(uid: 'u1');

      expect(result.isLeft(), isTrue);
    });
  });

  group('fetchFollowing', () {
    test('success returns Right(list)', () async {
      when(() => ds.fetchFollowing(uid: 'u1')).thenAnswer(
        (_) async => <AppUser>[followerB],
      );

      final Either<Failure, List<AppUser>> result =
          await repo.fetchFollowing(uid: 'u1');

      // ponytail: fpdart Right== is identity-based for List payloads
      expect(result.getRight().toNullable(), <AppUser>[followerB]);
      expect(result.isLeft(), isFalse);
    });
  });
}
