import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/notifications/domain/models/notification_item.dart';
import 'package:flutter_instagram_clone/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:flutter_instagram_clone/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:flutter_instagram_clone/features/notifications/presentation/bloc/notifications_state.dart';

class MockNotificationsRepository extends Mock
    implements INotificationsRepository {}

NotificationItem item(String id, {bool read = false}) => NotificationItem(
  id: id,
  type: NotificationType.like,
  ownerUid: 'u1',
  actorId: 'actor-$id',
  actorUsername: 'actor',
  createdAt: DateTime(2026, 1, 1),
  read: read,
);

void main() {
  late MockNotificationsRepository repo;

  setUp(() {
    repo = MockNotificationsRepository();
  });

  blocTest<NotificationsCubit, NotificationsState>(
    'init → ready with items and unreadCount (2 of 3 unread)',
    build: () {
      when(() => repo.watchNotifications(uid: 'u1')).thenAnswer(
        (_) => Stream<List<NotificationItem>>.value(<NotificationItem>[
          item('1'),
          item('2', read: true),
          item('3'),
        ]),
      );
      return NotificationsCubit(repo);
    },
    act: (NotificationsCubit cubit) => cubit.init('u1'),
    expect: () => <NotificationsState>[
      NotificationsState(
        status: NotificationsStatus.ready,
        items: <NotificationItem>[item('1'), item('2', read: true), item('3')],
        unreadCount: 2,
      ),
    ],
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'markAllRead success → unread 0 via re-emitted snapshot',
    build: () {
      final StreamController<List<NotificationItem>> controller =
          StreamController<List<NotificationItem>>();
      when(
        () => repo.watchNotifications(uid: 'u1'),
      ).thenAnswer((_) => controller.stream);
      when(() => repo.markAllRead(uid: 'u1')).thenAnswer((_) async {
        controller.add(<NotificationItem>[
          item('1', read: true),
          item('2', read: true),
        ]);
        return const Right<Failure, void>(null);
      });
      return NotificationsCubit(repo);
    },
    act: (NotificationsCubit cubit) async {
      cubit.init('u1');
      await cubit.markAllRead();
    },
    verify: (_) {
      verify(() => repo.markAllRead(uid: 'u1')).called(1);
    },
    expect: () => <NotificationsState>[
      NotificationsState(
        status: NotificationsStatus.ready,
        items: <NotificationItem>[item('1', read: true), item('2', read: true)],
        unreadCount: 0,
      ),
    ],
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'stream error → error set',
    build: () {
      when(() => repo.watchNotifications(uid: 'u1')).thenAnswer(
        (_) => Stream<List<NotificationItem>>.error(Exception('boom')),
      );
      return NotificationsCubit(repo);
    },
    act: (NotificationsCubit cubit) => cubit.init('u1'),
    expect: () => const <NotificationsState>[
      NotificationsState(error: 'Failed to load notifications'),
    ],
  );

  blocTest<NotificationsCubit, NotificationsState>(
    'double init same uid → single subscription',
    build: () {
      when(
        () => repo.watchNotifications(uid: 'u1'),
      ).thenAnswer((_) => const Stream<List<NotificationItem>>.empty());
      return NotificationsCubit(repo);
    },
    act: (NotificationsCubit cubit) {
      cubit.init('u1');
      cubit.init('u1');
    },
    verify: (_) {
      verify(() => repo.watchNotifications(uid: 'u1')).called(1);
    },
    expect: () => const <NotificationsState>[],
  );
}
