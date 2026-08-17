import '../../domain/models/notification_item.dart';

class NotificationDto {
  const NotificationDto({
    required this.ownerUid,
    required this.type,
    required this.actorId,
    required this.actorUsername,
    this.actorAvatarUrl,
    this.postId,
    this.postImageUrl,
    this.commentText,
    required this.createdAtMillis,
    required this.read,
  });

  factory NotificationDto.fromMap(String id, Map<String, dynamic> map) =>
      NotificationDto(
        ownerUid: map['ownerUid'] as String,
        type: NotificationType.values.byName(map['type'] as String),
        actorId: map['actorId'] as String,
        actorUsername: map['actorUsername'] as String,
        actorAvatarUrl: map['actorAvatarUrl'] as String?,
        postId: map['postId'] as String?,
        postImageUrl: map['postImageUrl'] as String?,
        commentText: map['commentText'] as String?,
        createdAtMillis: map['createdAt'] as int,
        read: map['read'] as bool? ?? false,
      );

  final String ownerUid;
  final NotificationType type;
  final String actorId;
  final String actorUsername;
  final String? actorAvatarUrl;
  final String? postId;
  final String? postImageUrl;
  final String? commentText;
  final int createdAtMillis;
  final bool read;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'ownerUid': ownerUid,
        'type': type.name,
        'actorId': actorId,
        'actorUsername': actorUsername,
        'actorAvatarUrl': actorAvatarUrl,
        'postId': postId,
        'postImageUrl': postImageUrl,
        'commentText': commentText,
        'createdAt': createdAtMillis,
        'read': read,
      };

  NotificationItem toDomain(String id) => NotificationItem(
        id: id,
        type: type,
        ownerUid: ownerUid,
        actorId: actorId,
        actorUsername: actorUsername,
        actorAvatarUrl: actorAvatarUrl,
        postId: postId,
        postImageUrl: postImageUrl,
        commentText: commentText,
        createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
        read: read,
      );
}
