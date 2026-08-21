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
import 'package:flutter_instagram_clone/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_instagram_clone/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_instagram_clone/features/chat/domain/repositories/chat_repository.dart';
import 'package:flutter_instagram_clone/core/router/route_constants.dart';
import 'package:flutter_instagram_clone/features/stories/domain/models/story.dart';
import 'package:flutter_instagram_clone/features/stories/domain/models/story_tray.dart';
import 'package:flutter_instagram_clone/features/stories/domain/repositories/stories_repository.dart';
import 'package:flutter_instagram_clone/features/stories/presentation/bloc/story_viewer_cubit.dart';
import 'package:flutter_instagram_clone/features/stories/presentation/screens/story_viewer_screen.dart';

class MockIStoriesRepository extends Mock implements IStoriesRepository {}

class MockIAuthRepository extends Mock implements IAuthRepository {}

class MockIChatRepositoryForViewer extends Mock implements IChatRepository {}

final Story a1 = Story(
  id: 'a1',
  uid: 'u1',
  authorUsername: 'alice',
  imageUrl: 'http://img/a1',
  createdAt: DateTime(2026, 1, 1, 10),
);
final Story a2 = Story(
  id: 'a2',
  uid: 'u1',
  authorUsername: 'alice',
  imageUrl: 'http://img/a2',
  createdAt: DateTime(2026, 1, 1, 11),
);
final Story b1 = Story(
  id: 'b1',
  uid: 'u2',
  authorUsername: 'bob',
  imageUrl: 'http://img/b1',
  createdAt: DateTime(2026, 1, 1, 12),
);
final List<StoryTray> trays = <StoryTray>[
  StoryTray(uid: 'u1', username: 'alice', stories: <Story>[a1, a2]),
  StoryTray(uid: 'u2', username: 'bob', stories: <Story>[b1]),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockIStoriesRepository repo;

  setUp(() {
    repo = MockIStoriesRepository();
    when(
      () => repo.markViewed(storyId: any(named: 'storyId')),
    ).thenAnswer((_) async => const Right<Failure, void>(null));
  });

  // AuthCubit state must be hydrated before the screen's first build: the
  // reply bar reads `state.user!.uid` to hide itself on your own stories.
  Future<AuthCubit> authedCubit() async {
    final MockIAuthRepository authRepo = MockIAuthRepository();
    when(
      () => authRepo.authStateChanges,
    ).thenAnswer(
      (_) => Stream<AppUser?>.value(
        AppUser(uid: 'me', email: 'me@x.com', username: 'me'),
      ),
    );
    when(
      () => authRepo.findProfile(
        uid: any(named: 'uid'),
        email: any(named: 'email'),
      ),
    ).thenAnswer(
      (_) async => Right<Failure, AppUser?>(
        AppUser(uid: 'me', email: 'me@x.com', username: 'me'),
      ),
    );
    final AuthCubit cubit = AuthCubit(authRepo);
    for (int i = 0; i < 20; i++) {
      await Future<void>.value();
    }
    return cubit;
  }

  testWidgets('tap right zone advances story', (WidgetTester tester) async {
    final AuthCubit authCubit = await authedCubit();
    final StoryViewerCubit cubit = StoryViewerCubit(
      repo,
      MockIChatRepositoryForViewer(),
      trays: trays,
      initialTrayIndex: 0,
      myUid: 'me',
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: <SingleChildWidget>[
            BlocProvider<AuthCubit>.value(value: authCubit),
            BlocProvider<StoryViewerCubit>.value(value: cubit),
          ],
          child: const StoryViewerScreen(),
        ),
      ),
    );
    await tester.pump();

    final Size size = tester.getSize(find.byType(Scaffold));
    await tester.tapAt(Offset(size.width * 0.7, size.height * 0.6));
    await tester.pump();

    expect(cubit.state.trayIndex, 0);
    expect(cubit.state.storyIndex, 1);
    verify(
      () => repo.markViewed(storyId: 'a1'),
    ).called(greaterThanOrEqualTo(1));
  });

  testWidgets('finishing all stories pops back', (WidgetTester tester) async {
    final AuthCubit authCubit = await authedCubit();
    final StoryViewerCubit cubit = StoryViewerCubit(
      repo,
      MockIChatRepositoryForViewer(),
      trays: trays,
      initialTrayIndex: 0,
      myUid: 'me',
    );
    addTearDown(cubit.close);

    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) =>
              const Scaffold(body: Center(child: Text('home-marker'))),
        ),
        GoRoute(
          path: Routes.storyViewer,
          builder: (BuildContext ctx, _) =>
              BlocProvider<StoryViewerCubit>.value(
                value: cubit,
                child: BlocProvider<AuthCubit>.value(
                  value: authCubit,
                  child: const StoryViewerScreen(),
                ),
              ),
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
    router.push(Routes.storyViewer);
    await tester.pump();
    // fixed pumps: pumpAndSettle would fast-forward the 5s story timer + tween
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(StoryViewerScreen), findsOneWidget);

    // 3 stories total -> third next() finishes and the listener pops
    cubit
      ..next()
      ..next()
      ..next();
    await tester.pump();
    // fixed pumps: pumpAndSettle would fast-forward the 5s story timer + tween
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(); // process completed reverse transition + dispose

    expect(cubit.state.finished, isTrue);
    expect(find.byType(StoryViewerScreen), findsNothing);
    expect(find.text('home-marker'), findsOneWidget);
  });
}
