import '../../domain/models/story.dart';

class StoryDto {
  const StoryDto({
    required this.uid,
    required this.authorUsername,
    this.authorAvatarUrl,
    required this.imageUrl,
    required this.createdAtMillis,
  });

  factory StoryDto.fromMap(String id, Map<String, dynamic> map) => StoryDto(
        uid: map['uid'] as String,
        authorUsername: map['username'] as String,
        authorAvatarUrl: map['avatarUrl'] as String?,
        imageUrl: map['imageUrl'] as String,
        createdAtMillis: map['createdAt'] as int,
      );

  final String uid;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String imageUrl;
  final int createdAtMillis;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'uid': uid,
        'username': authorUsername,
        'avatarUrl': authorAvatarUrl,
        'imageUrl': imageUrl,
        'createdAt': createdAtMillis,
      };

  Story toDomain(String id) => Story(
        id: id,
        uid: uid,
        authorUsername: authorUsername,
        authorAvatarUrl: authorAvatarUrl,
        imageUrl: imageUrl,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      );
}
