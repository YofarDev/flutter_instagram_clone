import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/l10n/generated/app_localizations.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/core/router/route_constants.dart';
import 'package:flutter_instagram_clone/features/stories/domain/models/story.dart';
import 'package:flutter_instagram_clone/features/stories/domain/models/story_tray.dart';
import 'package:flutter_instagram_clone/features/stories/domain/repositories/stories_repository.dart';
import 'package:flutter_instagram_clone/features/stories/presentation/bloc/story_viewer_cubit.dart';
import 'package:flutter_instagram_clone/features/stories/presentation/screens/story_viewer_screen.dart';

class MockIStoriesRepository extends Mock implements IStoriesRepository {}

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

  testWidgets('tap right zone advances story', (WidgetTester tester) async {
    final StoryViewerCubit cubit = StoryViewerCubit(
      repo,
      trays: trays,
      initialTrayIndex: 0,
    );
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<StoryViewerCubit>.value(
          value: cubit,
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
    final StoryViewerCubit cubit = StoryViewerCubit(
      repo,
      trays: trays,
      initialTrayIndex: 0,
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
          builder: (_, _) => BlocProvider<StoryViewerCubit>.value(
            value: cubit,
            child: const StoryViewerScreen(),
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
