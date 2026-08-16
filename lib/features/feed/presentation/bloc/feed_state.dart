import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/post.dart';

part 'feed_state.freezed.dart';

enum FeedStatus { loading, ready }

@freezed
sealed class FeedState with _$FeedState {
  const factory FeedState({
    @Default(FeedStatus.loading) FeedStatus status,
    @Default(<Post>[]) List<Post> posts,
    @Default(<String>{}) Set<String> likedIds,
    @Default(true) bool hasMore,
    String? error,
  }) = _FeedState;
}
