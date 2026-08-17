import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/app_user.dart';

part 'conversation.freezed.dart';

@freezed
sealed class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required AppUser otherUser,
    @Default('') String lastMessageText,
    String? lastMessageSenderId,
    DateTime? lastMessageAt,
  }) = _Conversation;
}
