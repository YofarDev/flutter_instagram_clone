import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nested/nested.dart';

import 'package:flutter_instagram_clone/core/l10n/generated/app_localizations.dart';
import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/core/models/post.dart';
import 'package:flutter_instagram_clone/features/explore/domain/repositories/explore_repository.dart';
import 'package:flutter_instagram_clone/features/explore/presentation/bloc/explore_cubit.dart';
import 'package:flutter_instagram_clone/features/explore/presentation/bloc/search_cubit.dart';
import 'package:flutter_instagram_clone/features/explore/presentation/screens/search_screen.dart';
import 'package:flutter_instagram_clone/features/profile/domain/repositories/profile_repository.dart';

class MockIExploreRepository extends Mock implements IExploreRepository {}

class MockIProfileRepository extends Mock implements IProfileRepository {}

final Post mine = Post(
  id: 'pm',
  authorId: 'me',
  authorUsername: 'me',
  imageUrl: 'http://img/pm',
  createdAt: DateTime(2026, 1, 1),
);
final Post followedPost = Post(
  id: 'pf',
  authorId: 'u2',
  authorUsername: 'followed',
  imageUrl: 'http://img/pf',
  createdAt: DateTime(2026, 1, 1),
);
final Post stranger = Post(
  id: 'ps',
  authorId: 'u9',
  authorUsername: 'stranger',
  imageUrl: 'http://img/ps',
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockIExploreRepository repo;
  late MockIProfileRepository profileRepo;

  setUp(() {
    repo = MockIExploreRepository();
    profileRepo = MockIProfileRepository();
    when(() => repo.watchExplorePosts(limit: any(named: 'limit'))).thenAnswer(
      (_) => Stream<List<Post>>.value(<Post>[mine, followedPost, stranger]),
    );
    when(
      () => profileRepo.watchFollowingIds(uid: any(named: 'uid')),
    ).thenAnswer((_) => Stream<List<String>>.value(<String>['u2']));
    when(
      () => repo.searchUsers(query: any(named: 'query')),
    ).thenAnswer((_) async => const Right<Failure, List<AppUser>>(<AppUser>[]));
  });

  Widget subject() => MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MultiBlocProvider(
      providers: <SingleChildWidget>[
        BlocProvider<ExploreCubit>(
          create: (_) => ExploreCubit(repo, profileRepo, myUid: 'me'),
        ),
        BlocProvider<SearchCubit>(create: (_) => SearchCubit(repo)),
      ],
      child: const SearchScreen(),
    ),
  );

  Future<void> pumpSubject(WidgetTester tester) async {
    await tester.pumpWidget(subject());
    await tester.pump();
    await tester.pump();
  }

  testWidgets('explore grid excludes self and followed, shows only stranger', (
    WidgetTester tester,
  ) async {
    await pumpSubject(tester);

    expect(find.byType(Image), findsOneWidget);
    final Image image = tester.widget<Image>(find.byType(Image));
    expect(
      image.image,
      isA<NetworkImage>().having(
        (NetworkImage n) => n.url,
        'url',
        'http://img/ps',
      ),
    );
  });

  testWidgets('typing shows accounts and hashtag row, hides explore grid', (
    WidgetTester tester,
  ) async {
    when(() => repo.searchUsers(query: 'al')).thenAnswer(
      (_) async => Right<Failure, List<AppUser>>(<AppUser>[
        const AppUser(uid: 'u1', email: 'alice@x.com', username: 'alice'),
      ]),
    );

    await pumpSubject(tester);
    expect(find.byType(Image), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'al');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text('alice'), findsOneWidget);
    expect(find.text('#al'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('typing with no matches shows searchNoResults', (
    WidgetTester tester,
  ) async {
    await pumpSubject(tester);

    final AppLocalizations l10n = AppLocalizations.of(
      tester.element(find.byType(SearchScreen)),
    );

    await tester.enterText(find.byType(TextField), 'zz');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.text(l10n.searchNoResults), findsOneWidget);
  });
}
