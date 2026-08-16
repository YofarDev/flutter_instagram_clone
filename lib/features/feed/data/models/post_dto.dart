import '../../domain/models/post.dart';

class PostDto {
  const PostDto({
    required this.authorId,
    required this.authorUsername,
    this.authorAvatarUrl,
    required this.imageUrl,
    this.caption = '',
    required this.createdAtMillis,
    this.likeCount = 0,
    this.commentCount = 0,
  });

  factory PostDto.fromMap(String id, Map<String, dynamic> map) => PostDto(
        authorId: map['authorId'] as String,
        authorUsername: map['authorUsername'] as String,
        authorAvatarUrl: map['authorAvatarUrl'] as String?,
        imageUrl: map['imageUrl'] as String,
        caption: map['caption'] as String? ?? '',
        createdAtMillis: map['createdAt'] as int,
        likeCount: map['likeCount'] as int? ?? 0,
        commentCount: map['commentCount'] as int? ?? 0,
      );

  final String authorId;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String imageUrl;
  final String caption;
  final int createdAtMillis;
  final int likeCount;
  final int commentCount;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'authorId': authorId,
        'authorUsername': authorUsername,
        'authorAvatarUrl': authorAvatarUrl,
        'imageUrl': imageUrl,
        'caption': caption,
        'createdAt': createdAtMillis,
        'likeCount': likeCount,
        'commentCount': commentCount,
      };

  Post toDomain(String id) => Post(
        id: id,
        authorId: authorId,
        authorUsername: authorUsername,
        authorAvatarUrl: authorAvatarUrl,
        imageUrl: imageUrl,
        caption: caption,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
        likeCount: likeCount,
        commentCount: commentCount,
      );
}
