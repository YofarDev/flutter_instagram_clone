import '../../domain/models/chat_message.dart';

class ChatMessageDto {
  const ChatMessageDto({
    required this.senderId,
    required this.text,
    required this.createdAtMillis,
    this.type = 'text',
    this.imageUrl,
  });

  factory ChatMessageDto.fromMap(Map<String, dynamic> map) => ChatMessageDto(
    senderId: map['senderId'] as String,
    text: map['text'] as String? ?? '',
    createdAtMillis: map['createdAt'] as int,
    type: map['type'] as String? ?? 'text',
    imageUrl: map['imageUrl'] as String?,
  );

  final String senderId;
  final String text;
  final int createdAtMillis;
  final String type;
  final String? imageUrl;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'senderId': senderId,
    'text': text,
    'createdAt': createdAtMillis,
    'type': type,
    if (imageUrl != null) 'imageUrl': imageUrl,
  };

  ChatMessage toDomain(String id, String conversationId) => ChatMessage(
    id: id,
    conversationId: conversationId,
    senderId: senderId,
    text: text,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
    type: type,
    imageUrl: imageUrl,
  );
}
