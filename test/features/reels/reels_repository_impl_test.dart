import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/reels/data/datasources/reels_firebase_datasource.dart';
import 'package:flutter_instagram_clone/features/reels/data/repositories/reels_repository_impl.dart';
import 'package:flutter_instagram_clone/features/reels/domain/models/reel.dart';

class MockReelsDataSource extends Mock implements IReelsDataSource {}

final Reel reel = Reel(
  id: 'r1',
  uid: 'u1',
  authorUsername: 'yo',
  videoUrl: 'http://vid',
  createdAt: DateTime.fromMillisecondsSinceEpoch(0),
);

void main() {
  late MockReelsDataSource ds;
  late ReelsRepositoryImpl repo;

  setUp(() {
    ds = MockReelsDataSource();
    repo = ReelsRepositoryImpl(ds);
  });

  group('watchReels', () {
    test('passes datasource stream through unchanged', () async {
      when(() => ds.watchReels(limit: 10))
          .thenAnswer((_) => Stream<List<Reel>>.value(<Reel>[reel]));

      final List<List<Reel>> emitted = await repo.watchReels(limit: 10).toList();

      expect(emitted, <List<Reel>>[
        <Reel>[reel],
      ]);
      verify(() => ds.watchReels(limit: 10)).called(1);
    });
  });

  group('createReel', () {
    test('returns Right(null) on success', () async {
      when(() => ds.createReel(caption: 'hi', filePath: '/tmp/v.mp4'))
          .thenAnswer((_) async {});

      final Either<Failure, void> result =
          await repo.createReel(caption: 'hi', filePath: '/tmp/v.mp4');

      expect(result, const Right<Failure, void>(null));
    });

    test('returns Left(Failure.serverError) when datasource throws', () async {
      when(() => ds.createReel(caption: 'hi', filePath: '/tmp/v.mp4'))
          .thenThrow(Exception('upload failed'));

      final Either<Failure, void> result =
          await repo.createReel(caption: 'hi', filePath: '/tmp/v.mp4');

      final Failure? failure = result.fold(
        (Failure f) => f,
        (_) => null,
      );
      expect(failure, isNotNull);
      expect(failure!.message, contains('upload failed'));
    });
  });

  group('fetchLikedReelIds', () {
    test('returns Right with the liked ids from datasource', () async {
      when(() => ds.fetchLikedReelIds(reelIds: <String>['r1', 'r2']))
          .thenAnswer((_) async => <String>{'r1'});

      final Either<Failure, Set<String>> result =
          await repo.fetchLikedReelIds(reelIds: <String>['r1', 'r2']);

      final Set<String>? ids = result.fold(
        (_) => null,
        (Set<String> s) => s,
      );
      expect(ids, <String>{'r1'});
    });

    test('returns Left when datasource throws', () async {
      when(() => ds.fetchLikedReelIds(reelIds: <String>['r1']))
          .thenThrow(Exception('reads failed'));

      final Either<Failure, Set<String>> result =
          await repo.fetchLikedReelIds(reelIds: <String>['r1']);

      expect(result.isLeft(), true);
    });
  });

  group('toggleReelLike', () {
    test('returns Right(null) and forwards params on success', () async {
      when(() => ds.toggleReelLike(reelId: 'r1', currentlyLiked: false))
          .thenAnswer((_) async {});

      final Either<Failure, void> result =
          await repo.toggleReelLike(reelId: 'r1', currentlyLiked: false);

      expect(result, const Right<Failure, void>(null));
      verify(() => ds.toggleReelLike(reelId: 'r1', currentlyLiked: false))
          .called(1);
    });

    test('returns Left when datasource throws', () async {
      when(() => ds.toggleReelLike(reelId: 'r1', currentlyLiked: true))
          .thenThrow(Exception('tx failed'));

      final Either<Failure, void> result =
          await repo.toggleReelLike(reelId: 'r1', currentlyLiked: true);

      expect(result.isLeft(), true);
    });
  });
}
