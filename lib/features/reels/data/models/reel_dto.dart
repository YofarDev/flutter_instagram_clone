import '../../domain/models/reel.dart';

class ReelDto {
  const ReelDto({
    required this.uid,
    required this.authorUsername,
    this.authorAvatarUrl,
    required this.videoUrl,
    required this.caption,
    required this.createdAtMillis,
    required this.likeCount,
  });

  factory ReelDto.fromMap(String id, Map<String, dynamic> map) => ReelDto(
        uid: map['uid'] as String,
        authorUsername: map['username'] as String,
        authorAvatarUrl: map['avatarUrl'] as String?,
        videoUrl: map['videoUrl'] as String,
        caption: map['caption'] as String? ?? '',
        createdAtMillis: map['createdAt'] as int,
        likeCount: map['likeCount'] as int? ?? 0,
      );

  final String uid;
  final String authorUsername;
  final String? authorAvatarUrl;
  final String videoUrl;
  final String caption;
  final int createdAtMillis;
  final int likeCount;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'uid': uid,
        'username': authorUsername,
        'avatarUrl': authorAvatarUrl,
        'videoUrl': videoUrl,
        'caption': caption,
        'createdAt': createdAtMillis,
        'likeCount': likeCount,
      };

  Reel toDomain(String id) => Reel(
        id: id,
        uid: uid,
        authorUsername: authorUsername,
        authorAvatarUrl: authorAvatarUrl,
        videoUrl: videoUrl,
        caption: caption,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
        likeCount: likeCount,
      );
}
