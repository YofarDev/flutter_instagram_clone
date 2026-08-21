import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nested/nested.dart';

import 'package:flutter_instagram_clone/core/l10n/generated/app_localizations.dart';
import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/core/router/route_constants.dart';
import 'package:flutter_instagram_clone/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_instagram_clone/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_instagram_clone/features/chat/domain/models/conversation.dart';
import 'package:flutter_instagram_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_instagram_clone/features/chat/presentation/bloc/conversations_cubit.dart';
import 'package:flutter_instagram_clone/features/chat/presentation/screens/conversations_screen.dart';

class MockChatRepository extends Mock implements IChatRepository {}

class MockAuthRepository extends Mock implements IAuthRepository {}

AppUser _me() => AppUser(uid: 'me', email: 'me@x.com', username: 'me');

Conversation _conversation() => Conversation(
  id: 'c1',
  otherUser: AppUser(uid: 'u1', email: 'a@b.c', username: 'alice'),
  lastMessageText: 'hello',
  lastMessageSenderId: 'me',
  lastMessageAt: DateTime.now(),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockChatRepository repo;
  late Conversation conversation;

  setUp(() {
    repo = MockChatRepository();
    conversation = _conversation();
    when(() => repo.watchConversations(myUid: 'me')).thenAnswer(
      (_) => Stream<List<Conversation>>.value(<Conversation>[conversation]),
    );
  });

  // AuthCubit state must be hydrated before the screen's first build:
  // ConversationsScreen reads `state.user!` at the top of build.
  // Drains microtasks only — timers never fire in fake async.
  Future<AuthCubit> authedCubit() async {
    final MockAuthRepository authRepo = MockAuthRepository();
    when(
      () => authRepo.authStateChanges,
    ).thenAnswer((_) => Stream<AppUser?>.value(_me()));
    when(
      () => authRepo.findProfile(
        uid: any(named: 'uid'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((_) async => Right<Failure, AppUser?>(_me()));
    final AuthCubit cubit = AuthCubit(authRepo);
    for (int i = 0; i < 20; i++) {
      await Future<void>.value();
    }
    return cubit;
  }

  Widget providersChild(Widget child, AuthCubit authCubit) {
    return MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<ConversationsCubit>(
          create: (_) => ConversationsCubit(repo, myUid: 'me'),
        ),
      ],
      child: child,
    );
  }

  Future<void> pumpSubject(WidgetTester tester) async {
    final AuthCubit authCubit = await authedCubit();
    addTearDown(authCubit.close);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: providersChild(const ConversationsScreen(), authCubit),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('rows render other user, You-prefixed preview, and time', (
    WidgetTester tester,
  ) async {
    await pumpSubject(tester);

    expect(find.text('alice'), findsOneWidget);
    expect(find.text('You: hello'), findsOneWidget);
    expect(find.text('now'), findsOneWidget);
    expect(find.byType(Badge), findsNothing);
  });

  testWidgets('unread conversations render a count badge', (
    WidgetTester tester,
  ) async {
    conversation = _conversation().copyWith(unreadCount: 3);
    await pumpSubject(tester);

    expect(find.byType(Badge), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('tap row pushes chat route with conversation as extra', (
    WidgetTester tester,
  ) async {
    final AuthCubit authCubit = await authedCubit();
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) =>
              providersChild(const ConversationsScreen(), authCubit),
        ),
        GoRoute(
          path: Routes.chat,
          builder: (_, _) => const Scaffold(body: Text('CHAT SCREEN')),
        ),
      ],
    );
    addTearDown(authCubit.close);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.text('alice'));
    await tester.pumpAndSettle();

    expect(find.text('CHAT SCREEN'), findsOneWidget);
  });
}
