import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/app_user.dart';
import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/explore/domain/repositories/explore_repository.dart';
import 'package:flutter_instagram_clone/features/explore/presentation/bloc/search_cubit.dart';
import 'package:flutter_instagram_clone/features/explore/presentation/bloc/search_state.dart';

class MockIExploreRepository extends Mock implements IExploreRepository {}

final AppUser user = AppUser(uid: 'u1', email: 'a@b.c', username: 'yo');

void main() {
  late MockIExploreRepository repo;

  setUp(() {
    repo = MockIExploreRepository();
  });

  blocTest<SearchCubit, SearchState>(
    'debounces rapid keystrokes into a single search',
    build: () {
      when(
        () => repo.searchUsers(query: 'al'),
      ).thenAnswer((_) async => Right<Failure, List<AppUser>>(<AppUser>[user]));
      return SearchCubit(repo);
    },
    act: (SearchCubit cubit) {
      cubit.queryChanged('a');
      cubit.queryChanged('al');
    },
    wait: const Duration(milliseconds: 400),
    verify: (_) {
      verify(() => repo.searchUsers(query: 'al')).called(1);
      verifyNever(() => repo.searchUsers(query: 'a'));
    },
    expect: () => <SearchState>[
      const SearchState(query: 'a'),
      const SearchState(query: 'al'),
      const SearchState(query: 'al', searching: true),
      SearchState(query: 'al', users: <AppUser>[user], searching: false),
    ],
  );

  blocTest<SearchCubit, SearchState>(
    'empty query clears results without calling datasource',
    build: () => SearchCubit(repo),
    seed: () => SearchState(query: 'al', users: <AppUser>[user]),
    act: (SearchCubit cubit) => cubit.queryChanged(''),
    wait: const Duration(milliseconds: 400),
    verify: (_) {
      verifyNever(() => repo.searchUsers(query: any(named: 'query')));
    },
    expect: () => <SearchState>[
      SearchState(query: '', users: <AppUser>[user]),
      const SearchState(query: ''),
    ],
  );

  blocTest<SearchCubit, SearchState>(
    'search failure sets error',
    build: () {
      when(() => repo.searchUsers(query: 'al')).thenAnswer(
        (_) async => const Left<Failure, List<AppUser>>(
          Failure.serverError(message: 'boom'),
        ),
      );
      return SearchCubit(repo);
    },
    act: (SearchCubit cubit) => cubit.queryChanged('al'),
    wait: const Duration(milliseconds: 400),
    expect: () => const <SearchState>[
      SearchState(query: 'al'),
      SearchState(query: 'al', searching: true),
      SearchState(query: 'al', searching: false, error: 'boom'),
    ],
  );
}
