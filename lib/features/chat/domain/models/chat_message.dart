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

    /// 'text', 'image', 'post' or 'story' — image messages carry
    /// [imageUrl] instead of text; post shares and story replies carry
    /// [imageUrl] plus the source id in [postId].
    @Default('text') String type,
    String? imageUrl,

    /// Post id for shared posts, story id for story replies.
    String? postId,

    /// Set by the recipient opening the conversation; null = unread.
    DateTime? readAt,
  }) = _ChatMessage;

  bool get isImage => type == 'image';

  bool get isPost => type == 'post';

  bool get isStory => type == 'story';
}
