import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nested/nested.dart';

import 'package:flutter_instagram_clone/core/l10n/generated/app_localizations.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/auth/domain/models/app_user.dart';
import 'package:flutter_instagram_clone/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_instagram_clone/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_instagram_clone/features/feed/domain/models/post.dart';
import 'package:flutter_instagram_clone/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/feed_cubit.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/screens/feed_screen.dart';

class MockFeedRepository extends Mock implements IFeedRepository {}

class MockAuthRepository extends Mock implements IAuthRepository {}

Post _post() => Post(
      id: 'p1',
      authorId: 'u1',
      authorUsername: 'alice',
      imageUrl: 'http://x',
      caption: 'hello world',
      createdAt: DateTime(2026, 1, 1),
      likeCount: 3,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFeedRepository repo;
  late Completer<Either<Failure, void>> toggleGate;

  setUpAll(() => registerFallbackValue(_post()));

  setUp(() {
    repo = MockFeedRepository();
    toggleGate = Completer<Either<Failure, void>>();
    when(() => repo.watchFeed(limit: any(named: 'limit')))
        .thenAnswer((_) => Stream<List<Post>>.value(<Post>[_post()]));
    when(() => repo.fetchLikedPostIds(postIds: any(named: 'postIds')))
        .thenAnswer(
            (_) async => const Right<Failure, Set<String>>(<String>{}));
    when(() => repo.toggleLike(
          post: any(named: 'post'),
          currentlyLiked: any(named: 'currentlyLiked'),
        )).thenAnswer((_) => toggleGate.future);
  });

  Widget subject() {
    final MockAuthRepository authRepo = MockAuthRepository();
    when(() => authRepo.authStateChanges)
        .thenAnswer((_) => const Stream<AppUser?>.empty());
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: <SingleChildWidget>[
          BlocProvider<AuthCubit>(create: (_) => AuthCubit(authRepo)),
          BlocProvider<FeedCubit>(create: (_) => FeedCubit(repo)),
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

  testWidgets('like tap on feed rebuilds via likedIds change and fills heart',
      (WidgetTester tester) async {
    await pumpSubject(tester);

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();

    // toggling changes likedIds (and post likeCount) without touching status
    // or posts.length — the buildWhen path Fix 1 restored
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(find.text('4 likes'), findsOneWidget);

    verify(() => repo.toggleLike(
          post: any(named: 'post'),
          currentlyLiked: false,
        )).called(1);
  });
}
