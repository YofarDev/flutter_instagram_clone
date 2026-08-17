import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/conversation.dart';
import '../../domain/repositories/chat_repository.dart';
import 'conversations_state.dart';

class ConversationsCubit extends Cubit<ConversationsState> {
  ConversationsCubit(this._repository, {required String myUid})
    : super(const ConversationsState()) {
    _sub = _repository
        .watchConversations(myUid: myUid)
        .listen(
          (List<Conversation> conversations) {
            if (isClosed) return;
            emit(
              state.copyWith(
                status: ConversationsStatus.ready,
                conversations: conversations,
              ),
            );
          },
          onError: (Object e) {
            if (isClosed) return;
            emit(state.copyWith(error: 'Failed to load conversations'));
          },
        );
  }

  final IChatRepository _repository;
  StreamSubscription<List<Conversation>>? _sub;

  void clearError() => emit(state.copyWith(error: null));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
