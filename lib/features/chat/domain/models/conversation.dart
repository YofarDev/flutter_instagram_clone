import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/models/app_user.dart';

part 'conversation.freezed.dart';

@freezed
sealed class Conversation with _$Conversation {
  const Conversation._();

  const factory Conversation({
    required String id,
    required AppUser otherUser,
    @Default('') String lastMessageText,
    String? lastMessageSenderId,
    DateTime? lastMessageAt,

    /// 'text' or 'image' — image previews render a localized "Photo".
    @Default('text') String lastMessageType,

    /// Messages from the other user I haven't read yet (denormalized).
    @Default(0) int unreadCount,
  }) = _Conversation;

  bool get lastMessageIsImage => lastMessageType == 'image';

  bool get lastMessageIsPost => lastMessageType == 'post';

  bool get lastMessageIsStory => lastMessageType == 'story';
}
