import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/app_user.dart';

part 'follow_list_state.freezed.dart';

@freezed
sealed class FollowListState with _$FollowListState {
  const factory FollowListState({
    @Default(<AppUser>[]) List<AppUser> users,
    @Default(false) bool loading,
    String? error,
  }) = _FollowListState;
}
