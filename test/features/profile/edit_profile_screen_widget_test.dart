import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/l10n/generated/app_localizations.dart';
import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_instagram_clone/features/profile/presentation/bloc/edit_profile_cubit.dart';
import 'package:flutter_instagram_clone/features/profile/presentation/screens/edit_profile_screen.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthRepository repo;

  setUpAll(() => registerFallbackValue(
      AppUser(uid: 'u1', email: 'yo@x.dev', username: 'yo')));

  setUp(() {
    repo = MockAuthRepository();
  });

  Widget subject() {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<EditProfileCubit>(
        create: (_) => EditProfileCubit(
          repo,
          user: AppUser(uid: 'u1', email: 'yo@x.dev', username: 'yo'),
        ),
        child: const EditProfileScreen(),
      ),
    );
  }

  testWidgets('empty username blocks submit', (WidgetTester tester) async {
    await tester.pumpWidget(subject());

    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(find.text('Save'));
    await tester.pump();

    verifyNever(() => repo.uploadAvatar(
          uid: any(named: 'uid'),
          filePath: any(named: 'filePath'),
        ));
    verifyNever(() => repo.saveProfile(user: any(named: 'user')));
  });

  testWidgets('taken username surfaces localized snackbar',
      (WidgetTester tester) async {
    when(() => repo.saveProfile(user: any(named: 'user'))).thenAnswer(
        (_) async =>
            Left<Failure, void>(Failure.serverError(message: 'Username is taken')));

    await tester.pumpWidget(subject());

    await tester.enterText(find.byType(TextField).first, 'taken');
    await tester.tap(find.text('Save'));
    await tester.pump();
    await tester.pump();

    expect(find.text('This username is already taken'), findsOneWidget);
    verify(() => repo.saveProfile(user: any(named: 'user'))).called(1);

    // fire the snackbar timer so nothing outlives the test
    await tester.pump(const Duration(seconds: 4));
    await tester.pump();
  });
}
