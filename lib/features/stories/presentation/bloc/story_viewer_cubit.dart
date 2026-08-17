import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/story.dart';
import '../../domain/models/story_tray.dart';
import '../../domain/repositories/stories_repository.dart';
import 'story_viewer_state.dart';

class StoryViewerArgs {
  const StoryViewerArgs({required this.trays, required this.initialTrayIndex});

  final List<StoryTray> trays;
  final int initialTrayIndex;
}

class StoryViewerCubit extends Cubit<StoryViewerState> {
  StoryViewerCubit(
    this._repository, {
    required List<StoryTray> trays,
    required int initialTrayIndex,
  }) : super(StoryViewerState(trays: trays, trayIndex: initialTrayIndex));

  final IStoriesRepository _repository;

  Story? get currentStory {
    if (state.trayIndex >= state.trays.length) return null;
    final StoryTray tray = state.trays[state.trayIndex];
    if (state.storyIndex >= tray.stories.length) return null;
    return tray.stories[state.storyIndex];
  }

  void init() => _markViewed(currentStory);

  void next() {
    if (state.finished) return;
    _markViewed(currentStory);
    final StoryTray tray = state.trays[state.trayIndex];
    if (state.storyIndex + 1 < tray.stories.length) {
      emit(state.copyWith(storyIndex: state.storyIndex + 1));
    } else if (state.trayIndex + 1 < state.trays.length) {
      emit(state.copyWith(trayIndex: state.trayIndex + 1, storyIndex: 0));
    } else {
      emit(state.copyWith(finished: true));
    }
  }

  void previous() {
    if (state.storyIndex > 0) {
      emit(state.copyWith(storyIndex: state.storyIndex - 1));
    } else if (state.trayIndex > 0) {
      final List<Story> prevStories = state.trays[state.trayIndex - 1].stories;
      emit(
        state.copyWith(
          trayIndex: state.trayIndex - 1,
          storyIndex: prevStories.length - 1,
        ),
      );
    }
  }

  // ponytail: fire-and-forget; a lost view-mark is invisible to the viewer
  void _markViewed(Story? story) {
    if (story == null) return;
    unawaited(_repository.markViewed(storyId: story.id));
    emit(state.copyWith(viewedIds: <String>{...state.viewedIds, story.id}));
  }
}
