import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/comment.dart';
import '../../../../core/models/post.dart';

part 'post_detail_state.freezed.dart';

enum PostDetailStatus { loading, ready }

@freezed
sealed class PostDetailState with _$PostDetailState {
  const factory PostDetailState({
    Post? post,
    @Default(PostDetailStatus.loading) PostDetailStatus status,
    @Default(false) bool isLiked,
    @Default(<Comment>[]) List<Comment> comments,
    @Default(false) bool sending,
    String? error,
  }) = _PostDetailState;
}
