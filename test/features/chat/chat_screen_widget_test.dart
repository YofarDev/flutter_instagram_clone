import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nested/nested.dart';

import 'package:flutter_instagram_clone/core/l10n/generated/app_localizations.dart';
import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_instagram_clone/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_instagram_clone/features/chat/domain/models/chat_message.dart';
import 'package:flutter_instagram_clone/features/chat/domain/models/conversation.dart';
import 'package:flutter_instagram_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_instagram_clone/features/chat/presentation/bloc/chat_cubit.dart';
import 'package:flutter_instagram_clone/features/chat/presentation/screens/chat_screen.dart';

class MockChatRepository extends Mock implements IChatRepository {}

class MockAuthRepository extends Mock implements IAuthRepository {}

AppUser _me() => AppUser(uid: 'me', email: 'me@x.com', username: 'me');

Conversation _conversation() => Conversation(
  id: 'c1',
  otherUser: AppUser(uid: 'u1', email: 'a@b.c', username: 'alice'),
);

ChatMessage _message({
  required String id,
  required String senderId,
  required String text,
}) => ChatMessage(
  id: id,
  conversationId: 'c1',
  senderId: senderId,
  text: text,
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockChatRepository repo;

  setUp(() {
    repo = MockChatRepository();
    when(() => repo.watchMessages(conversationId: 'c1')).thenAnswer(
      (_) => Stream<List<ChatMessage>>.value(<ChatMessage>[
        _message(id: 'm1', senderId: 'u1', text: 'hi'),
        _message(id: 'm2', senderId: 'me', text: 'yo there'),
      ]),
    );
    when(
      () => repo.sendMessage(
        conversationId: 'c1',
        myUid: 'me',
        otherUid: 'u1',
        text: 'new msg',
      ),
    ).thenAnswer((_) async => const Right<Failure, void>(null));
  });

  // AuthCubit state must be hydrated before the screen's first build:
  // ChatScreen reads `state.user!` at the top of build.
  // Drains microtasks only — timers never fire in fake async.
  Future<Widget> subject() async {
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
    final AuthCubit authCubit = AuthCubit(authRepo);
    for (int i = 0; i < 20; i++) {
      await Future<void>.value();
    }
    addTearDown(authCubit.close);
    return MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<ChatCubit>(
          create: (_) =>
              ChatCubit(repo, conversation: _conversation(), myUid: 'me'),
        ),
      ],
      child: const ChatScreen(),
    );
  }

  Future<void> pumpSubject(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: await subject(),
      ),
    );
    await tester.pump();
    await tester.pump();
  }

  testWidgets('messages render with both alignments', (
    WidgetTester tester,
  ) async {
    await pumpSubject(tester);

    expect(find.text('hi'), findsOneWidget);
    expect(find.text('yo there'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (Widget w) => w is Align && w.alignment == Alignment.centerLeft,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (Widget w) => w is Align && w.alignment == Alignment.centerRight,
      ),
      findsOneWidget,
    );
  });

  testWidgets('send tap sends trimmed text and clears input', (
    WidgetTester tester,
  ) async {
    await pumpSubject(tester);

    await tester.enterText(find.byType(TextField), '  new msg  ');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    await tester.pump();

    verify(
      () => repo.sendMessage(
        conversationId: 'c1',
        myUid: 'me',
        otherUid: 'u1',
        text: 'new msg',
      ),
    ).called(1);
    expect(find.text('new msg'), findsNothing);
  });
}
