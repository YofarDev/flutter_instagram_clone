import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/stories/data/datasources/stories_firebase_datasource.dart';
import 'package:flutter_instagram_clone/features/stories/data/repositories/stories_repository_impl.dart';
import 'package:flutter_instagram_clone/features/stories/domain/models/story.dart';

class MockStoriesDataSource extends Mock implements IStoriesDataSource {}

final Story story = Story(
  id: 's1',
  uid: 'u1',
  authorUsername: 'yo',
  imageUrl: 'http://img',
  createdAt: DateTime.fromMillisecondsSinceEpoch(0),
);

void main() {
  late MockStoriesDataSource ds;
  late StoriesRepositoryImpl repo;

  setUp(() {
    ds = MockStoriesDataSource();
    repo = StoriesRepositoryImpl(ds);
  });

  group('watchStories', () {
    test('passes datasource stream through unchanged', () async {
      when(() => ds.watchStories())
          .thenAnswer((_) => Stream<List<Story>>.value(<Story>[story]));

      final List<List<Story>> emitted = await repo.watchStories().toList();

      expect(emitted, <List<Story>>[
        <Story>[story],
      ]);
      verify(() => ds.watchStories()).called(1);
    });
  });

  group('createStory', () {
    test('returns Right(null) on success', () async {
      when(() => ds.createStory(filePath: '/tmp/s.jpg'))
          .thenAnswer((_) async {});

      final Either<Failure, void> result =
          await repo.createStory(filePath: '/tmp/s.jpg');

      expect(result, const Right<Failure, void>(null));
    });

    test('returns Left(Failure.serverError) when datasource throws', () async {
      when(() => ds.createStory(filePath: '/tmp/s.jpg'))
          .thenThrow(Exception('upload failed'));

      final Either<Failure, void> result =
          await repo.createStory(filePath: '/tmp/s.jpg');

      final Failure? failure = result.fold(
        (Failure f) => f,
        (_) => null,
      );
      expect(failure, isNotNull);
      expect(failure!.message, contains('upload failed'));
    });
  });

  group('fetchViewedStoryIds', () {
    test('returns Right with the viewed ids from datasource', () async {
      when(() => ds.fetchViewedStoryIds(storyIds: <String>['s1', 's2']))
          .thenAnswer((_) async => <String>{'s1'});

      final Either<Failure, Set<String>> result =
          await repo.fetchViewedStoryIds(storyIds: <String>['s1', 's2']);

      final Set<String>? ids = result.fold(
        (_) => null,
        (Set<String> s) => s,
      );
      expect(ids, <String>{'s1'});
    });

    test('returns Left when datasource throws', () async {
      when(() => ds.fetchViewedStoryIds(storyIds: <String>['s1']))
          .thenThrow(Exception('reads failed'));

      final Either<Failure, Set<String>> result =
          await repo.fetchViewedStoryIds(storyIds: <String>['s1']);

      expect(result.isLeft(), true);
    });
  });

  group('markViewed', () {
    test('returns Right(null) on success', () async {
      when(() => ds.markViewed(storyId: 's1')).thenAnswer((_) async {});

      final Either<Failure, void> result = await repo.markViewed(storyId: 's1');

      expect(result, const Right<Failure, void>(null));
    });

    test('returns Left when datasource throws', () async {
      when(() => ds.markViewed(storyId: 's1')).thenThrow(Exception('nope'));

      final Either<Failure, void> result = await repo.markViewed(storyId: 's1');

      expect(result.isLeft(), true);
    });
  });
}
