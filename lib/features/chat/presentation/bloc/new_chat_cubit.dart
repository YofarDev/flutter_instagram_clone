import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/models/failure.dart';
import '../../../../core/models/post.dart';
import '../../../explore/domain/repositories/explore_repository.dart';
import '../../domain/models/conversation.dart';
import '../../domain/repositories/chat_repository.dart';
import 'new_chat_state.dart';

class NewChatCubit extends Cubit<NewChatState> {
  NewChatCubit(
    this._exploreRepository,
    this._chatRepository, {
    required this._myUid,
    this._sharedPost,
  }) : super(const NewChatState()) {
    loadSuggestions();
  }

  final IExploreRepository _exploreRepository;
  final IChatRepository _chatRepository;
  final String _myUid;

  /// When set, picking a user shares this post instead of opening the chat.
  final Post? _sharedPost;

  // ponytail: Timer debounce in cubit, mirrors SearchCubit
  Timer? _debounce;

  void queryChanged(String query) {
    emit(state.copyWith(query: query, error: null));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _runSearch);
  }

  Future<void> _runSearch() async {
    final String q = state.query.trim().toLowerCase();
    if (q.isEmpty) {
      emit(state.copyWith(users: <AppUser>[], searching: false));
      return;
    }
    emit(state.copyWith(searching: true));
    final Either<Failure, List<AppUser>> either = await _exploreRepository
        .searchUsers(query: q);
    if (isClosed || q != state.query.trim().toLowerCase()) return;
    either.fold(
      (Failure f) => emit(state.copyWith(searching: false, error: f.message)),
      (List<AppUser> users) =>
          emit(state.copyWith(searching: false, users: users)),
    );
  }

  Future<void> startConversation(AppUser user) async {
    if (state.opening) return;
    emit(state.copyWith(opening: true, error: null));
    final Either<Failure, Conversation> either = await _chatRepository
        .getOrCreateConversation(myUid: _myUid, otherUid: user.uid);
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(opening: false, error: f.message)),
      (Conversation conversation) =>
          emit(state.copyWith(opening: false, opened: conversation)),
    );
  }

  /// Share mode: drops the pending post into [conversation]. The screen
  /// reacts to `shared` with a Sent toast and pops.
  Future<void> shareTo(Conversation conversation) async {
    final Post? post = _sharedPost;
    if (post == null || state.shared) return;
    final Either<Failure, void> either = await _chatRepository.sendPostMessage(
      conversationId: conversation.id,
      myUid: _myUid,
      otherUid: conversation.otherUser.uid,
      postId: post.id,
      imageUrl: post.imageUrl,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(error: f.message)),
      (_) => emit(state.copyWith(shared: true)),
    );
  }

  /// Most-followed people you don't follow yet — fills the empty-query
  /// state so the screen isn't a dead end before the first keystroke.
  Future<void> loadSuggestions() async {
    final Either<Failure, List<AppUser>> either = await _exploreRepository
        .fetchSuggestedUsers(myUid: _myUid, limit: 12);
    if (isClosed) return;
    either.fold(
      (_) => emit(state.copyWith(suggestionsLoading: false)),
      (List<AppUser> users) =>
          emit(state.copyWith(suggestions: users, suggestionsLoading: false)),
    );
  }

  void clearError() => emit(state.copyWith(error: null));

  void clearOpened() => emit(state.copyWith(opened: null));

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
