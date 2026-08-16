import '../../domain/models/comment.dart';

class CommentDto {
  const CommentDto({
    required this.authorId,
    required this.authorUsername,
    required this.text,
    required this.createdAtMillis,
  });

  factory CommentDto.fromMap(String id, Map<String, dynamic> map) => CommentDto(
        authorId: map['authorId'] as String,
        authorUsername: map['authorUsername'] as String,
        text: map['text'] as String,
        createdAtMillis: map['createdAt'] as int,
      );

  final String authorId;
  final String authorUsername;
  final String text;
  final int createdAtMillis;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'authorId': authorId,
        'authorUsername': authorUsername,
        'text': text,
        'createdAt': createdAtMillis,
      };

  Comment toDomain(String id, String postId) => Comment(
        id: id,
        postId: postId,
        authorId: authorId,
        authorUsername: authorUsername,
        text: text,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      );
}
