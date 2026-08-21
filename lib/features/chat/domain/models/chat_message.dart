import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

@freezed
sealed class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required String conversationId,
    required String senderId,
    @Default('') String text,
    required DateTime createdAt,

    /// 'text' or 'image' — image messages carry [imageUrl] instead of text.
    @Default('text') String type,
    String? imageUrl,

    /// Set by the recipient opening the conversation; null = unread.
    DateTime? readAt,
  }) = _ChatMessage;

  bool get isImage => type == 'image';
}
