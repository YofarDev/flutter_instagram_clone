import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/post.dart';

part 'hashtag_state.freezed.dart';

enum HashtagStatus { loading, ready }

@freezed
sealed class HashtagState with _$HashtagState {
  const factory HashtagState({
    @Default(HashtagStatus.loading) HashtagStatus status,
    @Default(<Post>[]) List<Post> posts,
    String? error,
  }) = _HashtagState;
}
