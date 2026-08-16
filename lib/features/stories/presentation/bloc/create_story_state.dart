import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_story_state.freezed.dart';

@freezed
sealed class CreateStoryState with _$CreateStoryState {
  const factory CreateStoryState({
    String? pickedPath,
    @Default(false) bool submitting,
    @Default(false) bool success,
    String? error,
  }) = _CreateStoryState;
}
