import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/comment.dart';
import '../../../../core/models/post.dart';

part 'post_detail_state.freezed.dart';

@freezed
sealed class PostDetailState with _$PostDetailState {
  const factory PostDetailState({
    required Post post,
    @Default(false) bool isLiked,
    @Default(<Comment>[]) List<Comment> comments,
    @Default(false) bool sending,
    String? error,
  }) = _PostDetailState;
}
