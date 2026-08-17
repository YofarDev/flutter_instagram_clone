import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/post.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/repositories/explore_repository.dart';
import 'explore_state.dart';

class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit(this._repository, this._profileRepository, {required String myUid})
      : _myUid = myUid,
        super(const ExploreState()) {
    _subscribe();
    _followingSub = _profileRepository
        .watchFollowingIds(uid: myUid)
        .listen((List<String> ids) {
      _followingIds = ids.toSet();
      // re-filter raw posts on follow changes; skip before first posts emission
      if (_allPosts != null) _emitFiltered(_gen);
    });
  }

  static const int _pageSize = 12;

  final IExploreRepository _repository;
  final IProfileRepository _profileRepository;
  final String _myUid;
  StreamSubscription<List<Post>>? _sub;
  StreamSubscription<List<String>>? _followingSub;
  Set<String> _followingIds = <String>{};
  List<Post>? _allPosts;
  int _limit = _pageSize;
  int _gen = 0;

  // ponytail: inverse of feed — discovery shows only non-followed strangers;
  // same client-side filter ceiling (Firestore 'in' caps at 10)
  List<Post> get _visiblePosts => _allPosts!
      .where((Post p) =>
          p.authorId != _myUid && !_followingIds.contains(p.authorId))
      .toList();

  void _subscribe() {
    _sub?.cancel();
    final int gen = ++_gen;
    _sub = _repository.watchExplorePosts(limit: _limit).listen(
          (List<Post> posts) => _onPosts(posts, gen),
          onError: (Object e) {
            if (isClosed) return;
            emit(state.copyWith(error: 'Failed to load explore'));
          },
        );
  }

  void _onPosts(List<Post> posts, int gen) {
    if (isClosed || gen != _gen) return;
    _allPosts = posts;
    _emitFiltered(gen);
  }

  void _emitFiltered(int gen) {
    if (isClosed || gen != _gen) return;
    emit(state.copyWith(
      status: ExploreStatus.ready,
      posts: _visiblePosts,
      hasMore: _allPosts!.length >= _limit,
    ));
  }

  void loadMore() {
    if (!state.hasMore) return;
    _limit += _pageSize;
    _subscribe();
  }

  void clearError() => emit(state.copyWith(error: null));

  @override
  Future<void> close() {
    _sub?.cancel();
    _followingSub?.cancel();
    return super.close();
  }
}
