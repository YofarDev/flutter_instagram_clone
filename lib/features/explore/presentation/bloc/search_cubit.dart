import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/models/failure.dart';
import '../../domain/repositories/explore_repository.dart';
import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  SearchCubit(this._repository) : super(const SearchState());

  final IExploreRepository _repository;

  // ponytail: Timer debounce in cubit, 6 lines vs bloc event boilerplate
  Timer? _debounce;

  void queryChanged(String query) {
    emit(state.copyWith(query: query));
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _runSearch);
  }

  Future<void> _runSearch() async {
    final String q = state.query.trim().toLowerCase();
    if (q.isEmpty) {
      emit(state.copyWith(users: <AppUser>[], searching: false));
      return;
    }
    emit(state.copyWith(searching: true));
    final Either<Failure, List<AppUser>> either =
        await _repository.searchUsers(query: q);
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(searching: false, error: f.message)),
      (List<AppUser> users) =>
          emit(state.copyWith(searching: false, users: users)),
    );
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}
