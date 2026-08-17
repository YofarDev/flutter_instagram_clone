import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_reel_state.freezed.dart';

@freezed
sealed class CreateReelState with _$CreateReelState {
  const factory CreateReelState({
    String? pickedPath,
    @Default('') String caption,
    @Default(false) bool submitting,
    @Default(false) bool success,
    String? error,
  }) = _CreateReelState;
}
