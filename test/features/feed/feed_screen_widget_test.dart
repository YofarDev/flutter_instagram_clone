import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nested/nested.dart';

import 'package:flutter_instagram_clone/core/l10n/generated/app_localizations.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_instagram_clone/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_instagram_clone/core/models/post.dart';
import 'package:flutter_instagram_clone/core/widgets/ig_icon.dart';
import 'package:flutter_instagram_clone/core/widgets/ig_icons.dart';
import 'package:flutter_instagram_clone/core/widgets/skeleton/skeletons.dart';
import 'package:flutter_instagram_clone/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/feed_cubit.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/screens/feed_screen.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/widgets/post_card.dart';
import 'package:flutter_instagram_clone/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:flutter_instagram_clone/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:flutter_instagram_clone/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_instagram_clone/features/stories/domain/models/story.dart';
import 'package:flutter_instagram_clone/features/stories/domain/repositories/stories_repository.dart';
import 'package:flutter_instagram_clone/features/stories/presentation/bloc/stories_cubit.dart';

class MockFeedRepository extends Mock implements IFeedRepository {}

class MockProfileRepository extends Mock implements IProfileRepository {}

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockStoriesRepository extends Mock implements IStoriesRepository {}

class MockNotificationsRepository extends Mock
    implements INotificationsRepository {}

Post _post() => Post(
  id: 'p1',
  authorId: 'u1',
  authorUsername: 'alice',
  imageUrls: <String>['http://x'],
  caption: 'hello world',
  createdAt: DateTime(2026, 1, 1),
  likeCount: 3,
);

Finder _heartIcon({required bool filled}) => find.byWidgetPredicate(
  (Widget w) =>
      w is IgIcon &&
      (filled ? w.data == IgIcons.heartFilled : w.data == IgIcons.heart),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFeedRepository repo;
  late MockProfileRepository profileRepo;
  late MockStoriesRepository storiesRepo;
  late MockNotificationsRepository notificationsRepo;
  late Completer<Either<Failure, void>> toggleGate;

  setUpAll(() => registerFallbackValue(_post()));

  setUp(() {
    repo = MockFeedRepository();
    profileRepo = MockProfileRepository();
    storiesRepo = MockStoriesRepository();
    notificationsRepo = MockNotificationsRepository();
    toggleGate = Completer<Either<Failure, void>>();
    when(
      () => repo.watchFeed(limit: any(named: 'limit')),
    ).thenAnswer((_) => Stream<List<Post>>.value(<Post>[_post()]));
    when(
      () => profileRepo.watchFollowingIds(uid: any(named: 'uid')),
    ).thenAnswer((_) => const Stream<List<String>>.empty());
    when(
      () => repo.fetchLikedPostIds(postIds: any(named: 'postIds')),
    ).thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));
    when(
      () => repo.fetchSavedPostIds(postIds: any(named: 'postIds')),
    ).thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));
    when(
      () => repo.toggleLike(
        post: any(named: 'post'),
        currentlyLiked: any(named: 'currentlyLiked'),
      ),
    ).thenAnswer((_) => toggleGate.future);
    when(
      () => storiesRepo.watchStories(),
    ).thenAnswer((_) => const Stream<List<Story>>.empty());
    when(
      () => storiesRepo.fetchViewedStoryIds(storyIds: any(named: 'storyIds')),
    ).thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));
  });

  Widget subject() {
    final MockAuthRepository authRepo = MockAuthRepository();
    when(
      () => authRepo.authStateChanges,
    ).thenAnswer((_) => const Stream<AppUser?>.empty());
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: <SingleChildWidget>[
          BlocProvider<AuthCubit>(create: (_) => AuthCubit(authRepo)),
          BlocProvider<FeedCubit>(
            create: (_) => FeedCubit(repo, profileRepo, myUid: 'u1'),
          ),
          BlocProvider<StoriesCubit>(
            create: (_) => StoriesCubit(storiesRepo, myUid: 'u1'),
          ),
          // shell provides the cubit above the feed branch — mirror that here
          BlocProvider<NotificationsCubit>(
            create: (_) => NotificationsCubit(notificationsRepo),
          ),
        ],
        child: const FeedScreen(),
      ),
    );
  }

  Future<void> pumpSubject(WidgetTester tester) async {
    // narrow surface keeps the like row on-screen under the square image
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(subject());
    await tester.pump();
    await tester.pump();
  }

  testWidgets('like tap on feed rebuilds via likedIds change and fills heart', (
    WidgetTester tester,
  ) async {
    await pumpSubject(tester);

    // scope to the post card — the appbar activity badge also paints a heart
    final Finder cardHeart = find.descendant(
      of: find.byType(PostCard),
      matching: _heartIcon(filled: false),
    );
    expect(cardHeart, findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(PostCard),
        matching: _heartIcon(filled: true),
      ),
      findsNothing,
    );

    await tester.tap(cardHeart);
    await tester.pump();

    // toggling changes likedIds (and post likeCount) without touching status
    // or posts.length — the buildWhen path Fix 1 restored
    expect(
      find.descendant(
        of: find.byType(PostCard),
        matching: _heartIcon(filled: true),
      ),
      findsOneWidget,
    );
    expect(cardHeart, findsNothing);
    expect(find.text('4 likes'), findsOneWidget);

    verify(
      () => repo.toggleLike(post: any(named: 'post'), currentlyLiked: false),
    ).called(1);
  });

  testWidgets('cold load renders skeleton post cards', (
    WidgetTester tester,
  ) async {
    when(
      () => repo.watchFeed(limit: any(named: 'limit')),
    ).thenAnswer((_) => const Stream<List<Post>>.empty());

    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(subject());
    await tester.pump();

    expect(find.byType(SkeletonPostCard), findsNWidgets(2));
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('appbar shows heart and plane, no logout, no FAB', (
    WidgetTester tester,
  ) async {
    await pumpSubject(tester);

    expect(find.byTooltip('Activity'), findsOneWidget);
    // navConversations l10n value is "Messages" in both locales
    expect(find.byTooltip('Messages'), findsOneWidget);
    expect(find.byIcon(Icons.logout), findsNothing);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
