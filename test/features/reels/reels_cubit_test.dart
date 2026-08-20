import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/reels/domain/models/reel.dart';
import 'package:flutter_instagram_clone/features/reels/domain/repositories/reels_repository.dart';
import 'package:flutter_instagram_clone/features/reels/presentation/bloc/reels_cubit.dart';
import 'package:flutter_instagram_clone/features/reels/presentation/bloc/reels_state.dart';

class MockIReelsRepository extends Mock implements IReelsRepository {}

final Reel r1 = Reel(
  id: 'r1',
  uid: 'u1',
  authorUsername: 'yo',
  videoUrl: 'http://vid/r1',
  createdAt: DateTime(2026, 1, 1),
  likeCount: 5,
);
final Reel r2 = Reel(
  id: 'r2',
  uid: 'u1',
  authorUsername: 'yo',
  videoUrl: 'http://vid/r2',
  createdAt: DateTime(2026, 1, 1),
);
final List<Reel> manyReels = List<Reel>.generate(
  12,
  (int i) => Reel(
    id: 'r$i',
    uid: 'u1',
    authorUsername: 'yo',
    videoUrl: 'http://vid/r$i',
    createdAt: DateTime(2026, 1, 1),
  ),
);

void main() {
  late MockIReelsRepository repo;

  setUp(() {
    repo = MockIReelsRepository();
    registerFallbackValue(<String>[]);
  });

  blocTest<ReelsCubit, ReelsState>(
    'initial load hydrates liked ids and sets hasMore',
    build: () {
      when(
        () => repo.watchReels(limit: any(named: 'limit')),
      ).thenAnswer((_) => Stream<List<Reel>>.value(<Reel>[r1, r2]));
      when(
        () => repo.fetchLikedReelIds(reelIds: any(named: 'reelIds')),
      ).thenAnswer(
        (_) async => const Right<Failure, Set<String>>(<String>{'r1'}),
      );
      return ReelsCubit(repo);
    },
    expect: () => <ReelsState>[
      ReelsState(
        status: ReelsStatus.ready,
        reels: <Reel>[r1, r2],
        likedIds: const <String>{'r1'},
        hasMore: false,
      ),
    ],
  );

  blocTest<ReelsCubit, ReelsState>(
    'liked-hydration failure keeps stale likedIds',
    build: () {
      final List<Either<Failure, Set<String>>> answers =
          <Either<Failure, Set<String>>>[
            const Right<Failure, Set<String>>(<String>{'r1'}),
            const Left<Failure, Set<String>>(
              Failure.serverError(message: 'boom'),
            ),
          ];
      when(() => repo.watchReels(limit: any(named: 'limit'))).thenAnswer(
        (_) => Stream<List<Reel>>.fromIterable(<List<Reel>>[
          <Reel>[r1, r2],
          <Reel>[r1],
        ]),
      );
      when(
        () => repo.fetchLikedReelIds(reelIds: any(named: 'reelIds')),
      ).thenAnswer((_) async => answers.removeAt(0));
      return ReelsCubit(repo);
    },
    expect: () => <ReelsState>[
      ReelsState(
        status: ReelsStatus.ready,
        reels: <Reel>[r1, r2],
        likedIds: const <String>{'r1'},
        hasMore: false,
      ),
      ReelsState(
        status: ReelsStatus.ready,
        reels: <Reel>[r1],
        likedIds: const <String>{'r1'},
        hasMore: false,
      ),
    ],
  );

  blocTest<ReelsCubit, ReelsState>(
    'watchReels error sets error message',
    build: () {
      final StreamController<List<Reel>> controller =
          StreamController<List<Reel>>();
      addTearDown(controller.close);
      when(
        () => repo.watchReels(limit: any(named: 'limit')),
      ).thenAnswer((_) => controller.stream);
      controller.addError(Exception('db down'));
      return ReelsCubit(repo);
    },
    expect: () => <ReelsState>[ReelsState(error: 'Failed to load reels')],
  );

  blocTest<ReelsCubit, ReelsState>(
    'toggleReelLike optimistic flip on success',
    build: () {
      when(
        () => repo.watchReels(limit: any(named: 'limit')),
      ).thenAnswer((_) => const Stream<List<Reel>>.empty());
      when(
        () => repo.toggleReelLike(
          reelId: any(named: 'reelId'),
          reelOwnerId: any(named: 'reelOwnerId'),
          currentlyLiked: any(named: 'currentlyLiked'),
        ),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      return ReelsCubit(repo);
    },
    seed: () =>
        ReelsState(status: ReelsStatus.ready, reels: <Reel>[r1], hasMore: true),
    act: (ReelsCubit cubit) => cubit.toggleReelLike(r1),
    verify: (ReelsCubit cubit) {
      verify(
        () => repo.toggleReelLike(
          reelId: 'r1',
          reelOwnerId: any(named: 'reelOwnerId'),
          currentlyLiked: false,
        ),
      ).called(1);
    },
    expect: () => <ReelsState>[
      ReelsState(
        status: ReelsStatus.ready,
        reels: <Reel>[r1.copyWith(likeCount: 6)],
        likedIds: const <String>{'r1'},
        hasMore: true,
      ),
    ],
  );

  blocTest<ReelsCubit, ReelsState>(
    'toggleReelLike rolls back on failure',
    build: () {
      when(
        () => repo.watchReels(limit: any(named: 'limit')),
      ).thenAnswer((_) => const Stream<List<Reel>>.empty());
      when(
        () => repo.toggleReelLike(
          reelId: any(named: 'reelId'),
          reelOwnerId: any(named: 'reelOwnerId'),
          currentlyLiked: any(named: 'currentlyLiked'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return ReelsCubit(repo);
    },
    seed: () =>
        ReelsState(status: ReelsStatus.ready, reels: <Reel>[r1], hasMore: true),
    act: (ReelsCubit cubit) => cubit.toggleReelLike(r1),
    expect: () => <ReelsState>[
      ReelsState(
        status: ReelsStatus.ready,
        reels: <Reel>[r1.copyWith(likeCount: 6)],
        likedIds: const <String>{'r1'},
        hasMore: true,
      ),
      ReelsState(
        status: ReelsStatus.ready,
        reels: <Reel>[r1],
        hasMore: true,
        error: 'boom',
      ),
    ],
  );

  blocTest<ReelsCubit, ReelsState>(
    'loadMore re-subscribes with grown limit',
    build: () {
      when(
        () => repo.watchReels(limit: any(named: 'limit')),
      ).thenAnswer((_) => Stream<List<Reel>>.value(manyReels));
      when(
        () => repo.fetchLikedReelIds(reelIds: any(named: 'reelIds')),
      ).thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));
      return ReelsCubit(repo);
    },
    act: (ReelsCubit cubit) async {
      await Future<void>.delayed(Duration.zero);
      cubit.loadMore();
    },
    verify: (ReelsCubit cubit) {
      verifyInOrder(<dynamic Function()>[
        () => repo.watchReels(limit: 10),
        () => repo.watchReels(limit: 20),
      ]);
    },
    expect: () => <ReelsState>[
      ReelsState(status: ReelsStatus.ready, reels: manyReels, hasMore: true),
      ReelsState(status: ReelsStatus.ready, reels: manyReels, hasMore: false),
    ],
  );

  blocTest<ReelsCubit, ReelsState>(
    'loadMore blocked when hasMore false',
    build: () {
      when(
        () => repo.watchReels(limit: any(named: 'limit')),
      ).thenAnswer((_) => const Stream<List<Reel>>.empty());
      return ReelsCubit(repo);
    },
    seed: () => ReelsState(status: ReelsStatus.ready, hasMore: false),
    act: (ReelsCubit cubit) => cubit.loadMore(),
    verify: (ReelsCubit cubit) {
      verify(() => repo.watchReels(limit: any(named: 'limit'))).called(1);
    },
    expect: () => const <ReelsState>[],
  );
}
