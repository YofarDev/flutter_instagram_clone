import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/models/failure.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit(this._auth, {required AppUser user})
      : super(EditProfileState(
          initial: user,
          username: user.username ?? '',
          bio: user.bio ?? '',
        ));

  final IAuthRepository _auth;

  void usernameChanged(String value) => emit(state.copyWith(username: value));

  void bioChanged(String value) => emit(state.copyWith(bio: value));

  void avatarPicked(String path) => emit(state.copyWith(avatarPath: path));

  Future<void> submit() async {
    if (state.username.trim().isEmpty || state.submitting) return;
    emit(state.copyWith(submitting: true, error: null));
    String? avatarUrl;
    if (state.avatarPath != null) {
      final Either<Failure, String> uploaded = await _auth.uploadAvatar(
        uid: state.initial.uid,
        filePath: state.avatarPath!,
      );
      if (isClosed) return;
      if (uploaded.isLeft()) {
        final Left<Failure, String> left = uploaded as Left<Failure, String>;
        emit(state.copyWith(submitting: false, error: left.value.message));
        return;
      }
      avatarUrl = (uploaded as Right<Failure, String>).value;
    }
    final AppUser updated = state.initial.copyWith(
      username: state.username.trim(),
      bio: state.bio,
      avatarUrl: avatarUrl ?? state.initial.avatarUrl,
    );
    final Either<Failure, void> saved = await _auth.saveProfile(user: updated);
    if (isClosed) return;
    saved.fold(
      (Failure f) => emit(state.copyWith(submitting: false, error: f.message)),
      (_) => emit(state.copyWith(submitting: false, success: true)),
    );
  }
}
