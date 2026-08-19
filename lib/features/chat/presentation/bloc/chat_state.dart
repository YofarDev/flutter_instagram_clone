import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/chat_message.dart';
import '../../domain/models/conversation.dart';

part 'chat_state.freezed.dart';

@freezed
sealed class ChatState with _$ChatState {
  const factory ChatState({
    required Conversation conversation,
    @Default(<ChatMessage>[]) List<ChatMessage> messages,
    @Default(false) bool sending,
    @Default(false) bool otherTyping,
    String? error,
  }) = _ChatState;
}
