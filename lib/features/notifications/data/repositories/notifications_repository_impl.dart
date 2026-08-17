import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../domain/models/notification_item.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_firebase_datasource.dart';

class NotificationsRepositoryImpl implements INotificationsRepository {
  const NotificationsRepositoryImpl(this._ds);

  final INotificationsDataSource _ds;

  @override
  Stream<List<NotificationItem>> watchNotifications({required String uid}) =>
      _ds.watchNotifications(uid: uid);

  @override
  Future<Either<Failure, void>> markAllRead({required String uid}) async {
    try {
      return Right<Failure, void>(await _ds.markAllRead(uid: uid));
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> createNotification({
    required String ownerUid,
    required NotificationType type,
    required String actorId,
    required String actorUsername,
    String? actorAvatarUrl,
    String? postId,
    String? postImageUrl,
    String? commentText,
  }) async {
    try {
      return Right<Failure, void>(await _ds.createNotificationDoc(
        ownerUid: ownerUid,
        type: type,
        actorId: actorId,
        actorUsername: actorUsername,
        actorAvatarUrl: actorAvatarUrl,
        postId: postId,
        postImageUrl: postImageUrl,
        commentText: commentText,
      ));
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  Failure _mapError(Object e) =>
      Failure.serverError(message: e.toString()); // ponytail: firestore errors are descriptive strings
}
