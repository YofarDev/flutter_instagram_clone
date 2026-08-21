import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/story_tray.dart';

part 'story_viewer_state.freezed.dart';

@freezed
sealed class StoryViewerState with _$StoryViewerState {
  const factory StoryViewerState({
    required List<StoryTray> trays,
    @Default(0) int trayIndex,
    @Default(0) int storyIndex,
    @Default(<String>{}) Set<String> viewedIds,
    @Default(false) bool finished,

    /// Story replies: last reply landed (drives the Sent toast).
    @Default(false) bool replySent,
    String? error,
  }) = _StoryViewerState;
}
