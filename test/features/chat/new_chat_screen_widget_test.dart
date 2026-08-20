import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/l10n/generated/app_localizations.dart';
import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/core/router/route_constants.dart';
import 'package:flutter_instagram_clone/features/chat/domain/models/conversation.dart';
import 'package:flutter_instagram_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_instagram_clone/features/chat/presentation/bloc/new_chat_cubit.dart';
import 'package:flutter_instagram_clone/features/chat/presentation/screens/new_chat_screen.dart';
import 'package:flutter_instagram_clone/features/explore/domain/repositories/explore_repository.dart';

class MockChatRepository extends Mock implements IChatRepository {}

class MockExploreRepository extends Mock implements IExploreRepository {}

AppUser _alice() => AppUser(uid: 'u1', email: 'a@b.c', username: 'alice');

Conversation _conversation() => Conversation(id: 'c1', otherUser: _alice());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockExploreRepository exploreRepo;
  late MockChatRepository chatRepo;

  setUp(() {
    exploreRepo = MockExploreRepository();
    when(
      () => exploreRepo.fetchSuggestedUsers(
        myUid: any(named: 'myUid'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => Completer<Either<Failure, List<AppUser>>>().future);
    chatRepo = MockChatRepository();
    when(() => exploreRepo.searchUsers(query: 'al')).thenAnswer(
      (_) async => Right<Failure, List<AppUser>>(<AppUser>[_alice()]),
    );
    when(
      () => chatRepo.getOrCreateConversation(myUid: 'me', otherUid: 'u1'),
    ).thenAnswer((_) async => Right<Failure, Conversation>(_conversation()));
  });

  testWidgets('search shows user row and tap opens conversation', (
    WidgetTester tester,
  ) async {
    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) => BlocProvider<NewChatCubit>(
            create: (_) => NewChatCubit(exploreRepo, chatRepo, myUid: 'me'),
            child: const NewChatScreen(),
          ),
        ),
        GoRoute(
          path: Routes.chat,
          builder: (_, _) => const Scaffold(body: Text('CHAT SCREEN')),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );

    await tester.enterText(find.byType(TextField), 'al');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    await tester.pump();

    expect(find.text('alice'), findsOneWidget);

    await tester.tap(find.text('alice'));
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    verify(
      () => chatRepo.getOrCreateConversation(myUid: 'me', otherUid: 'u1'),
    ).called(1);
  });
}
