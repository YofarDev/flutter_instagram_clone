import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../domain/models/story.dart';
import '../../domain/models/story_tray.dart';
import '../../domain/repositories/stories_repository.dart';
import 'stories_state.dart';

class StoriesCubit extends Cubit<StoriesState> {
  StoriesCubit(this._repository, {required this._myUid})
    : super(const StoriesState()) {
    _subscribe();
  }

  final IStoriesRepository _repository;
  final String _myUid;
  StreamSubscription<List<Story>>? _sub;
  int _gen = 0;

  void _subscribe() {
    _sub?.cancel();
    final int gen = ++_gen;
    _sub = _repository.watchStories().listen(
      (List<Story> stories) => _onStories(stories, gen),
      onError: (Object e) {
        if (isClosed) return;
        emit(state.copyWith(error: 'Failed to load stories'));
      },
    );
  }

  Future<void> _onStories(List<Story> stories, int gen) async {
    if (isClosed || gen != _gen) return;
    final List<StoryTray> trays = _group(stories);
    final Either<Failure, Set<String>> either = await _repository
        .fetchViewedStoryIds(storyIds: stories.map((Story s) => s.id).toList());
    if (isClosed || gen != _gen) return;
    either.fold(
      (_) => emit(
        state.copyWith(status: StoriesStatus.ready, trays: trays),
      ), // ponytail: keep stale viewedIds on hydration failure
      (Set<String> ids) => emit(
        state.copyWith(
          status: StoriesStatus.ready,
          trays: trays,
          viewedIds: ids,
        ),
      ),
    );
  }

  List<StoryTray> _group(List<Story> stories) {
    final Map<String, List<Story>> byUid = <String, List<Story>>{};
    for (final Story s in stories) {
      byUid.putIfAbsent(s.uid, () => <Story>[]).add(s);
    }
    final List<StoryTray> trays = byUid.entries.map((
      MapEntry<String, List<Story>> e,
    ) {
      final List<Story> asc = e.value
        ..sort((Story a, Story b) => a.createdAt.compareTo(b.createdAt));
      final Story latest = asc.last;
      return StoryTray(
        uid: e.key,
        username: latest.authorUsername,
        avatarUrl: latest.authorAvatarUrl,
        stories: asc,
      );
    }).toList();
    trays.sort((StoryTray a, StoryTray b) {
      if (a.uid == _myUid) return b.uid == _myUid ? 0 : -1;
      if (b.uid == _myUid) return 1;
      return b.stories.last.createdAt.compareTo(a.stories.last.createdAt);
    });
    return trays;
  }

  void clearError() => emit(state.copyWith(error: null));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
