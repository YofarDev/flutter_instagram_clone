import 'package:freezed_annotation/freezed_annotation.dart';

import 'story.dart';

part 'story_tray.freezed.dart';

@freezed
sealed class StoryTray with _$StoryTray {
  const factory StoryTray({
    required String uid,
    required String username,
    String? avatarUrl,
    required List<Story> stories, // asc by createdAt
  }) = _StoryTray;
}
