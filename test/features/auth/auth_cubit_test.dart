import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_instagram_clone/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:flutter_instagram_clone/features/auth/presentation/bloc/auth_state.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

const AppUser user = AppUser(uid: 'u1', email: 'a@b.c');
const AppUser profile =
    AppUser(uid: 'u1', email: 'a@b.c', username: 'yo');

void main() {
  late MockAuthRepository repo;

  setUp(() {
    repo = MockAuthRepository();
    registerFallbackValue(profile);
  });

  blocTest<AuthCubit, AuthState>(
    'null auth event → unauthenticated',
    build: () {
      when(() => repo.authStateChanges)
          .thenAnswer((_) => Stream<AppUser?>.value(null));
      return AuthCubit(repo);
    },
    expect: () => const <AuthState>[
      AuthState(status: AuthStatus.unauthenticated),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'user without profile doc → needsProfile',
    build: () {
      when(() => repo.authStateChanges)
          .thenAnswer((_) => Stream<AppUser?>.value(user));
      when(() => repo.findProfile(uid: 'u1', email: 'a@b.c'))
          .thenAnswer((_) async => const Right<Failure, AppUser?>(null));
      return AuthCubit(repo);
    },
    expect: () => const <AuthState>[
      AuthState(status: AuthStatus.needsProfile, user: user),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'user with profile → authenticated',
    build: () {
      when(() => repo.authStateChanges)
          .thenAnswer((_) => Stream<AppUser?>.value(user));
      when(() => repo.findProfile(uid: 'u1', email: 'a@b.c'))
          .thenAnswer((_) async => const Right<Failure, AppUser?>(profile));
      return AuthCubit(repo);
    },
    expect: () => const <AuthState>[
      AuthState(status: AuthStatus.authenticated, user: profile),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'profile-check failure → still authenticated (fallback)',
    build: () {
      when(() => repo.authStateChanges)
          .thenAnswer((_) => Stream<AppUser?>.value(user));
      when(() => repo.findProfile(uid: 'u1', email: 'a@b.c')).thenAnswer(
        (_) async =>
            const Left<Failure, AppUser?>(Failure.serverError(message: 'x')),
      );
      return AuthCubit(repo);
    },
    expect: () => const <AuthState>[
      AuthState(status: AuthStatus.authenticated, user: user),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'signIn failure → error set, submitting reset',
    build: () {
      when(() => repo.authStateChanges)
          .thenAnswer((_) => const Stream<AppUser?>.empty());
      when(() => repo.signIn(email: 'a@b.c', password: 'bad')).thenAnswer(
        (_) async => const Left<Failure, AppUser>(
            Failure.serverError(message: 'Invalid email or password')),
      );
      return AuthCubit(repo);
    },
    act: (AuthCubit cubit) => cubit.signIn(email: 'a@b.c', password: 'bad'),
    expect: () => const <AuthState>[
      AuthState(submitting: true),
      AuthState(submitting: false, error: 'Invalid email or password'),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'google cancel (typed failure) → no error shown',
    build: () {
      when(() => repo.authStateChanges)
          .thenAnswer((_) => const Stream<AppUser?>.empty());
      when(() => repo.signInWithGoogle()).thenAnswer(
        (_) async => const Left<Failure, AppUser>(Failure.cancelled()),
      );
      return AuthCubit(repo);
    },
    act: (AuthCubit cubit) => cubit.signInWithGoogle(),
    expect: () => const <AuthState>[
      AuthState(submitting: true),
      AuthState(submitting: false),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'completeProfile uploads avatar, saves, authenticates',
    build: () {
      when(() => repo.authStateChanges)
          .thenAnswer((_) => const Stream<AppUser?>.empty());
      when(() => repo.uploadAvatar(uid: 'u1', filePath: '/tmp/p.jpg'))
          .thenAnswer((_) async => const Right<Failure, String>('http://avatar'));
      when(() => repo.saveProfile(user: any(named: 'user')))
          .thenAnswer((_) async => const Right<Failure, void>(null));
      return AuthCubit(repo);
    },
    seed: () => const AuthState(status: AuthStatus.needsProfile, user: user),
    act: (AuthCubit cubit) => cubit.completeProfile(
      username: 'yo',
      bio: 'hi',
      avatarPath: '/tmp/p.jpg',
    ),
    verify: (AuthCubit cubit) {
      final List<dynamic> captured = verify(
        () => repo.saveProfile(user: captureAny(named: 'user')),
      ).captured;
      expect(
        captured.single as AppUser,
        const AppUser(
          uid: 'u1',
          email: 'a@b.c',
          username: 'yo',
          bio: 'hi',
          avatarUrl: 'http://avatar',
        ),
      );
    },
    expect: () => const <AuthState>[
      AuthState(status: AuthStatus.needsProfile, user: user, submitting: true),
      AuthState(
        status: AuthStatus.authenticated,
        user: AppUser(
          uid: 'u1',
          email: 'a@b.c',
          username: 'yo',
          bio: 'hi',
          avatarUrl: 'http://avatar',
        ),
      ),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'avatar upload failure → error, saveProfile never called',
    build: () {
      when(() => repo.authStateChanges)
          .thenAnswer((_) => const Stream<AppUser?>.empty());
      when(() => repo.uploadAvatar(uid: 'u1', filePath: '/tmp/p.jpg'))
          .thenAnswer(
        (_) async =>
            const Left<Failure, String>(Failure.serverError(message: 'upload failed')),
      );
      return AuthCubit(repo);
    },
    seed: () => const AuthState(status: AuthStatus.needsProfile, user: user),
    act: (AuthCubit cubit) => cubit.completeProfile(
      username: 'yo',
      bio: 'hi',
      avatarPath: '/tmp/p.jpg',
    ),
    verify: (AuthCubit cubit) {
      verifyNever(() => repo.saveProfile(user: any(named: 'user')));
    },
    expect: () => const <AuthState>[
      AuthState(status: AuthStatus.needsProfile, user: user, submitting: true),
      AuthState(
        status: AuthStatus.needsProfile,
        user: user,
        error: 'upload failed',
      ),
    ],
  );

  blocTest<AuthCubit, AuthState>(
    'completeProfile without avatar skips upload',
    build: () {
      when(() => repo.authStateChanges)
          .thenAnswer((_) => const Stream<AppUser?>.empty());
      when(() => repo.saveProfile(user: any(named: 'user')))
          .thenAnswer((_) async => const Right<Failure, void>(null));
      return AuthCubit(repo);
    },
    seed: () => const AuthState(status: AuthStatus.needsProfile, user: user),
    act: (AuthCubit cubit) =>
        cubit.completeProfile(username: 'yo2', bio: null, avatarPath: null),
    verify: (AuthCubit cubit) {
      verifyNever(() => repo.uploadAvatar(
            uid: any(named: 'uid'),
            filePath: any(named: 'filePath'),
          ));
      final List<dynamic> captured = verify(
        () => repo.saveProfile(user: captureAny(named: 'user')),
      ).captured;
      expect(
        captured.single as AppUser,
        const AppUser(uid: 'u1', email: 'a@b.c', username: 'yo2'),
      );
    },
    expect: () => const <AuthState>[
      AuthState(status: AuthStatus.needsProfile, user: user, submitting: true),
      AuthState(
        status: AuthStatus.authenticated,
        user: AppUser(uid: 'u1', email: 'a@b.c', username: 'yo2'),
      ),
    ],
  );
}
