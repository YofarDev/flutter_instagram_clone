import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/app_user.dart';

part 'search_state.freezed.dart';

@freezed
sealed class SearchState with _$SearchState {
  const factory SearchState({
    @Default('') String query,
    @Default(<AppUser>[]) List<AppUser> users,
    @Default(false) bool searching,
    String? error,
  }) = _SearchState;
}
