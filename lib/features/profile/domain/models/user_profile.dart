import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/app_user.dart';

part 'user_profile.freezed.dart';

@freezed
sealed class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,
    required String email,
    String? username,
    String? bio,
    String? avatarUrl,
    @Default(0) int followerCount,
    @Default(0) int followingCount,
    @Default(0) int postCount,
  }) = _UserProfile;

  factory UserProfile.fromAppUser(
    AppUser user, {
    int followerCount = 0,
    int followingCount = 0,
    int postCount = 0,
  }) =>
      UserProfile(
        uid: user.uid,
        email: user.email,
        username: user.username,
        bio: user.bio,
        avatarUrl: user.avatarUrl,
        followerCount: followerCount,
        followingCount: followingCount,
        postCount: postCount,
      );
}
