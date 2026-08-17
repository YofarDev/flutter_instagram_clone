import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/l10n/generated/app_localizations.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/notifications/domain/models/notification_item.dart';
import 'package:flutter_instagram_clone/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:flutter_instagram_clone/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:flutter_instagram_clone/features/notifications/presentation/screens/activity_screen.dart';

class MockNotificationsRepository extends Mock
    implements INotificationsRepository {}

NotificationItem _item({
  required String id,
  required NotificationType type,
  required String actorId,
  required String actorUsername,
  bool read = false,
  String? postImageUrl,
  String? commentText,
}) => NotificationItem(
  id: id,
  type: type,
  ownerUid: 'me',
  actorId: actorId,
  actorUsername: actorUsername,
  postImageUrl: postImageUrl,
  postId: postImageUrl != null ? 'post-$id' : null,
  commentText: commentText,
  createdAt: DateTime(2026, 1, 1),
  read: read,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockNotificationsRepository repo;
  late NotificationsCubit cubit;

  setUp(() {
    repo = MockNotificationsRepository();
    cubit = NotificationsCubit(repo);
    when(
      () => repo.markAllRead(uid: any(named: 'uid')),
    ).thenAnswer((_) async => const Right<Failure, void>(null));
  });

  tearDown(() async => cubit.close());

  Future<void> pumpSubject(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<NotificationsCubit>.value(
          value: cubit,
          child: const ActivityScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('renders rows per notification type', (
    WidgetTester tester,
  ) async {
    when(() => repo.watchNotifications(uid: 'me')).thenAnswer(
      (_) => Stream<List<NotificationItem>>.value(<NotificationItem>[
        _item(
          id: 'n1',
          type: NotificationType.like,
          actorId: 'a1',
          actorUsername: 'alice',
          read: true,
          postImageUrl: 'http://t',
        ),
        _item(
          id: 'n2',
          type: NotificationType.comment,
          actorId: 'a2',
          actorUsername: 'bob',
          commentText: 'nice',
        ),
        _item(
          id: 'n3',
          type: NotificationType.follow,
          actorId: 'a3',
          actorUsername: 'carol',
        ),
      ]),
    );
    cubit.init('me');

    await pumpSubject(tester);

    expect(find.textContaining('alice'), findsOneWidget);
    expect(find.textContaining('liked your post'), findsOneWidget);
    expect(find.textContaining('bob'), findsOneWidget);
    expect(find.textContaining('commented: nice'), findsOneWidget);
    expect(find.textContaining('carol'), findsOneWidget);
    expect(find.textContaining('started following you'), findsOneWidget);
  });

  testWidgets('markAllRead called on mount', (WidgetTester tester) async {
    when(() => repo.watchNotifications(uid: 'me')).thenAnswer(
      (_) => Stream<List<NotificationItem>>.value(<NotificationItem>[]),
    );
    cubit.init('me');

    await pumpSubject(tester);

    verify(() => repo.markAllRead(uid: 'me')).called(1);
  });

  testWidgets('empty stream shows empty state', (WidgetTester tester) async {
    when(() => repo.watchNotifications(uid: 'me')).thenAnswer(
      (_) => Stream<List<NotificationItem>>.value(<NotificationItem>[]),
    );
    cubit.init('me');

    await pumpSubject(tester);

    expect(find.text('No activity yet'), findsOneWidget);
  });
}
