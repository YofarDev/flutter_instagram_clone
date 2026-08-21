import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_post_state.freezed.dart';

@freezed
sealed class CreatePostState with _$CreatePostState {
  const factory CreatePostState({
    @Default(<String>[]) List<String> pickedPaths,
    @Default('') String caption,
    @Default(false) bool submitting,
    @Default(false) bool success,
    String? error,
  }) = _CreatePostState;
}
