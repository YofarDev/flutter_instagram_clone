import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/feed/domain/models/comment.dart';
import 'package:flutter_instagram_clone/features/feed/domain/models/post.dart';
import 'package:flutter_instagram_clone/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/post_detail_cubit.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/post_detail_state.dart';

class MockIFeedRepository extends Mock implements IFeedRepository {}

final Post p1 = Post(
  id: 'p1',
  authorId: 'u1',
  authorUsername: 'yo',
  imageUrl: 'http://img/p1',
  createdAt: DateTime(2026, 1, 1),
  likeCount: 5,
);
final Comment c1 = Comment(
  id: 'c1',
  postId: 'p1',
  authorId: 'u2',
  authorUsername: 'ma',
  text: 'nice',
  createdAt: DateTime(2026, 1, 2),
);

void main() {
  late MockIFeedRepository repo;

  setUp(() {
    repo = MockIFeedRepository();
    registerFallbackValue(p1);
  });

  // ponytail: exact-arg stubs, no registerFallbackValue needed
  void stubQuietCtor() {
    when(() => repo.watchComments(postId: 'p1'))
        .thenAnswer((_) => const Stream<List<Comment>>.empty());
    when(() => repo.fetchLikedPostIds(postIds: <String>['p1'])).thenAnswer(
      (_) async =>
          const Left<Failure, Set<String>>(Failure.serverError(message: 'offline')),
    );
  }

  blocTest<PostDetailCubit, PostDetailState>(
    'hydrates like state then comments',
    build: () {
      when(() => repo.watchComments(postId: 'p1')).thenAnswer(
        (_) => Stream<List<Comment>>.fromFuture(
          Future<List<Comment>>.delayed(
            const Duration(milliseconds: 50),
            () => <Comment>[c1],
          ),
        ),
      );
      when(() => repo.fetchLikedPostIds(postIds: <String>['p1'])).thenAnswer(
        (_) async => const Right<Failure, Set<String>>(<String>{'p1'}),
      );
      return PostDetailCubit(repo, post: p1);
    },
    wait: const Duration(milliseconds: 200),
    expect: () => <PostDetailState>[
      PostDetailState(post: p1, isLiked: true),
      PostDetailState(post: p1, isLiked: true, comments: <Comment>[c1]),
    ],
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'comments stream error sets error message',
    build: () {
      stubQuietCtor();
      when(() => repo.watchComments(postId: 'p1'))
          .thenAnswer((_) => Stream<List<Comment>>.error(Exception('db down')));
      return PostDetailCubit(repo, post: p1);
    },
    expect: () => <PostDetailState>[
      PostDetailState(post: p1, error: 'Failed to load comments'),
    ],
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'toggleLike optimistic flip on success',
    build: () {
      stubQuietCtor();
      when(
        () => repo.toggleLike(
          post: any(named: 'post'),
          currentlyLiked: any(named: 'currentlyLiked'),
        ),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      return PostDetailCubit(repo, post: p1);
    },
    act: (PostDetailCubit cubit) => cubit.toggleLike(),
    verify: (_) {
      // repo receives the optimistically flipped post (likeCount 6)
      verify(() => repo.toggleLike(
        post: p1.copyWith(likeCount: 6),
        currentlyLiked: false,
      )).called(1);
    },
    expect: () => <PostDetailState>[
      PostDetailState(post: p1.copyWith(likeCount: 6), isLiked: true),
    ],
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'toggleLike rolls back on failure',
    build: () {
      stubQuietCtor();
      when(
        () => repo.toggleLike(
          post: any(named: 'post'),
          currentlyLiked: any(named: 'currentlyLiked'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return PostDetailCubit(repo, post: p1);
    },
    act: (PostDetailCubit cubit) => cubit.toggleLike(),
    expect: () => <PostDetailState>[
      PostDetailState(post: p1.copyWith(likeCount: 6), isLiked: true),
      PostDetailState(post: p1, error: 'boom'),
    ],
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'addComment with blank text does nothing',
    build: () {
      stubQuietCtor();
      return PostDetailCubit(repo, post: p1);
    },
    act: (PostDetailCubit cubit) => cubit.addComment('   '),
    verify: (_) {
      verifyNever(
        () => repo.addComment(
          postId: any(named: 'postId'),
          text: any(named: 'text'),
        ),
      );
    },
    expect: () => const <PostDetailState>[],
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'addComment success sends trimmed text',
    build: () {
      stubQuietCtor();
      when(() => repo.addComment(postId: 'p1', text: 'hey'))
          .thenAnswer((_) async => const Right<Failure, void>(null));
      return PostDetailCubit(repo, post: p1);
    },
    act: (PostDetailCubit cubit) => cubit.addComment(' hey '),
    verify: (_) {
      verify(() => repo.addComment(postId: 'p1', text: 'hey')).called(1);
    },
    expect: () => <PostDetailState>[
      PostDetailState(post: p1, sending: true),
      PostDetailState(post: p1),
    ],
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'addComment failure sets error',
    build: () {
      stubQuietCtor();
      when(() => repo.addComment(postId: 'p1', text: 'hey')).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return PostDetailCubit(repo, post: p1);
    },
    act: (PostDetailCubit cubit) => cubit.addComment('hey'),
    expect: () => <PostDetailState>[
      PostDetailState(post: p1, sending: true),
      PostDetailState(post: p1, error: 'boom'),
    ],
  );
}
