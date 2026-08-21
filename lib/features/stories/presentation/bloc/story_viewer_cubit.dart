import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../chat/domain/models/conversation.dart';
import '../../../chat/domain/repositories/chat_repository.dart';
import '../../../../core/models/failure.dart';
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
    this._repository,
    this._chatRepository, {
    required List<StoryTray> trays,
    required int initialTrayIndex,
    required this._myUid,
  }) : super(StoryViewerState(trays: trays, trayIndex: initialTrayIndex));

  final IStoriesRepository _repository;
  final IChatRepository _chatRepository;
  final String _myUid;

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

  /// Sends [text] as a DM quoting the current story to its author.
  Future<void> reply(String text) async {
    final Story? story = currentStory;
    final String trimmed = text.trim();
    if (story == null || trimmed.isEmpty || state.replySent) return;
    final String authorUid = state.trays[state.trayIndex].uid;
    String? failure;
    Conversation? conversation;
    (await _chatRepository.getOrCreateConversation(
      myUid: _myUid,
      otherUid: authorUid,
    )).fold((Failure f) => failure = f.message, (Conversation c) {
      conversation = c;
    });
    if (isClosed) return;
    if (conversation == null) {
      emit(state.copyWith(error: failure));
      return;
    }
    final Either<Failure, void> either = await _chatRepository.sendStoryReply(
      conversationId: conversation!.id,
      myUid: _myUid,
      otherUid: authorUid,
      text: trimmed,
      storyId: story.id,
      imageUrl: story.imageUrl,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(error: f.message)),
      (_) => emit(state.copyWith(replySent: true)),
    );
  }

  void clearError() => emit(state.copyWith(error: null));

  void clearReplySent() => emit(state.copyWith(replySent: false));
}
