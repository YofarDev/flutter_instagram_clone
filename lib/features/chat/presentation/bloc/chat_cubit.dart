import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';

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
  }) : _conversation = conversation,
       super(ChatState(conversation: conversation)) {
    _sub = _repository
        .watchMessages(conversationId: conversation.id)
        .listen(
          (List<ChatMessage> messages) {
            if (isClosed) return;
            emit(state.copyWith(messages: messages));
            _markIncomingRead(messages);
          },
          onError: (Object e) {
            if (isClosed) return;
            emit(state.copyWith(error: 'Failed to load messages'));
          },
        );
    _typingSub = _repository
        .watchTyping(conversationId: conversation.id)
        .listen((String? typingUid) {
          if (isClosed) return;
          // ponytail: field trusted as-is; writer self-clears after 4s
          emit(
            state.copyWith(
              otherTyping: typingUid == conversation.otherUser.uid,
            ),
          );
        }, onError: (Object _) {});
  }

  static const Duration _typingTimeout = Duration(seconds: 4);

  final IChatRepository _repository;
  final Conversation _conversation;
  final String _myUid;
  StreamSubscription<List<ChatMessage>>? _sub;
  StreamSubscription<String?>? _typingSub;
  Timer? _typingTimer;
  bool _typingSent = false;

  /// Typing lifecycle: first keystroke flags, idle timeout / send / empty
  /// input clears. One write per state change, not per keystroke.
  void onInputChanged(String text) {
    if (text.trim().isNotEmpty) {
      _markTyping();
    } else {
      _clearTyping();
    }
  }

  void _markTyping() {
    if (_typingSent) {
      _typingTimer?.cancel();
    } else {
      _typingSent = true;
      _repository
          .setTyping(
            conversationId: _conversation.id,
            myUid: _myUid,
            typing: true,
          )
          .then((_) {}, onError: (Object _) {});
    }
    _typingTimer?.cancel();
    _typingTimer = Timer(_typingTimeout, _clearTyping);
  }

  void _clearTyping() {
    _typingTimer?.cancel();
    _typingTimer = null;
    if (!_typingSent) return;
    _typingSent = false;
    _repository
        .setTyping(
          conversationId: _conversation.id,
          myUid: _myUid,
          typing: false,
        )
        .then((_) {}, onError: (Object _) {});
  }

  Future<void> send(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty || state.sending) return;
    _clearTyping();
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

  /// Picks one image (camera or gallery) and sends it as an image message.
  Future<void> pickAndSendImage(ImageSource source) async {
    if (state.sending) return;
    XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1080,
        imageQuality: 70,
      );
    } catch (_) {
      // ponytail: plugin cancel/permission errors — nothing sensible to show
      return;
    }
    if (isClosed || picked == null) return;
    _clearTyping();
    emit(state.copyWith(sending: true, error: null));
    final Either<Failure, void> either = await _repository.sendImageMessage(
      conversationId: _conversation.id,
      myUid: _myUid,
      otherUid: _conversation.otherUser.uid,
      filePath: picked.path,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(sending: false, error: f.message)),
      (_) => emit(state.copyWith(sending: false)),
    );
  }

  void clearError() => emit(state.copyWith(error: null));

  /// Read receipts: stamp every incoming unread message as read while this
  /// screen is open. Failure is silent — the next emission retries.
  void _markIncomingRead(List<ChatMessage> messages) {
    final List<String> unread = messages
        .where((ChatMessage m) => m.senderId != _myUid && m.readAt == null)
        .map((ChatMessage m) => m.id)
        .toList();
    if (unread.isEmpty) return;
    _repository
        .markMessagesRead(
          conversationId: _conversation.id,
          myUid: _myUid,
          messageIds: unread,
        )
        .then((_) {}, onError: (Object _) {});
  }

  @override
  Future<void> close() {
    _clearTyping();
    _sub?.cancel();
    _typingSub?.cancel();
    return super.close();
  }
}
