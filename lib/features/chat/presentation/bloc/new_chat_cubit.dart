import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/models/failure.dart';
import '../../../explore/domain/repositories/explore_repository.dart';
import '../../domain/models/conversation.dart';
import '../../domain/repositories/chat_repository.dart';
import 'new_chat_state.dart';

class NewChatCubit extends Cubit<NewChatState> {
  NewChatCubit(
    this._exploreRepository,
    this._chatRepository, {
    required this._myUid,
  })  : super(const NewChatState());

  final IExploreRepository _exploreRepository;
  final IChatRepository _chatRepository;
  final String _myUid;

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
    final Either<Failure, List<AppUser>> either =
        await _exploreRepository.searchUsers(query: q);
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
    final Either<Failure, Conversation> either =
        await _chatRepository.getOrCreateConversation(
      myUid: _myUid,
      otherUid: user.uid,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(opening: false, error: f.message)),
      (Conversation conversation) => emit(
        state.copyWith(opening: false, opened: conversation),
      ),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
