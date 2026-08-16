import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/models/failure.dart';
import '../../domain/repositories/profile_repository.dart';
import 'follow_list_state.dart';

class FollowListCubit extends Cubit<FollowListState> {
  FollowListCubit(this._repository) : super(const FollowListState());

  final IProfileRepository _repository;

  Future<void> load({required String uid, required bool followersMode}) async {
    emit(state.copyWith(loading: true, error: null));
    final Either<Failure, List<AppUser>> either = followersMode
        ? await _repository.fetchFollowers(uid: uid)
        : await _repository.fetchFollowing(uid: uid);
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(loading: false, error: f.message)),
      (List<AppUser> users) =>
          emit(state.copyWith(loading: false, users: users)),
    );
  }
}
