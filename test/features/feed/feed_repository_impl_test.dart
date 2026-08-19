import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/feed/data/datasources/feed_firebase_datasource.dart';
import 'package:flutter_instagram_clone/features/feed/data/repositories/feed_repository_impl.dart';
import 'package:flutter_instagram_clone/features/feed/domain/models/comment.dart';
import 'package:flutter_instagram_clone/core/models/post.dart';

class MockFeedDataSource extends Mock implements IFeedDataSource {}

final Post post = Post(
  id: 'p1',
  authorId: 'u1',
  authorUsername: 'yo',
  imageUrl: 'http://img',
  createdAt: DateTime.fromMillisecondsSinceEpoch(0),
);

final Comment comment = Comment(
  id: 'c1',
  postId: 'p1',
  authorId: 'u2',
  authorUsername: 'yo2',
  text: 'nice',
  createdAt: DateTime.fromMillisecondsSinceEpoch(0),
);

void main() {
  late MockFeedDataSource ds;
  late FeedRepositoryImpl repo;

  setUp(() {
    ds = MockFeedDataSource();
    repo = FeedRepositoryImpl(ds);
  });

  group('watchFeed', () {
    test('passes datasource stream through unchanged', () async {
      when(
        () => ds.watchFeed(limit: 10),
      ).thenAnswer((_) => Stream<List<Post>>.value(<Post>[post]));

      final List<List<Post>> emitted = await repo.watchFeed(limit: 10).toList();

      expect(emitted, <List<Post>>[
        <Post>[post],
      ]);
      verify(() => ds.watchFeed(limit: 10)).called(1);
    });
  });

  group('createPost', () {
    test('returns Right(null) on success', () async {
      when(
        () => ds.createPost(caption: 'cap', filePath: '/tmp/f.jpg'),
      ).thenAnswer((_) async {});

      final Either<Failure, void> result = await repo.createPost(
        caption: 'cap',
        filePath: '/tmp/f.jpg',
      );

      expect(result, const Right<Failure, void>(null));
    });

    test('returns Left(Failure.serverError) when datasource throws', () async {
      when(
        () => ds.createPost(caption: 'cap', filePath: '/tmp/f.jpg'),
      ).thenThrow(Exception('boom'));

      final Either<Failure, void> result = await repo.createPost(
        caption: 'cap',
        filePath: '/tmp/f.jpg',
      );

      final Failure? failure = result.fold((Failure f) => f, (_) => null);
      expect(failure, isNotNull);
      expect(failure!.message, contains('boom'));
    });
  });

  group('fetchLikedPostIds', () {
    test('returns Right with the liked ids from datasource', () async {
      when(
        () => ds.fetchLikedPostIds(postIds: <String>['p1', 'p2']),
      ).thenAnswer((_) async => <String>{'p1'});

      final Either<Failure, Set<String>> result = await repo.fetchLikedPostIds(
        postIds: <String>['p1', 'p2'],
      );

      final Set<String>? ids = result.fold((_) => null, (Set<String> s) => s);
      expect(ids, <String>{'p1'});
    });

    test('returns Left when datasource throws', () async {
      when(
        () => ds.fetchLikedPostIds(postIds: <String>['p1']),
      ).thenThrow(Exception('reads failed'));

      final Either<Failure, Set<String>> result = await repo.fetchLikedPostIds(
        postIds: <String>['p1'],
      );

      expect(result.isLeft(), true);
    });
  });

  group('toggleLike', () {
    test('returns Right(null) and passes post.id + currentlyLiked', () async {
      when(
        () => ds.toggleLike(
          postId: 'p1',
          postOwnerId: 'u1',
          postImageUrl: 'http://img',
          currentlyLiked: false,
        ),
      ).thenAnswer((_) async {});

      final Either<Failure, void> result = await repo.toggleLike(
        post: post,
        currentlyLiked: false,
      );

      expect(result, const Right<Failure, void>(null));
      verify(
        () => ds.toggleLike(
          postId: 'p1',
          postOwnerId: 'u1',
          postImageUrl: 'http://img',
          currentlyLiked: false,
        ),
      ).called(1);
    });

    test('returns Left when datasource throws', () async {
      when(
        () => ds.toggleLike(
          postId: 'p1',
          postOwnerId: 'u1',
          postImageUrl: 'http://img',
          currentlyLiked: true,
        ),
      ).thenThrow(Exception('tx failed'));

      final Either<Failure, void> result = await repo.toggleLike(
        post: post,
        currentlyLiked: true,
      );

      final Failure? failure = result.fold((Failure f) => f, (_) => null);
      expect(failure, isNotNull);
      expect(failure!.message, contains('tx failed'));
    });
  });

  group('getPostById', () {
    test('returns Right with post on success', () async {
      when(() => ds.getPostById(postId: 'p1')).thenAnswer((_) async => post);

      final Either<Failure, Post> result = await repo.getPostById(postId: 'p1');

      expect(result, Right<Failure, Post>(post));
    });

    test('returns Left with clean message when post missing', () async {
      when(
        () => ds.getPostById(postId: 'p1'),
      ).thenThrow(StateError('Post not found'));

      final Either<Failure, Post> result = await repo.getPostById(postId: 'p1');

      final Failure? failure = result.fold((Failure f) => f, (_) => null);
      expect(failure, isNotNull);
      expect(failure!.message, 'Post not found');
    });
  });

  group('watchComments', () {
    test('passes datasource stream through unchanged', () async {
      when(
        () => ds.watchComments(postId: 'p1'),
      ).thenAnswer((_) => Stream<List<Comment>>.value(<Comment>[comment]));

      final List<List<Comment>> emitted = await repo
          .watchComments(postId: 'p1')
          .toList();

      expect(emitted, <List<Comment>>[
        <Comment>[comment],
      ]);
      verify(() => ds.watchComments(postId: 'p1')).called(1);
    });
  });

  group('addComment', () {
    test('returns Right(null) on success', () async {
      when(
        () => ds.addComment(postId: 'p1', postOwnerId: 'u1', text: 'nice'),
      ).thenAnswer((_) async {});

      final Either<Failure, void> result = await repo.addComment(
        postId: 'p1',
        postOwnerId: 'u1',
        text: 'nice',
      );

      expect(result, const Right<Failure, void>(null));
    });

    test('returns Left when datasource throws', () async {
      when(
        () => ds.addComment(postId: 'p1', postOwnerId: 'u1', text: 'nice'),
      ).thenThrow(Exception('nope'));

      final Either<Failure, void> result = await repo.addComment(
        postId: 'p1',
        postOwnerId: 'u1',
        text: 'nice',
      );

      expect(result.isLeft(), true);
    });
  });

  group('saved posts', () {
    test('toggleSave forwards post id and current state', () async {
      when(
        () => ds.toggleSave(
          postId: any(named: 'postId'),
          currentlySaved: any(named: 'currentlySaved'),
        ),
      ).thenAnswer((_) async {});

      final Either<Failure, void> result = await repo.toggleSave(
        post: post,
        currentlySaved: true,
      );

      expect(result.isRight(), isTrue);
      verify(() => ds.toggleSave(postId: 'p1', currentlySaved: true)).called(1);
    });

    test('toggleSave maps datasource throw to Left', () async {
      when(
        () => ds.toggleSave(
          postId: any(named: 'postId'),
          currentlySaved: any(named: 'currentlySaved'),
        ),
      ).thenThrow(Exception('boom'));

      final Either<Failure, void> result = await repo.toggleSave(
        post: post,
        currentlySaved: false,
      );

      expect(result.isLeft(), isTrue);
    });

    test('fetchSavedPostIds wraps datasource result', () async {
      when(
        () => ds.fetchSavedPostIds(postIds: any(named: 'postIds')),
      ).thenAnswer((_) async => const <String>{'p1'});

      final Either<Failure, Set<String>> result = await repo.fetchSavedPostIds(
        postIds: const <String>['p1'],
      );

      expect(result, const Right<Failure, Set<String>>(<String>{'p1'}));
      verify(
        () => ds.fetchSavedPostIds(postIds: const <String>['p1']),
      ).called(1);
    });
  });
}
