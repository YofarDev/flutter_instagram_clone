import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/notification_item.dart';
import '../models/notification_dto.dart';

abstract interface class INotificationsDataSource {
  Stream<List<NotificationItem>> watchNotifications({required String uid});
  Future<void> markAllRead({required String uid});
  Future<void> createNotificationDoc({
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

class NotificationsFirebaseDataSource implements INotificationsDataSource {
  const NotificationsFirebaseDataSource();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  @override
  Stream<List<NotificationItem>> watchNotifications({required String uid}) =>
      _db
          .collection('notifications')
          .where('ownerUid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((QuerySnapshot<Object?> snap) => snap.docs
              .map((QueryDocumentSnapshot<Object?> doc) =>
                  NotificationDto.fromMap(
                          doc.id, doc.data() as Map<String, dynamic>)
                      .toDomain(doc.id))
              .toList());

  // ponytail: unread capped at 50 per pass; badge drift above that
  @override
  Future<void> markAllRead({required String uid}) async {
    final QuerySnapshot<Object?> snap = await _db
        .collection('notifications')
        .where('ownerUid', isEqualTo: uid)
        .where('read', isEqualTo: false)
        .limit(50)
        .get();
    final WriteBatch batch = _db.batch();
    for (final QueryDocumentSnapshot<Object?> doc in snap.docs) {
      batch.update(doc.reference, <String, dynamic>{'read': true});
    }
    await batch.commit();
  }

  @override
  Future<void> createNotificationDoc({
    required String ownerUid,
    required NotificationType type,
    required String actorId,
    required String actorUsername,
    String? actorAvatarUrl,
    String? postId,
    String? postImageUrl,
    String? commentText,
  }) =>
      _db.collection('notifications').add(NotificationDto(
            ownerUid: ownerUid,
            type: type,
            actorId: actorId,
            actorUsername: actorUsername,
            actorAvatarUrl: actorAvatarUrl,
            postId: postId,
            postImageUrl: postImageUrl,
            commentText: commentText,
            createdAtMillis: DateTime.now().millisecondsSinceEpoch,
            read: false,
          ).toMap());
}
