import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/post.dart';

part 'explore_state.freezed.dart';

enum ExploreStatus { loading, ready }

@freezed
sealed class ExploreState with _$ExploreState {
  const factory ExploreState({
    @Default(ExploreStatus.loading) ExploreStatus status,
    @Default(<Post>[]) List<Post> posts,
    @Default(true) bool hasMore,
    String? error,
  }) = _ExploreState;
}
