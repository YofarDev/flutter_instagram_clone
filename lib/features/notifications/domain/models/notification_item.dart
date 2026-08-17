import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_item.freezed.dart';

enum NotificationType { like, comment, follow }

@freezed
sealed class NotificationItem with _$NotificationItem {
  const factory NotificationItem({
    required String id,
    required NotificationType type,
    required String ownerUid,
    required String actorId,
    required String actorUsername,
    String? actorAvatarUrl,
    String? postId,
    String? postImageUrl,
    String? commentText,
    required DateTime createdAt,
    @Default(false) bool read,
  }) = _NotificationItem;
}
