import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../domain/models/post.dart';
import '../../domain/repositories/feed_repository.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit(this._repository) : super(const FeedState()) {
    _subscribe();
  }

  static const int _pageSize = 10;

  final IFeedRepository _repository;
  StreamSubscription<List<Post>>? _sub;
  int _limit = _pageSize;
  int _gen = 0;

  void _subscribe() {
    _sub?.cancel();
    final int gen = ++_gen;
    _sub = _repository.watchFeed(limit: _limit).listen(
          (List<Post> posts) => _onPosts(posts, gen),
          onError: (Object e) =>
              emit(state.copyWith(error: 'Failed to load feed')),
        );
  }

  Future<void> _onPosts(List<Post> posts, int gen) async {
    if (isClosed || gen != _gen) return;
    final Either<Failure, Set<String>> either = await _repository
        .fetchLikedPostIds(postIds: posts.map((Post p) => p.id).toList());
    if (isClosed || gen != _gen) return;
    either.fold(
      (_) => emit(state.copyWith(
        status: FeedStatus.ready,
        posts: posts,
        hasMore: posts.length >= _limit,
      )), // ponytail: keep stale likedIds on hydration failure
      (Set<String> ids) => emit(state.copyWith(
        status: FeedStatus.ready,
        posts: posts,
        likedIds: ids,
        hasMore: posts.length >= _limit,
      )),
    );
  }

  void loadMore() {
    if (!state.hasMore) return;
    _limit += _pageSize;
    _subscribe();
  }

  Future<void> toggleLike(Post post) async {
    final bool wasLiked = state.likedIds.contains(post.id);
    // optimistic flip
    emit(state.copyWith(
      posts: state.posts
          .map((Post p) => p.id == post.id
              ? p.copyWith(likeCount: p.likeCount + (wasLiked ? -1 : 1))
              : p)
          .toList(),
      likedIds: wasLiked
          ? (<String>{...state.likedIds}..remove(post.id))
          : <String>{...state.likedIds, post.id},
    ));
    final Either<Failure, void> either =
        await _repository.toggleLike(post: post, currentlyLiked: wasLiked);
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(
        error: f.message,
        posts: state.posts
            .map((Post p) => p.id == post.id
                ? p.copyWith(likeCount: p.likeCount + (wasLiked ? 1 : -1))
                : p)
            .toList(),
        likedIds: wasLiked
            ? <String>{...state.likedIds, post.id}
            : (<String>{...state.likedIds}..remove(post.id)),
      )),
      (_) {},
    );
  }

  void clearError() => emit(state.copyWith(error: null));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
