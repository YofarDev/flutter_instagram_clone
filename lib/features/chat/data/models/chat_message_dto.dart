import '../../domain/models/chat_message.dart';

class ChatMessageDto {
  const ChatMessageDto({
    required this.senderId,
    required this.text,
    required this.createdAtMillis,
    this.type = 'text',
    this.imageUrl,
    this.postId,
    this.readAtMillis,
  });

  factory ChatMessageDto.fromMap(Map<String, dynamic> map) => ChatMessageDto(
    senderId: map['senderId'] as String,
    text: map['text'] as String? ?? '',
    createdAtMillis: map['createdAt'] as int,
    type: map['type'] as String? ?? 'text',
    imageUrl: map['imageUrl'] as String?,
    postId: map['postId'] as String?,
    readAtMillis: map['readAt'] as int?,
  );

  final String senderId;
  final String text;
  final int createdAtMillis;
  final String type;
  final String? imageUrl;
  final String? postId;
  final int? readAtMillis;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'senderId': senderId,
    'text': text,
    'createdAt': createdAtMillis,
    'type': type,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (postId != null) 'postId': postId,
  };

  ChatMessage toDomain(String id, String conversationId) => ChatMessage(
    id: id,
    conversationId: conversationId,
    senderId: senderId,
    text: text,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
    type: type,
    imageUrl: imageUrl,
    postId: postId,
    readAt: readAtMillis == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(readAtMillis!),
  );
}
