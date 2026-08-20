import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../domain/models/reel.dart';
import '../../domain/repositories/reels_repository.dart';
import 'reels_state.dart';

// ponytail: reels are global (no follow filter) — Instagram discovery semantics
class ReelsCubit extends Cubit<ReelsState> {
  ReelsCubit(this._repository) : super(const ReelsState()) {
    _subscribe();
  }

  static const int _pageSize = 10;

  final IReelsRepository _repository;
  StreamSubscription<List<Reel>>? _sub;
  int _limit = _pageSize;
  int _gen = 0;

  void _subscribe() {
    _sub?.cancel();
    final int gen = ++_gen;
    _sub = _repository
        .watchReels(limit: _limit)
        .listen(
          (List<Reel> reels) => _onReels(reels, gen),
          onError: (Object e) {
            if (isClosed) return;
            emit(state.copyWith(error: 'Failed to load reels'));
          },
        );
  }

  Future<void> _onReels(List<Reel> reels, int gen) async {
    if (isClosed || gen != _gen) return;
    final Either<Failure, Set<String>> either = await _repository
        .fetchLikedReelIds(reelIds: reels.map((Reel r) => r.id).toList());
    if (isClosed || gen != _gen) return;
    either.fold(
      (_) => emit(
        state.copyWith(
          status: ReelsStatus.ready,
          reels: reels,
          hasMore: reels.length >= _limit,
        ),
      ), // ponytail: keep stale likedIds on hydration failure
      (Set<String> ids) => emit(
        state.copyWith(
          status: ReelsStatus.ready,
          reels: reels,
          likedIds: ids,
          hasMore: reels.length >= _limit,
        ),
      ),
    );
  }

  void loadMore() {
    if (!state.hasMore) return;
    _limit += _pageSize;
    _subscribe();
  }

  Future<void> toggleReelLike(Reel reel) async {
    final bool wasLiked = state.likedIds.contains(reel.id);
    // optimistic flip
    emit(
      state.copyWith(
        reels: state.reels
            .map(
              (Reel r) => r.id == reel.id
                  ? r.copyWith(likeCount: r.likeCount + (wasLiked ? -1 : 1))
                  : r,
            )
            .toList(),
        likedIds: wasLiked
            ? (<String>{...state.likedIds}..remove(reel.id))
            : <String>{...state.likedIds, reel.id},
      ),
    );
    final Either<Failure, void> either = await _repository.toggleReelLike(
      reelId: reel.id,
      reelOwnerId: reel.uid,
      currentlyLiked: wasLiked,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(
        state.copyWith(
          error: f.message,
          reels: state.reels
              .map(
                (Reel r) => r.id == reel.id
                    ? r.copyWith(likeCount: r.likeCount + (wasLiked ? 1 : -1))
                    : r,
              )
              .toList(),
          likedIds: wasLiked
              ? <String>{...state.likedIds, reel.id}
              : (<String>{...state.likedIds}..remove(reel.id)),
        ),
      ),
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
