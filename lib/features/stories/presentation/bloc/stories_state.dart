import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/story_tray.dart';

part 'stories_state.freezed.dart';

enum StoriesStatus { loading, ready }

@freezed
sealed class StoriesState with _$StoriesState {
  const factory StoriesState({
    @Default(StoriesStatus.loading) StoriesStatus status,
    @Default(<StoryTray>[]) List<StoryTray> trays,
    @Default(<String>{}) Set<String> viewedIds,
    String? error,
  }) = _StoriesState;
}
