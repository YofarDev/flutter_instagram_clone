import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/post.dart';
import '../../domain/models/user_profile.dart';

part 'profile_state.freezed.dart';

enum ProfileStatus { loading, ready }

@freezed
sealed class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(ProfileStatus.loading) ProfileStatus status,
    UserProfile? profile,
    @Default(<Post>[]) List<Post> posts,
    @Default(<Post>[]) List<Post> savedPosts,
    @Default(true) bool savedLoading,
    @Default(false) bool isFollowing,
    @Default(false) bool isMe,
    @Default(true) bool hasMore,
    String? error,
  }) = _ProfileState;
}
