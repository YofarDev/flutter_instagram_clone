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
    _followingSub = _profileRepository.watchFollowingIds(uid: myUid).listen((
      List<String> ids,
    ) {
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
  bool _fetchingMore = false;
  Completer<void>? _refreshCompleter;

  // ponytail: client-side follow filter; Firestore 'in' caps at 10 —
  // server-side whereIn when the graph outgrows it
  List<Post> get _visiblePosts => _allPosts!
      .where(
        (Post p) => p.authorId == _myUid || _followingIds.contains(p.authorId),
      )
      .toList();

  void _subscribe() {
    _sub?.cancel();
    final int gen = ++_gen;
    _sub = _repository
        .watchFeed(limit: _limit)
        .listen(
          (List<Post> posts) => _onPosts(posts, gen),
          onError: (Object e) {
            if (isClosed) return;
            emit(state.copyWith(error: 'Failed to load feed'));
            _completeRefresh();
          },
        );
  }

  Future<void> _onPosts(List<Post> posts, int gen) async {
    if (isClosed || gen != _gen) return;
    _allPosts = posts;
    await _emitFiltered(gen);
    _completeRefresh();
  }

  void _completeRefresh() {
    if (!(_refreshCompleter?.isCompleted ?? true)) {
      _refreshCompleter!.complete();
    }
  }

  Future<void> _emitFiltered(int gen) async {
    if (isClosed || gen != _gen) return;
    final List<Post> visible = _visiblePosts;
    final List<String> ids = visible.map((Post p) => p.id).toList();
    final List<Either<Failure, Set<String>>> results =
        await Future.wait(<Future<Either<Failure, Set<String>>>>[
          _repository.fetchLikedPostIds(postIds: ids),
          _repository.fetchSavedPostIds(postIds: ids),
        ]);
    if (isClosed || gen != _gen) return;
    _fetchingMore = false;
    // ponytail: keep stale liked/saved ids on hydration failure
    final Set<String>? liked = results[0].fold(
      (Failure _) => null,
      (Set<String> ids) => ids,
    );
    final Set<String>? saved = results[1].fold(
      (Failure _) => null,
      (Set<String> ids) => ids,
    );
    emit(
      state.copyWith(
        status: FeedStatus.ready,
        posts: visible,
        likedIds: liked ?? state.likedIds,
        savedIds: saved ?? state.savedIds,
        hasMore: _allPosts!.length >= _limit,
      ),
    );
  }

  void loadMore() {
    if (!state.hasMore || _fetchingMore) return;
    _fetchingMore = true;
    _limit += _pageSize;
    _subscribe();
  }

  /// Pull-to-refresh: reset to the first page and complete once the
  /// re-subscribed stream has emitted (or failed).
  Future<void> refresh() {
    if (!(_refreshCompleter?.isCompleted ?? true)) {
      return _refreshCompleter!.future;
    }
    _refreshCompleter = Completer<void>();
    _limit = _pageSize;
    _subscribe();
    return _refreshCompleter!.future;
  }

  Future<void> toggleLike(Post post) async {
    final bool wasLiked = state.likedIds.contains(post.id);
    // optimistic flip
    emit(
      state.copyWith(
        posts: state.posts
            .map(
              (Post p) => p.id == post.id
                  ? p.copyWith(likeCount: p.likeCount + (wasLiked ? -1 : 1))
                  : p,
            )
            .toList(),
        likedIds: wasLiked
            ? (<String>{...state.likedIds}..remove(post.id))
            : <String>{...state.likedIds, post.id},
      ),
    );
    final Either<Failure, void> either = await _repository.toggleLike(
      post: post,
      currentlyLiked: wasLiked,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(
        state.copyWith(
          error: f.message,
          posts: state.posts
              .map(
                (Post p) => p.id == post.id
                    ? p.copyWith(likeCount: p.likeCount + (wasLiked ? 1 : -1))
                    : p,
              )
              .toList(),
          likedIds: wasLiked
              ? <String>{...state.likedIds, post.id}
              : (<String>{...state.likedIds}..remove(post.id)),
        ),
      ),
      (_) {},
    );
  }

  Future<void> toggleSave(Post post) async {
    final bool wasSaved = state.savedIds.contains(post.id);
    // optimistic flip, rollback on failure — same discipline as toggleLike
    emit(
      state.copyWith(
        savedIds: wasSaved
            ? (<String>{...state.savedIds}..remove(post.id))
            : <String>{...state.savedIds, post.id},
      ),
    );
    final Either<Failure, void> either = await _repository.toggleSave(
      post: post,
      currentlySaved: wasSaved,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(
        state.copyWith(
          error: f.message,
          savedIds: wasSaved
              ? <String>{...state.savedIds, post.id}
              : (<String>{...state.savedIds}..remove(post.id)),
        ),
      ),
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
