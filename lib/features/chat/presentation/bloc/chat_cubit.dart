import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/conversation.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_state.dart';

class ChatArgs {
  const ChatArgs({required this.conversation, required this.myUid});

  final Conversation conversation;
  final String myUid;
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(
    this._repository, {
    required Conversation conversation,
    required this._myUid,
  })  : _conversation = conversation,
        super(ChatState(conversation: conversation)) {
    _sub = _repository
        .watchMessages(conversationId: conversation.id)
        .listen((List<ChatMessage> messages) {
      if (isClosed) return;
      emit(state.copyWith(messages: messages));
    }, onError: (Object e) {
      if (isClosed) return;
      emit(state.copyWith(error: 'Failed to load messages'));
    });
  }

  final IChatRepository _repository;
  final Conversation _conversation;
  final String _myUid;
  StreamSubscription<List<ChatMessage>>? _sub;

  Future<void> send(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return;
    emit(state.copyWith(sending: true, error: null));
    final Either<Failure, void> either = await _repository.sendMessage(
      conversationId: _conversation.id,
      myUid: _myUid,
      otherUid: _conversation.otherUser.uid,
      text: trimmed,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(sending: false, error: f.message)),
      (_) => emit(state.copyWith(sending: false)),
    );
    // ponytail: no optimistic append — live snapshot delivers
  }

  void clearError() => emit(state.copyWith(error: null));

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
