import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/comment.dart';
import '../../../../core/models/failure.dart';
import '../../domain/models/reel.dart';
import '../../domain/repositories/reels_repository.dart';
import 'reel_comments_state.dart';

/// Sheet-scoped: one instance per open comment sheet, wired via
/// registerFactoryParam in service_locator.
class ReelCommentsCubit extends Cubit<ReelCommentsState> {
  ReelCommentsCubit(this._repository, {required Reel reel})
    : _reel = reel,
      super(const ReelCommentsState()) {
    _sub = _repository
        .watchReelComments(reelId: reel.id)
        .listen(
          (List<Comment> comments) {
            if (isClosed) return;
            emit(
              state.copyWith(
                status: ReelCommentsStatus.ready,
                comments: comments,
              ),
            );
          },
          onError: (Object e) {
            if (isClosed) return;
            emit(state.copyWith(error: 'Failed to load comments'));
          },
        );
  }

  final IReelsRepository _repository;
  final Reel _reel;
  StreamSubscription<List<Comment>>? _sub;

  Future<void> addComment(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return;
    emit(state.copyWith(sending: true, error: null));
    final Either<Failure, void> either = await _repository.addReelComment(
      reelId: _reel.id,
      reelOwnerId: _reel.uid,
      text: trimmed,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(sending: false, error: f.message)),
      (_) => emit(state.copyWith(sending: false)),
      // count on the reel doc bumps via transaction; watchReels delivers
    );
  }

  void clearError() => emit(state.copyWith(error: null));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
