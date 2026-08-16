import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../../../core/models/post.dart';
import '../../domain/repositories/feed_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import 'feed_state.dart';

class FeedCubit extends Cubit<FeedState> {
  FeedCubit(this._repository, this._profileRepository, {required String myUid})
      : _myUid = myUid,
        super(const FeedState()) {
    _subscribe();
    _followingSub = _profileRepository
        .watchFollowingIds(uid: myUid)
        .listen((List<String> ids) {
      _followingIds = ids.toSet();
      // re-filter raw posts on follow changes; skip before first posts emission
      if (_allPosts != null) _emitFiltered(_gen);
    });
  }

  static const int _pageSize = 10;

  final IFeedRepository _repository;
  final IProfileRepository _profileRepository;
  final String _myUid;
  StreamSubscription<List<Post>>? _sub;
  StreamSubscription<List<String>>? _followingSub;
  Set<String> _followingIds = <String>{};
  List<Post>? _allPosts;
  int _limit = _pageSize;
  int _gen = 0;

  // ponytail: client-side follow filter; Firestore 'in' caps at 10 —
  // server-side whereIn when the graph outgrows it
  List<Post> get _visiblePosts => _allPosts!
      .where((Post p) =>
          p.authorId == _myUid || _followingIds.contains(p.authorId))
      .toList();

  void _subscribe() {
    _sub?.cancel();
    final int gen = ++_gen;
    _sub = _repository.watchFeed(limit: _limit).listen(
          (List<Post> posts) => _onPosts(posts, gen),
          onError: (Object e) {
            if (isClosed) return;
            emit(state.copyWith(error: 'Failed to load feed'));
          },
        );
  }

  Future<void> _onPosts(List<Post> posts, int gen) async {
    if (isClosed || gen != _gen) return;
    _allPosts = posts;
    await _emitFiltered(gen);
  }

  Future<void> _emitFiltered(int gen) async {
    if (isClosed || gen != _gen) return;
    final List<Post> visible = _visiblePosts;
    final Either<Failure, Set<String>> either = await _repository
        .fetchLikedPostIds(
            postIds: visible.map((Post p) => p.id).toList());
    if (isClosed || gen != _gen) return;
    either.fold(
      (_) => emit(state.copyWith(
        status: FeedStatus.ready,
        posts: visible,
        hasMore: _allPosts!.length >= _limit,
      )), // ponytail: keep stale likedIds on hydration failure
      (Set<String> ids) => emit(state.copyWith(
        status: FeedStatus.ready,
        posts: visible,
        likedIds: ids,
        hasMore: _allPosts!.length >= _limit,
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
    _followingSub?.cancel();
    return super.close();
  }
}
