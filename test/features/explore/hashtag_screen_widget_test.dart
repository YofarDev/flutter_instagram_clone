import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/post.dart';
import 'package:flutter_instagram_clone/features/explore/domain/repositories/explore_repository.dart';
import 'package:flutter_instagram_clone/features/explore/presentation/bloc/hashtag_cubit.dart';
import 'package:flutter_instagram_clone/features/explore/presentation/screens/hashtag_screen.dart';

class MockIExploreRepository extends Mock implements IExploreRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockIExploreRepository repo;

  setUp(() {
    repo = MockIExploreRepository();
  });

  testWidgets('renders tagged posts grid', (WidgetTester tester) async {
    when(() => repo.watchPostsByTag(tag: 'sunset')).thenAnswer(
      (_) => Stream<List<Post>>.value(<Post>[
        Post(
          id: 'p1',
          authorId: 'u1',
          authorUsername: 'alice',
          imageUrl: 'http://img/sunset',
          createdAt: DateTime(2026, 1, 1),
        ),
      ]),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<HashtagCubit>(
          create: (_) => HashtagCubit(repo, tag: 'sunset'),
          child: const HashtagScreen(tag: 'sunset'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('#sunset'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });
}
