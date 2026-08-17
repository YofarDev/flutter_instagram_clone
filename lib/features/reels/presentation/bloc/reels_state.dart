import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/reel.dart';

part 'reels_state.freezed.dart';

enum ReelsStatus { loading, ready }

@freezed
sealed class ReelsState with _$ReelsState {
  const factory ReelsState({
    @Default(ReelsStatus.loading) ReelsStatus status,
    @Default(<Reel>[]) List<Reel> reels,
    @Default(<String>{}) Set<String> likedIds,
    @Default(true) bool hasMore,
    String? error,
  }) = _ReelsState;
}
