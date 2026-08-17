import '../../domain/models/chat_message.dart';

class ChatMessageDto {
  const ChatMessageDto({
    required this.senderId,
    required this.text,
    required this.createdAtMillis,
  });

  factory ChatMessageDto.fromMap(Map<String, dynamic> map) => ChatMessageDto(
        senderId: map['senderId'] as String,
        text: map['text'] as String,
        createdAtMillis: map['createdAt'] as int,
      );

  final String senderId;
  final String text;
  final int createdAtMillis;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'senderId': senderId,
        'text': text,
        'createdAt': createdAtMillis,
      };

  ChatMessage toDomain(String id, String conversationId) => ChatMessage(
        id: id,
        conversationId: conversationId,
        senderId: senderId,
        text: text,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      );
}
