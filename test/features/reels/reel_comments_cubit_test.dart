import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/comment.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/reels/domain/models/reel.dart';
import 'package:flutter_instagram_clone/features/reels/domain/repositories/reels_repository.dart';
import 'package:flutter_instagram_clone/features/reels/presentation/bloc/reel_comments_cubit.dart';
import 'package:flutter_instagram_clone/features/reels/presentation/bloc/reel_comments_state.dart';

class MockIReelsRepository extends Mock implements IReelsRepository {}

final Reel r1 = Reel(
  id: 'r1',
  uid: 'u1',
  authorUsername: 'yo',
  videoUrl: 'http://v/1',
  createdAt: DateTime(2026, 1, 1),
);

final Comment c1 = Comment(
  id: 'c1',
  postId: 'r1',
  authorId: 'u2',
  authorUsername: 'ma',
  text: 'nice',
  createdAt: DateTime(2026, 1, 2),
);

void main() {
  late MockIReelsRepository repo;

  setUp(() {
    repo = MockIReelsRepository();
    when(
      () => repo.watchReelComments(reelId: 'r1'),
    ).thenAnswer((_) => const Stream<List<Comment>>.empty());
  });

  blocTest<ReelCommentsCubit, ReelCommentsState>(
    'hydrates comments from the live stream',
    build: () {
      when(
        () => repo.watchReelComments(reelId: 'r1'),
      ).thenAnswer((_) => Stream<List<Comment>>.value(<Comment>[c1]));
      return ReelCommentsCubit(repo, reel: r1);
    },
    expect: () => <ReelCommentsState>[
      ReelCommentsState(
        status: ReelCommentsStatus.ready,
        comments: <Comment>[c1],
      ),
    ],
  );

  blocTest<ReelCommentsCubit, ReelCommentsState>(
    'stream error surfaces an error message',
    build: () {
      when(
        () => repo.watchReelComments(reelId: 'r1'),
      ).thenAnswer((_) => Stream<List<Comment>>.error(Exception('db down')));
      return ReelCommentsCubit(repo, reel: r1);
    },
    expect: () => const <ReelCommentsState>[
      ReelCommentsState(error: 'Failed to load comments'),
    ],
  );

  blocTest<ReelCommentsCubit, ReelCommentsState>(
    'addComment sends trimmed text and stops sending',
    build: () {
      when(
        () => repo.addReelComment(reelId: 'r1', reelOwnerId: 'u1', text: 'hey'),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      return ReelCommentsCubit(repo, reel: r1);
    },
    act: (ReelCommentsCubit cubit) => cubit.addComment(' hey '),
    verify: (_) {
      verify(
        () => repo.addReelComment(reelId: 'r1', reelOwnerId: 'u1', text: 'hey'),
      ).called(1);
    },
    expect: () => const <ReelCommentsState>[
      ReelCommentsState(sending: true),
      ReelCommentsState(),
    ],
  );

  blocTest<ReelCommentsCubit, ReelCommentsState>(
    'blank addComment never calls the repository',
    build: () => ReelCommentsCubit(repo, reel: r1),
    act: (ReelCommentsCubit cubit) => cubit.addComment('   '),
    verify: (_) {
      verifyNever(
        () => repo.addReelComment(
          reelId: any(named: 'reelId'),
          reelOwnerId: any(named: 'reelOwnerId'),
          text: any(named: 'text'),
        ),
      );
    },
    expect: () => const <ReelCommentsState>[],
  );

  blocTest<ReelCommentsCubit, ReelCommentsState>(
    'addComment failure sets error',
    build: () {
      when(
        () => repo.addReelComment(
          reelId: any(named: 'reelId'),
          reelOwnerId: any(named: 'reelOwnerId'),
          text: any(named: 'text'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return ReelCommentsCubit(repo, reel: r1);
    },
    act: (ReelCommentsCubit cubit) => cubit.addComment('hey'),
    expect: () => const <ReelCommentsState>[
      ReelCommentsState(sending: true),
      ReelCommentsState(sending: false, error: 'boom'),
    ],
  );
}
