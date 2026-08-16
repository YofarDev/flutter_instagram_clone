import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/app_user.dart';

part 'edit_profile_state.freezed.dart';

@freezed
sealed class EditProfileState with _$EditProfileState {
  const factory EditProfileState({
    required AppUser initial,
    @Default('') String username,
    @Default('') String bio,
    String? avatarPath,
    @Default(false) bool submitting,
    @Default(false) bool success,
    String? error,
  }) = _EditProfileState;
}
