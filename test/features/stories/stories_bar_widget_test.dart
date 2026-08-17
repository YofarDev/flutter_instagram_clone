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
import 'package:flutter_instagram_clone/features/stories/domain/models/story.dart';
import 'package:flutter_instagram_clone/features/stories/domain/repositories/stories_repository.dart';
import 'package:flutter_instagram_clone/features/stories/presentation/bloc/stories_cubit.dart';
import 'package:flutter_instagram_clone/features/stories/presentation/widgets/stories_bar.dart';
import 'package:flutter_instagram_clone/features/stories/presentation/widgets/story_tray_avatar.dart';

class MockIAuthRepository extends Mock implements IAuthRepository {}

class MockIStoriesRepository extends Mock implements IStoriesRepository {}

final AppUser me = AppUser(uid: 'me', email: 'me@x.com', username: 'me');

final Story mineStory = Story(
  id: 'mine-1',
  uid: 'me',
  authorUsername: 'me',
  imageUrl: 'http://img/mine',
  createdAt: DateTime(2026, 1, 1, 9),
);
final Story aliceT2 = Story(
  id: 'alice-2',
  uid: 'u2',
  authorUsername: 'alice',
  imageUrl: 'http://img/a2',
  createdAt: DateTime(2026, 1, 1, 10),
);
final Story aliceT3 = Story(
  id: 'alice-3',
  uid: 'u2',
  authorUsername: 'alice',
  imageUrl: 'http://img/a3',
  createdAt: DateTime(2026, 1, 1, 11),
);

Widget providersChild(Widget child) => MultiBlocProvider(
  providers: <SingleChildWidget>[
    BlocProvider<AuthCubit>(create: (_) => AuthCubit(mockAuthRepo)),
    BlocProvider<StoriesCubit>(
      create: (_) => StoriesCubit(mockStoriesRepo, myUid: 'me'),
    ),
  ],
  child: Scaffold(body: child),
);

late MockIAuthRepository mockAuthRepo;
late MockIStoriesRepository mockStoriesRepo;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    mockAuthRepo = MockIAuthRepository();
    mockStoriesRepo = MockIStoriesRepository();
    when(
      () => mockAuthRepo.authStateChanges,
    ).thenAnswer((_) => Stream<AppUser?>.value(me));
    when(
      () => mockAuthRepo.findProfile(
        uid: any(named: 'uid'),
        email: any(named: 'email'),
      ),
    ).thenAnswer((_) async => Right<Failure, AppUser?>(me));
  });

  Future<void> pumpBar(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: providersChild(const StoriesBar()),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump();
  }

  testWidgets('renders trays with own first and Your story label', (
    WidgetTester tester,
  ) async {
    when(() => mockStoriesRepo.watchStories()).thenAnswer(
      (_) => Stream<List<Story>>.value(<Story>[aliceT2, mineStory, aliceT3]),
    );
    when(
      () =>
          mockStoriesRepo.fetchViewedStoryIds(storyIds: any(named: 'storyIds')),
    ).thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));

    await pumpBar(tester);

    // own tray first, then alice's grouped tray (2 stories asc)
    expect(find.byType(StoryTrayAvatar), findsNWidgets(2));
    expect(find.text('Your story'), findsOneWidget);
    expect(find.text('alice'), findsOneWidget);
  });

  testWidgets('viewed tray ring is grey, unviewed is pink', (
    WidgetTester tester,
  ) async {
    when(() => mockStoriesRepo.watchStories()).thenAnswer(
      (_) => Stream<List<Story>>.value(<Story>[aliceT2, mineStory, aliceT3]),
    );
    // alice's stories already viewed -> grey; mine never viewed -> pink
    when(
      () =>
          mockStoriesRepo.fetchViewedStoryIds(storyIds: any(named: 'storyIds')),
    ).thenAnswer(
      (_) async =>
          const Right<Failure, Set<String>>(<String>{'alice-2', 'alice-3'}),
    );

    await pumpBar(tester);

    int ringCount(Color color) => find
        .byWidgetPredicate((Widget w) {
          if (w is! Container) return false;
          final Decoration? d = w.decoration;
          if (d is! BoxDecoration || d.border is! Border) return false;
          return (d.border as Border).top.color == color;
        })
        .evaluate()
        .length;

    expect(ringCount(Colors.grey), 1);
    expect(ringCount(Colors.pinkAccent), 1);
  });

  testWidgets('empty stories shows single own tray and taps through', (
    WidgetTester tester,
  ) async {
    when(
      () => mockStoriesRepo.watchStories(),
    ).thenAnswer((_) => const Stream<List<Story>>.empty());

    final GoRouter router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (_, _) => providersChild(const StoriesBar()),
        ),
        GoRoute(
          path: Routes.createStory,
          builder: (_, _) => const Scaffold(body: Text('create-story-marker')),
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
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.byType(StoryTrayAvatar), findsOneWidget);
    expect(find.text('Your story'), findsOneWidget);

    await tester.tap(find.byType(CircleAvatar).first);
    await tester.pumpAndSettle();

    expect(find.text('create-story-marker'), findsOneWidget);
  });
}
