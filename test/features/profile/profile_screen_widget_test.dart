import 'dart:async';

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
import 'package:flutter_instagram_clone/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_instagram_clone/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_instagram_clone/features/profile/domain/models/user_profile.dart';
import 'package:flutter_instagram_clone/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_instagram_clone/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:flutter_instagram_clone/features/profile/presentation/screens/profile_screen.dart';

class MockProfileRepository extends Mock implements IProfileRepository {}

class MockAuthRepository extends Mock implements IAuthRepository {}

UserProfile _profile() => UserProfile(
  uid: 'u1',
  email: 'yo@x.dev',
  username: 'yo',
  followerCount: 3,
  followingCount: 2,
  postCount: 5,
);

Post _post() => Post(
  id: 'p1',
  authorId: 'u1',
  authorUsername: 'yo',
  imageUrl: 'http://x',
  caption: 'hello',
  createdAt: DateTime(2026, 1, 1),
  likeCount: 3,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockProfileRepository repo;
  late Completer<Either<Failure, void>> toggleGate;

  setUp(() {
    repo = MockProfileRepository();
    toggleGate = Completer<Either<Failure, void>>();
    when(
      () => repo.getProfile(uid: any(named: 'uid')),
    ).thenAnswer((_) async => Right<Failure, UserProfile>(_profile()));
    when(
      () => repo.watchUserPosts(
        uid: any(named: 'uid'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((_) => Stream<List<Post>>.value(<Post>[_post()]));
    when(
      () => repo.watchIsFollowing(uid: any(named: 'uid')),
    ).thenAnswer((_) => Stream<bool>.value(false));
    when(
      () => repo.toggleFollow(
        uid: any(named: 'uid'),
        currentlyFollowing: any(named: 'currentlyFollowing'),
      ),
    ).thenAnswer((_) => toggleGate.future);
  });

  Widget subject() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<ProfileCubit>(
        create: (_) => ProfileCubit(repo, uid: 'u1', isMe: false),
        child: const ProfileScreen(),
      ),
    );
  }

  Future<void> pumpSubject(WidgetTester tester) async {
    await tester.pumpWidget(subject());
    await tester.pump();
    await tester.pump();
  }

  testWidgets('renders username, counts, follow button and one grid image', (
    WidgetTester tester,
  ) async {
    await pumpSubject(tester);

    // username in app bar + bold body text
    expect(find.text('yo'), findsNWidgets(2));
    expect(find.text('3'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Follow'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('follow tap flips button optimistically before repo resolves', (
    WidgetTester tester,
  ) async {
    await pumpSubject(tester);

    await tester.tap(find.text('Follow'));
    await tester.pump();

    expect(find.text('Unfollow'), findsOneWidget);
    verify(
      () => repo.toggleFollow(uid: 'u1', currentlyFollowing: false),
    ).called(1);
  });

  testWidgets('own profile more-menu sheet signs out', (
    WidgetTester tester,
  ) async {
    final MockAuthRepository authRepo = MockAuthRepository();
    when(
      () => authRepo.authStateChanges,
    ).thenAnswer((_) => const Stream<AppUser?>.empty());
    when(
      () => authRepo.signOut(),
    ).thenAnswer((_) async => const Right<Failure, void>(null));

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MultiBlocProvider(
          providers: <SingleChildWidget>[
            BlocProvider<AuthCubit>(create: (_) => AuthCubit(authRepo)),
            BlocProvider<ProfileCubit>(
              create: (_) => ProfileCubit(repo, uid: 'u1', isMe: true),
            ),
          ],
          child: const ProfileScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tap(find.byTooltip('Log out'));
    await tester.pumpAndSettle();

    expect(find.text('Cancel'), findsOneWidget); // sheet open

    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();

    verify(() => authRepo.signOut()).called(1);
    expect(find.text('Cancel'), findsNothing); // sheet dismissed
  });
}
