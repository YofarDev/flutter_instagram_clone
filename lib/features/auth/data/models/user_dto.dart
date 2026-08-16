import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_dto.freezed.dart';

@freezed
sealed class UserDto with _$UserDto {
  const factory UserDto({
    required String email,
    String? username,
    String? bio,
    String? avatarUrl,
  }) = _UserDto;

  const UserDto._();

  factory UserDto.fromMap(Map<String, dynamic> map) => UserDto(
        email: map['email'] as String,
        username: map['username'] as String?,
        bio: map['bio'] as String?,
        avatarUrl: map['avatarUrl'] as String?,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'email': email,
        'username': username,
        'bio': bio,
        'avatarUrl': avatarUrl,
      };
}
