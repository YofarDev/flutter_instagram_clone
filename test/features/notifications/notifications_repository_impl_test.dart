import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/notifications/data/datasources/notifications_firebase_datasource.dart';
import 'package:flutter_instagram_clone/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:flutter_instagram_clone/features/notifications/domain/models/notification_item.dart';

class MockNotificationsDataSource extends Mock
    implements INotificationsDataSource {}

final NotificationItem item = NotificationItem(
  id: 'n1',
  type: NotificationType.like,
  ownerUid: 'u1',
  actorId: 'u2',
  actorUsername: 'yo',
  createdAt: DateTime.fromMillisecondsSinceEpoch(0),
);

void main() {
  late MockNotificationsDataSource ds;
  late NotificationsRepositoryImpl repo;

  setUp(() {
    ds = MockNotificationsDataSource();
    repo = NotificationsRepositoryImpl(ds);
  });

  test(
    'watchNotifications passes datasource stream through unchanged',
    () async {
      when(() => ds.watchNotifications(uid: 'u1')).thenAnswer(
        (_) => Stream<List<NotificationItem>>.value(<NotificationItem>[item]),
      );

      final List<List<NotificationItem>> emitted = await repo
          .watchNotifications(uid: 'u1')
          .toList();

      expect(emitted, <List<NotificationItem>>[
        <NotificationItem>[item],
      ]);
      verify(() => ds.watchNotifications(uid: 'u1')).called(1);
    },
  );

  test('watchNotifications surfaces stream errors via onError', () async {
    when(() => ds.watchNotifications(uid: 'u1')).thenAnswer(
      (_) => Stream<List<NotificationItem>>.error(Exception('db down')),
    );

    await expectLater(
      repo.watchNotifications(uid: 'u1').toList(),
      throwsA(isA<Exception>()),
    );
  });

  test('markAllRead returns Right(null) and forwards uid', () async {
    when(() => ds.markAllRead(uid: 'u1')).thenAnswer((_) async {});

    final Either<Failure, void> result = await repo.markAllRead(uid: 'u1');

    expect(result, const Right<Failure, void>(null));
    verify(() => ds.markAllRead(uid: 'u1')).called(1);
  });

  test(
    'markAllRead returns Left(Failure.serverError) when datasource throws',
    () async {
      when(() => ds.markAllRead(uid: 'u1')).thenThrow(Exception('batch boom'));

      final Either<Failure, void> result = await repo.markAllRead(uid: 'u1');

      final Failure? failure = result.fold((Failure f) => f, (_) => null);
      expect(failure, isNotNull);
      expect(failure!.message, contains('batch boom'));
    },
  );

  test(
    'createNotification returns Right(null) and forwards all params',
    () async {
      when(
        () => ds.createNotificationDoc(
          ownerUid: 'u1',
          type: NotificationType.comment,
          actorId: 'u2',
          actorUsername: 'yo',
          actorAvatarUrl: 'http://img/a',
          postId: 'p1',
          postImageUrl: 'http://img/p',
          commentText: 'nice',
        ),
      ).thenAnswer((_) async {});

      final Either<Failure, void> result = await repo.createNotification(
        ownerUid: 'u1',
        type: NotificationType.comment,
        actorId: 'u2',
        actorUsername: 'yo',
        actorAvatarUrl: 'http://img/a',
        postId: 'p1',
        postImageUrl: 'http://img/p',
        commentText: 'nice',
      );

      expect(result, const Right<Failure, void>(null));
      verify(
        () => ds.createNotificationDoc(
          ownerUid: 'u1',
          type: NotificationType.comment,
          actorId: 'u2',
          actorUsername: 'yo',
          actorAvatarUrl: 'http://img/a',
          postId: 'p1',
          postImageUrl: 'http://img/p',
          commentText: 'nice',
        ),
      ).called(1);
    },
  );

  test(
    'createNotification returns Left(Failure.serverError) when datasource throws',
    () async {
      when(
        () => ds.createNotificationDoc(
          ownerUid: 'u1',
          type: NotificationType.follow,
          actorId: 'u2',
          actorUsername: 'yo',
        ),
      ).thenThrow(Exception('write denied'));

      final Either<Failure, void> result = await repo.createNotification(
        ownerUid: 'u1',
        type: NotificationType.follow,
        actorId: 'u2',
        actorUsername: 'yo',
      );

      final Failure? failure = result.fold((Failure f) => f, (_) => null);
      expect(failure, isNotNull);
      expect(failure!.message, contains('write denied'));
    },
  );
}
