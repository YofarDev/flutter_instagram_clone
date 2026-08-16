import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

@freezed
sealed class AppUser with _$AppUser {
  const factory AppUser({
    required String uid,
    required String email,
    String? username,
    String? bio,
    String? avatarUrl,
  }) = _AppUser;
}
