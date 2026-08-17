import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/models/conversation.dart';

part 'conversations_state.freezed.dart';

enum ConversationsStatus { loading, ready }

@freezed
sealed class ConversationsState with _$ConversationsState {
  const factory ConversationsState({
    @Default(ConversationsStatus.loading) ConversationsStatus status,
    @Default(<Conversation>[]) List<Conversation> conversations,
    String? error,
  }) = _ConversationsState;
}
