import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../domain/models/comment.dart';
import '../../domain/models/post.dart';
import '../../domain/repositories/feed_repository.dart';
import 'post_detail_state.dart';

class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit(this._repository, {required Post post})
      : super(PostDetailState(post: post)) {
    _commentsSub = _repository
        .watchComments(postId: post.id)
        .listen(_onComments, onError: (Object e) {
      emit(state.copyWith(error: 'Failed to load comments'));
    });
    _hydrateLike();
  }

  final IFeedRepository _repository;
  late final StreamSubscription<List<Comment>> _commentsSub;

  Future<void> _hydrateLike() async {
    final Either<Failure, Set<String>> either =
        await _repository.fetchLikedPostIds(postIds: <String>[state.post.id]);
    either.fold(
      (_) {}, // ponytail: default unliked on hydration failure
      (Set<String> ids) =>
          emit(state.copyWith(isLiked: ids.contains(state.post.id))),
    );
  }

  void _onComments(List<Comment> comments) =>
      emit(state.copyWith(comments: comments));

  Future<void> toggleLike() async {
    final bool wasLiked = state.isLiked;
    emit(state.copyWith(
      isLiked: !wasLiked,
      post: state.post
          .copyWith(likeCount: state.post.likeCount + (wasLiked ? -1 : 1)),
    ));
    final Either<Failure, void> either = await _repository.toggleLike(
      post: state.post,
      currentlyLiked: wasLiked,
    );
    either.fold(
      (Failure f) => emit(state.copyWith(
        error: f.message,
        isLiked: wasLiked,
        post: state.post.copyWith(
          likeCount: state.post.likeCount + (wasLiked ? 1 : -1),
        ),
      )),
      (_) {},
    );
  }

  Future<void> addComment(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return;
    emit(state.copyWith(sending: true, error: null));
    final Either<Failure, void> either =
        await _repository.addComment(postId: state.post.id, text: trimmed);
    either.fold(
      (Failure f) => emit(state.copyWith(sending: false, error: f.message)),
      (_) => emit(state.copyWith(sending: false)),
    );
  }

  void clearError() => emit(state.copyWith(error: null));

  @override
  Future<void> close() {
    _commentsSub.cancel();
    return super.close();
  }
}
