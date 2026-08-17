import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/auth/data/datasources/auth_firebase_datasource.dart';
import 'package:flutter_instagram_clone/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_instagram_clone/core/models/app_user.dart';

class MockAuthDataSource extends Mock implements IAuthDataSource {}

void main() {
  late MockAuthDataSource ds;
  late AuthRepositoryImpl repo;

  const AppUser user = AppUser(uid: 'u1', email: 'a@b.c');
  const AppUser profileWithUsername = AppUser(
    uid: 'u1',
    email: 'a@b.c',
    username: 'newname',
  );

  setUp(() {
    ds = MockAuthDataSource();
    repo = AuthRepositoryImpl(ds);
  });

  group('signUp', () {
    test('maps datasource user to Right', () async {
      when(
        () => ds.signUp(email: 'a@b.c', password: 'pw'),
      ).thenAnswer((_) async => user);

      final Either<Failure, AppUser> result = await repo.signUp(
        email: 'a@b.c',
        password: 'pw',
      );

      expect(result, const Right<Failure, AppUser>(user));
    });

    test('maps invalid-credential to friendly failure', () async {
      when(
        () => ds.signUp(email: 'a@b.c', password: 'pw'),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      final Either<Failure, AppUser> result = await repo.signUp(
        email: 'a@b.c',
        password: 'pw',
      );

      expect(result.getLeft().toNullable()?.message, 'Email already in use');
    });

    test('maps network failure', () async {
      when(
        () => ds.signUp(email: 'a@b.c', password: 'pw'),
      ).thenThrow(FirebaseAuthException(code: 'network-request-failed'));

      final Either<Failure, AppUser> result = await repo.signUp(
        email: 'a@b.c',
        password: 'pw',
      );

      expect(
        result.getLeft().toNullable(),
        isA<Failure>().having(
          (Failure f) =>
              f.maybeMap(networkError: (_) => true, orElse: () => false),
          'is network error',
          isTrue,
        ),
      );
    });
  });

  group('signInWithGoogle', () {
    test('user cancel produces typed cancelled failure', () async {
      when(() => ds.signInWithGoogle()).thenThrow(
        GoogleSignInException(
          code: GoogleSignInExceptionCode.canceled,
          description: 'canceled',
        ),
      );

      final Either<Failure, AppUser> result = await repo.signInWithGoogle();

      expect(result.getLeft().toNullable()?.message, '');
      expect(
        result.getLeft().toNullable(),
        isA<Failure>().having(
          (Failure f) =>
              f.maybeWhen(cancelled: () => true, orElse: () => false),
          'is cancelled',
          isTrue,
        ),
      );
    });
  });

  group('findProfile', () {
    test('missing doc returns Right(null)', () async {
      when(() => ds.fetchProfileDoc('u1')).thenAnswer((_) async => null);

      final Either<Failure, AppUser?> result = await repo.findProfile(
        uid: 'u1',
        email: 'a@b.c',
      );

      expect(result, const Right<Failure, AppUser?>(null));
    });

    test('doc maps to full AppUser', () async {
      when(() => ds.fetchProfileDoc('u1')).thenAnswer(
        (_) async => <String, dynamic>{
          'email': 'a@b.c',
          'username': 'yo',
          'bio': null,
          'avatarUrl': 'http://x',
        },
      );

      final Either<Failure, AppUser?> result = await repo.findProfile(
        uid: 'u1',
        email: 'a@b.c',
      );

      expect(
        result.getRight().toNullable(),
        const AppUser(
          uid: 'u1',
          email: 'a@b.c',
          username: 'yo',
          avatarUrl: 'http://x',
        ),
      );
    });
  });

  group('saveProfile username uniqueness', () {
    test('UsernameTakenException maps to friendly failure', () async {
      when(
        () => ds.fetchProfileDoc('u1'),
      ).thenAnswer((_) async => <String, dynamic>{'email': 'a@b.c'});
      when(
        () => ds.saveProfileDoc(
          uid: 'u1',
          data: any(named: 'data'),
          previousUsername: any(named: 'previousUsername'),
        ),
      ).thenThrow(UsernameTakenException());

      final Either<Failure, void> result = await repo.saveProfile(
        user: profileWithUsername,
      );

      expect(result.getLeft().toNullable()?.message, 'Username is taken');
    });

    test('passes previousUsername from current doc', () async {
      when(() => ds.fetchProfileDoc('u1')).thenAnswer(
        (_) async => <String, dynamic>{'email': 'a@b.c', 'username': 'old'},
      );
      when(
        () => ds.saveProfileDoc(
          uid: 'u1',
          data: any(named: 'data'),
          previousUsername: 'old',
        ),
      ).thenAnswer((_) async {});

      await repo.saveProfile(user: profileWithUsername);

      verify(
        () => ds.saveProfileDoc(
          uid: 'u1',
          data: any(named: 'data'),
          previousUsername: 'old',
        ),
      ).called(1);
    });
  });
}
