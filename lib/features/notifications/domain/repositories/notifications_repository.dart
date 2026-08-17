import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../models/notification_item.dart';

abstract interface class INotificationsRepository {
  Stream<List<NotificationItem>> watchNotifications({required String uid});
  Future<Either<Failure, void>> markAllRead({required String uid});
  Future<Either<Failure, void>> createNotification({
    required String ownerUid,
    required NotificationType type,
    required String actorId,
    required String actorUsername,
    String? actorAvatarUrl,
    String? postId,
    String? postImageUrl,
    String? commentText,
  });
}
