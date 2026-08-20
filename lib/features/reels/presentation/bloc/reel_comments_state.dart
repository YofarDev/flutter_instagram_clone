import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/comment.dart';

part 'reel_comments_state.freezed.dart';

enum ReelCommentsStatus { loading, ready }

@freezed
sealed class ReelCommentsState with _$ReelCommentsState {
  const factory ReelCommentsState({
    @Default(ReelCommentsStatus.loading) ReelCommentsStatus status,
    @Default(<Comment>[]) List<Comment> comments,
    @Default(false) bool sending,
    String? error,
  }) = _ReelCommentsState;
}
