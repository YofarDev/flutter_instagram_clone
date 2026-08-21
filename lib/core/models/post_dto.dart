import './post.dart';

class PostDto {
  const PostDto({
    required this.authorId,
    required this.authorUsername,
    this.authorAvatarUrl,
    required this.imageUrls,
    this.caption = '',
    required this.createdAtMillis,
    this.likeCount = 0,
    this.commentCount = 0,
    this.tags = const <String>[],
  });

  factory PostDto.fromMap(String id, Map<String, dynamic> map) => PostDto(
    authorId: map['authorId'] as String,
    authorUsername: map['authorUsername'] as String,
    authorAvatarUrl: map['authorAvatarUrl'] as String?,
    // pre-carousel docs only carry imageUrl; keep reading them
    imageUrls:
        ((map['imageUrls'] as List<dynamic>?) ?? <dynamic>[map['imageUrl']])
            .map((dynamic e) => e as String)
            .toList(),
    caption: map['caption'] as String? ?? '',
    createdAtMillis: map['createdAt'] as int,
    likeCount: map['likeCount'] as int? ?? 0,
    commentCount: map['commentCount'] as int? ?? 0,
    tags: ((map['tags'] as List<dynamic>?) ?? <dynamic>[])
        .map((dynamic e) => e as String)
        .toList(),
  );

  final String authorId;
  final String authorUsername;
  final String? authorAvatarUrl;
  final List<String> imageUrls;
  final String caption;
  final int createdAtMillis;
  final int likeCount;
  final int commentCount;
  final List<String> tags;

  Map<String, dynamic> toMap() => <String, dynamic>{
    'authorId': authorId,
    'authorUsername': authorUsername,
    'authorAvatarUrl': authorAvatarUrl,
    // cover kept as a scalar for old readers; imageUrls is the source of truth
    'imageUrl': imageUrls.first,
    'imageUrls': imageUrls,
    'caption': caption,
    'createdAt': createdAtMillis,
    'likeCount': likeCount,
    'commentCount': commentCount,
    'tags': tags,
  };

  Post toDomain(String id) => Post(
    id: id,
    authorId: authorId,
    authorUsername: authorUsername,
    authorAvatarUrl: authorAvatarUrl,
    imageUrls: imageUrls,
    caption: caption,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
    likeCount: likeCount,
    commentCount: commentCount,
    tags: tags,
  );
}
