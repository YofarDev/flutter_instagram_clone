import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_instagram_clone/features/profile/presentation/bloc/edit_profile_cubit.dart';
import 'package:flutter_instagram_clone/features/profile/presentation/bloc/edit_profile_state.dart';

class MockIAuthRepository extends Mock implements IAuthRepository {}

final AppUser baseUser = AppUser(
  uid: 'u1',
  email: 'a@b.io',
  username: 'old',
  bio: 'hi',
  avatarUrl: 'http://img/old.png',
);

void main() {
  late MockIAuthRepository repo;

  setUp(() {
    repo = MockIAuthRepository();
    registerFallbackValue(baseUser);
  });

  blocTest<EditProfileCubit, EditProfileState>(
    'submit with blank username is a no-op',
    build: () => EditProfileCubit(repo, user: baseUser),
    seed: () =>
        EditProfileState(initial: baseUser, username: '   ', bio: 'hi'),
    act: (EditProfileCubit cubit) => cubit.submit(),
    verify: (EditProfileCubit cubit) {
      verifyNever(() => repo.saveProfile(user: any(named: 'user')));
    },
    expect: () => const <EditProfileState>[],
  );

  blocTest<EditProfileCubit, EditProfileState>(
    'avatar upload failure aborts before saveProfile',
    build: () {
      when(() => repo.uploadAvatar(uid: 'u1', filePath: 'pick')).thenAnswer(
        (_) async => const Left<Failure, String>(
          Failure.serverError(message: 'upload failed'),
        ),
      );
      return EditProfileCubit(repo, user: baseUser);
    },
    seed: () => EditProfileState(
      initial: baseUser,
      username: 'old',
      bio: 'hi',
      avatarPath: 'pick',
    ),
    act: (EditProfileCubit cubit) => cubit.submit(),
    verify: (EditProfileCubit cubit) {
      verifyNever(() => repo.saveProfile(user: any(named: 'user')));
    },
    expect: () => <EditProfileState>[
      EditProfileState(
        initial: baseUser,
        username: 'old',
        bio: 'hi',
        avatarPath: 'pick',
        submitting: true,
      ),
      EditProfileState(
        initial: baseUser,
        username: 'old',
        bio: 'hi',
        avatarPath: 'pick',
        error: 'upload failed',
      ),
    ],
  );

  blocTest<EditProfileCubit, EditProfileState>(
    'saveProfile failure surfaces error',
    build: () {
      when(() => repo.saveProfile(user: any(named: 'user'))).thenAnswer(
        (_) async => const Left<Failure, void>(
          Failure.serverError(message: 'Username is taken'),
        ),
      );
      return EditProfileCubit(repo, user: baseUser);
    },
    seed: () => EditProfileState(
      initial: baseUser,
      username: 'taken',
      bio: 'hi',
    ),
    act: (EditProfileCubit cubit) => cubit.submit(),
    verify: (EditProfileCubit cubit) {
      verifyNever(
        () => repo.uploadAvatar(
          uid: any(named: 'uid'),
          filePath: any(named: 'filePath'),
        ),
      );
    },
    expect: () => <EditProfileState>[
      EditProfileState(
        initial: baseUser,
        username: 'taken',
        bio: 'hi',
        submitting: true,
      ),
      EditProfileState(
        initial: baseUser,
        username: 'taken',
        bio: 'hi',
        error: 'Username is taken',
      ),
    ],
  );

  blocTest<EditProfileCubit, EditProfileState>(
    'success saves new username, bio, and uploaded avatarUrl',
    build: () {
      when(() => repo.uploadAvatar(uid: 'u1', filePath: 'pick')).thenAnswer(
        (_) async => const Right<Failure, String>('http://img/new.png'),
      );
      when(() => repo.saveProfile(user: any(named: 'user'))).thenAnswer(
        (_) async => const Right<Failure, void>(null),
      );
      return EditProfileCubit(repo, user: baseUser);
    },
    seed: () => EditProfileState(
      initial: baseUser,
      username: 'newname',
      bio: 'new bio',
      avatarPath: 'pick',
    ),
    act: (EditProfileCubit cubit) => cubit.submit(),
    verify: (EditProfileCubit cubit) {
      final List<dynamic> captured = verify(
        () => repo.saveProfile(user: captureAny(named: 'user')),
      ).captured;
      final AppUser saved = captured.single as AppUser;
      expect(saved.username, 'newname');
      expect(saved.bio, 'new bio');
      expect(saved.avatarUrl, 'http://img/new.png');
      expect(saved.uid, 'u1');
    },
    expect: () => <EditProfileState>[
      EditProfileState(
        initial: baseUser,
        username: 'newname',
        bio: 'new bio',
        avatarPath: 'pick',
        submitting: true,
      ),
      EditProfileState(
        initial: baseUser,
        username: 'newname',
        bio: 'new bio',
        avatarPath: 'pick',
        success: true,
      ),
    ],
  );

  blocTest<EditProfileCubit, EditProfileState>(
    'keeps old avatarUrl when no new pick',
    build: () {
      when(() => repo.saveProfile(user: any(named: 'user'))).thenAnswer(
        (_) async => const Right<Failure, void>(null),
      );
      return EditProfileCubit(repo, user: baseUser);
    },
    seed: () => EditProfileState(
      initial: baseUser,
      username: 'newname',
      bio: 'hi',
    ),
    act: (EditProfileCubit cubit) => cubit.submit(),
    verify: (EditProfileCubit cubit) {
      verifyNever(
        () => repo.uploadAvatar(
          uid: any(named: 'uid'),
          filePath: any(named: 'filePath'),
        ),
      );
      final List<dynamic> captured = verify(
        () => repo.saveProfile(user: captureAny(named: 'user')),
      ).captured;
      expect((captured.single as AppUser).avatarUrl, 'http://img/old.png');
    },
    expect: () => <EditProfileState>[
      EditProfileState(
        initial: baseUser,
        username: 'newname',
        bio: 'hi',
        submitting: true,
      ),
      EditProfileState(
        initial: baseUser,
        username: 'newname',
        bio: 'hi',
        success: true,
      ),
    ],
  );
}
