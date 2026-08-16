import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_instagram_clone/features/profile/presentation/bloc/follow_list_cubit.dart';
import 'package:flutter_instagram_clone/features/profile/presentation/bloc/follow_list_state.dart';

class MockIProfileRepository extends Mock implements IProfileRepository {}

final AppUser u1 = AppUser(uid: 'a', email: 'a@b.io', username: 'a');
final AppUser u2 = AppUser(uid: 'b', email: 'b@b.io', username: 'b');
final List<AppUser> users = <AppUser>[u1, u2];

void main() {
  late MockIProfileRepository repo;

  setUp(() {
    repo = MockIProfileRepository();
  });

  blocTest<FollowListCubit, FollowListState>(
    'followers mode maps to fetchFollowers and toggles loading',
    build: () {
      when(() => repo.fetchFollowers(uid: 'me'))
          .thenAnswer((_) async => Right<Failure, List<AppUser>>(users));
      return FollowListCubit(repo);
    },
    act: (FollowListCubit cubit) => cubit.load(uid: 'me', followersMode: true),
    verify: (FollowListCubit cubit) {
      verify(() => repo.fetchFollowers(uid: 'me')).called(1);
      verifyNever(() => repo.fetchFollowing(uid: any(named: 'uid')));
    },
    expect: () => <FollowListState>[
      const FollowListState(loading: true),
      FollowListState(users: users),
    ],
  );

  blocTest<FollowListCubit, FollowListState>(
    'following mode maps to fetchFollowing',
    build: () {
      when(() => repo.fetchFollowing(uid: 'me'))
          .thenAnswer((_) async => Right<Failure, List<AppUser>>(users));
      return FollowListCubit(repo);
    },
    act: (FollowListCubit cubit) => cubit.load(uid: 'me', followersMode: false),
    verify: (FollowListCubit cubit) {
      verify(() => repo.fetchFollowing(uid: 'me')).called(1);
      verifyNever(() => repo.fetchFollowers(uid: any(named: 'uid')));
    },
    expect: () => <FollowListState>[
      const FollowListState(loading: true),
      FollowListState(users: users),
    ],
  );

  blocTest<FollowListCubit, FollowListState>(
    'failure sets error',
    build: () {
      when(() => repo.fetchFollowers(uid: 'me')).thenAnswer(
        (_) async =>
            const Left<Failure, List<AppUser>>(Failure.serverError(message: 'boom')),
      );
      return FollowListCubit(repo);
    },
    act: (FollowListCubit cubit) => cubit.load(uid: 'me', followersMode: true),
    expect: () => <FollowListState>[
      const FollowListState(loading: true),
      const FollowListState(error: 'boom'),
    ],
  );
}
