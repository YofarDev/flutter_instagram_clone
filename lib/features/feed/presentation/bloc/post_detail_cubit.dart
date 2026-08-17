import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../domain/models/comment.dart';
import '../../../../core/models/post.dart';
import '../../domain/repositories/feed_repository.dart';
import 'post_detail_state.dart';

class PostDetailCubit extends Cubit<PostDetailState> {
  PostDetailCubit(this._repository, {Post? post, String? postId})
      : super(post != null
            ? PostDetailState(post: post, status: PostDetailStatus.ready)
            : const PostDetailState()) {
    if (post != null) {
      _onPostReady(post);
    } else if (postId != null) {
      _fetchPost(postId);
    }
  }

  final IFeedRepository _repository;
  StreamSubscription<List<Comment>>? _commentsSub;
  bool _toggled = false;

  Future<void> _fetchPost(String postId) async {
    final Either<Failure, Post> either =
        await _repository.getPostById(postId: postId);
    if (isClosed) return;
    either.fold(
      (Failure f) =>
          emit(state.copyWith(status: PostDetailStatus.failed, error: f.message)),
      (Post post) {
        emit(state.copyWith(post: post, status: PostDetailStatus.ready));
        _onPostReady(post);
      },
    );
  }

  void _onPostReady(Post post) {
    _commentsSub = _repository
        .watchComments(postId: post.id)
        .listen(_onComments, onError: (Object e) {
      if (isClosed) return;
      emit(state.copyWith(error: 'Failed to load comments'));
    });
    _hydrateLike();
  }

  Future<void> _hydrateLike() async {
    final String postId = state.post!.id;
    final Either<Failure, Set<String>> either =
        await _repository.fetchLikedPostIds(postIds: <String>[postId]);
    if (isClosed || _toggled) return;
    either.fold(
      (_) {}, // ponytail: default unliked on hydration failure
      (Set<String> ids) =>
          emit(state.copyWith(isLiked: ids.contains(postId))),
    );
  }

  void _onComments(List<Comment> comments) =>
      emit(state.copyWith(comments: comments));

  Future<void> toggleLike() async {
    final bool wasLiked = state.isLiked;
    _toggled = true;
    emit(state.copyWith(
      isLiked: !wasLiked,
      post: state.post!
          .copyWith(likeCount: state.post!.likeCount + (wasLiked ? -1 : 1)),
    ));
    final Either<Failure, void> either = await _repository.toggleLike(
      post: state.post!,
      currentlyLiked: wasLiked,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(
        error: f.message,
        isLiked: wasLiked,
        post: state.post!.copyWith(
          likeCount: state.post!.likeCount + (wasLiked ? 1 : -1),
        ),
      )),
      (_) {},
    );
  }

  Future<void> addComment(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return;
    emit(state.copyWith(sending: true, error: null));
    final Either<Failure, void> either = await _repository.addComment(
      postId: state.post!.id,
      postOwnerId: state.post!.authorId,
      text: trimmed,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(sending: false, error: f.message)),
      (_) => emit(state.copyWith(
        sending: false,
        post: state.post!
            .copyWith(commentCount: state.post!.commentCount + 1),
      )),
    );
  }

  void clearError() => emit(state.copyWith(error: null));

  @override
  Future<void> close() {
    _commentsSub?.cancel();
    return super.close();
  }
}
