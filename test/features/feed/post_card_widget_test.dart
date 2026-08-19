import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/l10n/generated/app_localizations.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/core/models/post.dart';
import 'package:flutter_instagram_clone/core/theme/ig_colors.dart';
import 'package:flutter_instagram_clone/core/widgets/heart_burst.dart';
import 'package:flutter_instagram_clone/core/widgets/ig_icon.dart';
import 'package:flutter_instagram_clone/core/widgets/ig_icons.dart';
import 'package:flutter_instagram_clone/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/feed_cubit.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/feed_state.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/widgets/post_card.dart';
import 'package:flutter_instagram_clone/features/profile/domain/repositories/profile_repository.dart';

class MockFeedRepository extends Mock implements IFeedRepository {}

class MockProfileRepository extends Mock implements IProfileRepository {}

Post _post() => Post(
  id: 'p1',
  authorId: 'u1',
  authorUsername: 'alice',
  imageUrl: 'http://x',
  caption: 'hello world',
  createdAt: DateTime(2026, 1, 1),
  likeCount: 3,
  commentCount: 2,
);

Finder igHeart(bool filled) => find.byWidgetPredicate(
  (Widget w) =>
      w is IgIcon &&
      (filled ? w.data == IgIcons.heartFilled : w.data == IgIcons.heart),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFeedRepository repo;
  late MockProfileRepository profileRepo;
  late Completer<Either<Failure, void>> toggleGate;

  setUpAll(() => registerFallbackValue(_post()));

  setUp(() {
    repo = MockFeedRepository();
    profileRepo = MockProfileRepository();
    toggleGate = Completer<Either<Failure, void>>();
    when(
      () => repo.watchFeed(limit: any(named: 'limit')),
    ).thenAnswer((_) => const Stream<List<Post>>.empty());
    when(
      () => profileRepo.watchFollowingIds(uid: any(named: 'uid')),
    ).thenAnswer((_) => const Stream<List<String>>.empty());
    when(
      () => repo.fetchLikedPostIds(postIds: any(named: 'postIds')),
    ).thenAnswer((_) async => const Right<Failure, Set<String>>(<String>{}));
    when(
      () => repo.toggleLike(
        post: any(named: 'post'),
        currentlyLiked: any(named: 'currentlyLiked'),
      ),
    ).thenAnswer((_) => toggleGate.future);
  });

  Widget subject() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<FeedCubit>(
        create: (_) => FeedCubit(repo, profileRepo, myUid: 'u1'),
        child: Scaffold(
          body: ListView(
            children: <Widget>[
              BlocBuilder<FeedCubit, FeedState>(
                builder: (BuildContext context, FeedState state) => PostCard(
                  post: _post(),
                  isLiked: state.likedIds.contains('p1'),
                  onLikeTap: () =>
                      context.read<FeedCubit>().toggleLike(_post()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pumpSubject(WidgetTester tester) async {
    // narrow surface keeps the like row on-screen under the square image
    await tester.binding.setSurfaceSize(const Size(400, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(subject());
    await tester.pump();
  }

  testWidgets('like tap flips icon optimistically before repo resolves', (
    WidgetTester tester,
  ) async {
    await pumpSubject(tester);

    expect(igHeart(false), findsOneWidget);
    expect(igHeart(true), findsNothing);

    await tester.tap(igHeart(false));
    await tester.pump();

    expect(igHeart(true), findsOneWidget);
    expect(igHeart(false), findsNothing);
    expect(tester.widget<IgIcon>(igHeart(true)).color, IgColors.likeRed);

    verify(
      () => repo.toggleLike(post: any(named: 'post'), currentlyLiked: false),
    ).called(1);
  });

  testWidgets('double-tap image likes once unliked, never un-likes', (
    WidgetTester tester,
  ) async {
    await pumpSubject(tester);

    // first double-tap: burst fires and the like goes through
    await tester.tap(find.byType(Image));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byType(Image));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // two filled hearts mid-gesture: the like button + the burst overlay
    expect(igHeart(true), findsNWidgets(2));
    verify(
      () => repo.toggleLike(post: any(named: 'post'), currentlyLiked: false),
    ).called(1);

    // burst heart is mid-animation and visible
    expect(find.byType(HeartBurst), findsOneWidget);

    // second double-tap on an already-liked post: burst, no un-like call
    await tester.tap(find.byType(Image));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.byType(Image));
    // let the double-tap recognizer's settle timer expire before teardown
    await tester.pump(const Duration(milliseconds: 300));

    verifyNever(
      () => repo.toggleLike(post: any(named: 'post'), currentlyLiked: true),
    );
  });

  testWidgets('renders username, caption and localized counts from post', (
    WidgetTester tester,
  ) async {
    await pumpSubject(tester);

    expect(find.text('alice'), findsOneWidget);
    expect(find.textContaining('hello world'), findsOneWidget);
    expect(find.text('3 likes'), findsOneWidget);
    expect(find.text('2 comments'), findsOneWidget);
  });
}
