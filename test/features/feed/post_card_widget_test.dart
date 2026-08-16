import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/core/models/post.dart';
import 'package:flutter_instagram_clone/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/feed_cubit.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/feed_state.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/widgets/post_card.dart';

class MockFeedRepository extends Mock implements IFeedRepository {}

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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFeedRepository repo;
  late Completer<Either<Failure, void>> toggleGate;

  setUpAll(() => registerFallbackValue(_post()));

  setUp(() {
    repo = MockFeedRepository();
    toggleGate = Completer<Either<Failure, void>>();
    when(() => repo.watchFeed(limit: any(named: 'limit')))
        .thenAnswer((_) => const Stream<List<Post>>.empty());
    when(() => repo.fetchLikedPostIds(postIds: any(named: 'postIds')))
        .thenAnswer(
            (_) async => const Right<Failure, Set<String>>(<String>{}));
    when(() => repo.toggleLike(
          post: any(named: 'post'),
          currentlyLiked: any(named: 'currentlyLiked'),
        )).thenAnswer((_) => toggleGate.future);
  });

  Widget subject() {
    return MaterialApp(
      home: BlocProvider<FeedCubit>(
        create: (_) => FeedCubit(repo),
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

  testWidgets('like tap flips icon optimistically before repo resolves',
      (WidgetTester tester) async {
    await pumpSubject(tester);

    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsNothing);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.pump();

    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border), findsNothing);
    expect(tester.widget<Icon>(find.byIcon(Icons.favorite)).color, Colors.red);

    verify(() => repo.toggleLike(
          post: any(named: 'post'),
          currentlyLiked: false,
        )).called(1);
  });

  testWidgets('renders username, caption and counts from post',
      (WidgetTester tester) async {
    await pumpSubject(tester);

    expect(find.text('alice'), findsOneWidget);
    expect(find.textContaining('hello world'), findsOneWidget);
    expect(find.text('3 likes'), findsOneWidget);
    expect(find.text('2 comments'), findsOneWidget);
  });
}
