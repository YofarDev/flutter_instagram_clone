import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/core/models/comment.dart';
import 'package:flutter_instagram_clone/core/models/post.dart';
import 'package:flutter_instagram_clone/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/post_detail_cubit.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/post_detail_state.dart';

class MockIFeedRepository extends Mock implements IFeedRepository {}

final Post p1 = Post(
  id: 'p1',
  authorId: 'u1',
  authorUsername: 'yo',
  imageUrls: <String>['http://img/p1'],
  createdAt: DateTime(2026, 1, 1),
  likeCount: 5,
  commentCount: 2,
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
    // saved hydration defaults to offline/Left; tests can re-stub
    when(() => repo.fetchSavedPostIds(postIds: <String>['p1'])).thenAnswer(
      (_) async => const Left<Failure, Set<String>>(
        Failure.serverError(message: 'offline'),
      ),
    );
  });

  // ponytail: exact-arg stubs, no registerFallbackValue needed
  void stubQuietCtor() {
    when(
      () => repo.watchComments(postId: 'p1'),
    ).thenAnswer((_) => const Stream<List<Comment>>.empty());
    when(() => repo.fetchLikedPostIds(postIds: <String>['p1'])).thenAnswer(
      (_) async => const Left<Failure, Set<String>>(
        Failure.serverError(message: 'offline'),
      ),
    );
    when(() => repo.fetchSavedPostIds(postIds: <String>['p1'])).thenAnswer(
      (_) async => const Left<Failure, Set<String>>(
        Failure.serverError(message: 'offline'),
      ),
    );
  }

  blocTest<PostDetailCubit, PostDetailState>(
    'toggleSave flips optimistically and rolls back on failure',
    build: () {
      stubQuietCtor();
      when(
        () => repo.toggleSave(
          post: any(named: 'post'),
          currentlySaved: any(named: 'currentlySaved'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return PostDetailCubit(repo, post: p1);
    },
    act: (PostDetailCubit cubit) => cubit.toggleSave(),
    expect: () => <PostDetailState>[
      PostDetailState(post: p1, status: PostDetailStatus.ready, isSaved: true),
      PostDetailState(
        post: p1,
        status: PostDetailStatus.ready,
        isSaved: false,
        error: 'boom',
      ),
    ],
  );

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
      PostDetailState(post: p1, status: PostDetailStatus.ready, isLiked: true),
      PostDetailState(
        post: p1,
        status: PostDetailStatus.ready,
        isLiked: true,
        comments: <Comment>[c1],
      ),
    ],
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'comments stream error sets error message',
    build: () {
      stubQuietCtor();
      when(
        () => repo.watchComments(postId: 'p1'),
      ).thenAnswer((_) => Stream<List<Comment>>.error(Exception('db down')));
      return PostDetailCubit(repo, post: p1);
    },
    expect: () => <PostDetailState>[
      PostDetailState(
        post: p1,
        status: PostDetailStatus.ready,
        error: 'Failed to load comments',
      ),
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
      verify(
        () => repo.toggleLike(
          post: p1.copyWith(likeCount: 6),
          currentlyLiked: false,
        ),
      ).called(1);
    },
    expect: () => <PostDetailState>[
      PostDetailState(
        post: p1.copyWith(likeCount: 6),
        status: PostDetailStatus.ready,
        isLiked: true,
      ),
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
      PostDetailState(
        post: p1.copyWith(likeCount: 6),
        status: PostDetailStatus.ready,
        isLiked: true,
      ),
      PostDetailState(post: p1, status: PostDetailStatus.ready, error: 'boom'),
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
          postOwnerId: any(named: 'postOwnerId'),
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
      when(
        () => repo.addComment(postId: 'p1', postOwnerId: 'u1', text: 'hey'),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      return PostDetailCubit(repo, post: p1);
    },
    act: (PostDetailCubit cubit) => cubit.addComment(' hey '),
    verify: (_) {
      verify(
        () => repo.addComment(postId: 'p1', postOwnerId: 'u1', text: 'hey'),
      ).called(1);
    },
    expect: () => <PostDetailState>[
      PostDetailState(post: p1, status: PostDetailStatus.ready, sending: true),
      PostDetailState(
        post: p1.copyWith(commentCount: 3),
        status: PostDetailStatus.ready,
      ),
    ],
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'addComment failure sets error',
    build: () {
      stubQuietCtor();
      when(
        () => repo.addComment(postId: 'p1', postOwnerId: 'u1', text: 'hey'),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return PostDetailCubit(repo, post: p1);
    },
    act: (PostDetailCubit cubit) => cubit.addComment('hey'),
    expect: () => <PostDetailState>[
      PostDetailState(post: p1, status: PostDetailStatus.ready, sending: true),
      PostDetailState(post: p1, status: PostDetailStatus.ready, error: 'boom'),
    ],
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'postId path fetches post then goes ready',
    build: () {
      when(
        () => repo.getPostById(postId: 'p1'),
      ).thenAnswer((_) async => Right<Failure, Post>(p1));
      when(
        () => repo.watchComments(postId: 'p1'),
      ).thenAnswer((_) => const Stream<List<Comment>>.empty());
      when(() => repo.fetchLikedPostIds(postIds: <String>['p1'])).thenAnswer(
        (_) async => const Left<Failure, Set<String>>(
          Failure.serverError(message: 'offline'),
        ),
      );
      return PostDetailCubit(repo, postId: 'p1');
    },
    expect: () => <PostDetailState>[
      PostDetailState(post: p1, status: PostDetailStatus.ready),
    ],
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'postId path not found sets error',
    build: () {
      when(() => repo.getPostById(postId: 'p1')).thenAnswer(
        (_) async => const Left<Failure, Post>(
          Failure.serverError(message: 'Post not found'),
        ),
      );
      return PostDetailCubit(repo, postId: 'p1');
    },
    expect: () => <PostDetailState>[
      const PostDetailState(
        status: PostDetailStatus.failed,
        error: 'Post not found',
      ),
    ],
  );
}
