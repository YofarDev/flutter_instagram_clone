import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/app_user.dart';

part 'auth_state.freezed.dart';

enum AuthStatus { loading, unauthenticated, needsProfile, authenticated }

@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.loading) AuthStatus status,
    AppUser? user,
    @Default(false) bool submitting,
    String? error,
  }) = _AuthState;
}
