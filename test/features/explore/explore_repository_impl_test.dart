import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/core/models/post.dart';
import 'package:flutter_instagram_clone/features/explore/data/datasources/explore_firebase_datasource.dart';
import 'package:flutter_instagram_clone/features/explore/data/repositories/explore_repository_impl.dart';

class MockExploreDataSource extends Mock implements IExploreDataSource {}

final Post post = Post(
  id: 'p1',
  authorId: 'u1',
  authorUsername: 'yo',
  imageUrl: 'http://img',
  createdAt: DateTime.fromMillisecondsSinceEpoch(0),
);

final AppUser user = AppUser(uid: 'u1', email: 'a@b.c', username: 'yo');

void main() {
  late MockExploreDataSource ds;
  late ExploreRepositoryImpl repo;

  setUp(() {
    ds = MockExploreDataSource();
    repo = ExploreRepositoryImpl(ds);
  });

  group('watchExplorePosts', () {
    test(
      'passes datasource stream through unchanged and forwards limit',
      () async {
        when(
          () => ds.watchExplorePosts(limit: 12),
        ).thenAnswer((_) => Stream<List<Post>>.value(<Post>[post]));

        final List<List<Post>> emitted = await repo
            .watchExplorePosts(limit: 12)
            .toList();

        expect(emitted, <List<Post>>[
          <Post>[post],
        ]);
        verify(() => ds.watchExplorePosts(limit: 12)).called(1);
      },
    );
  });

  group('watchPostsByTag', () {
    test(
      'passes datasource stream through unchanged and forwards tag',
      () async {
        when(
          () => ds.watchPostsByTag(tag: 'sunset'),
        ).thenAnswer((_) => Stream<List<Post>>.value(<Post>[post]));

        final List<List<Post>> emitted = await repo
            .watchPostsByTag(tag: 'sunset')
            .toList();

        expect(emitted, <List<Post>>[
          <Post>[post],
        ]);
        verify(() => ds.watchPostsByTag(tag: 'sunset')).called(1);
      },
    );
  });

  group('searchUsers', () {
    test(
      'returns Right with users from datasource and forwards query',
      () async {
        when(
          () => ds.searchUsers(query: 'al'),
        ).thenAnswer((_) async => <AppUser>[user]);

        final Either<Failure, List<AppUser>> result = await repo.searchUsers(
          query: 'al',
        );

        final List<AppUser>? users = result.fold(
          (_) => null,
          (List<AppUser> u) => u,
        );
        expect(users, <AppUser>[user]);
        verify(() => ds.searchUsers(query: 'al')).called(1);
      },
    );

    test('returns Left(Failure.serverError) when datasource throws', () async {
      when(() => ds.searchUsers(query: 'al')).thenThrow(Exception('boom'));

      final Either<Failure, List<AppUser>> result = await repo.searchUsers(
        query: 'al',
      );

      final Failure? failure = result.fold((Failure f) => f, (_) => null);
      expect(failure, isNotNull);
      expect(failure!.message, contains('boom'));
    });
  });

  group('fetchSuggestedUsers', () {
    test('forwards params and wraps the list', () async {
      when(
        () => ds.fetchSuggestedUsers(myUid: 'me', limit: 12),
      ).thenAnswer((_) async => <AppUser>[]);

      final Either<Failure, List<AppUser>> result = await repo
          .fetchSuggestedUsers(myUid: 'me', limit: 12);

      expect(result.isRight(), isTrue);
      verify(() => ds.fetchSuggestedUsers(myUid: 'me', limit: 12)).called(1);
    });
  });
}
