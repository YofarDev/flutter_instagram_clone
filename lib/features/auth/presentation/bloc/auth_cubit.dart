import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../../../core/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState()) {
    _sub = _repository.authStateChanges.listen(_onUserChanged);
  }

  final IAuthRepository _repository;
  late final StreamSubscription<AppUser?> _sub;

  Future<void> _onUserChanged(AppUser? user) async {
    if (user == null) {
      emit(state.copyWith(user: null, status: AuthStatus.unauthenticated));
      return;
    }
    final Either<Failure, AppUser?> result =
        await _repository.findProfile(uid: user.uid, email: user.email);
    result.fold(
      (_) => emit(state.copyWith(
        user: user,
        status: AuthStatus.authenticated,
      )), // ponytail: profile-check failure lets user in; revisit when profiles gate content
      (AppUser? profile) => emit(state.copyWith(
        user: profile ?? user,
        status: profile == null
            ? AuthStatus.needsProfile
            : AuthStatus.authenticated,
      )),
    );
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _runAction(
      () => _repository.signIn(email: email, password: password),
    );
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    await _runAction(
      () => _repository.signUp(email: email, password: password),
    );
  }

  Future<void> signInWithGoogle() async {
    await _runAction(_repository.signInWithGoogle);
  }

  Future<void> completeProfile({
    required String username,
    String? bio,
    String? avatarPath,
  }) async {
    final AppUser? user = state.user;
    if (user == null) return;
    emit(state.copyWith(submitting: true, error: null));
    String? avatarUrl;
    if (avatarPath != null) {
      final Either<Failure, String> upload = await _repository.uploadAvatar(
        uid: user.uid,
        filePath: avatarPath,
      );
      upload.fold(
        (Failure f) => emit(state.copyWith(submitting: false, error: f.message)),
        (String url) => avatarUrl = url,
      );
      if (avatarUrl == null) return;
    }
    final AppUser saved =
        user.copyWith(username: username, bio: bio, avatarUrl: avatarUrl);
    final Either<Failure, void> result =
        await _repository.saveProfile(user: saved);
    result.fold(
      (Failure f) => emit(state.copyWith(submitting: false, error: f.message)),
      (_) => emit(state.copyWith(
        user: saved,
        submitting: false,
        status: AuthStatus.authenticated,
      )),
    );
  }

  Future<void> signOut() async {
    final Either<Failure, void> result = await _repository.signOut();
    result.fold(
      (Failure f) => emit(state.copyWith(error: f.message)),
      (_) {},
    );
  }

  Future<void> _runAction(
    Future<Either<Failure, Object?>> Function() action,
  ) async {
    emit(state.copyWith(submitting: true, error: null));
    final Either<Failure, Object?> result = await action();
    result.fold(
      (Failure f) => emit(state.copyWith(
        submitting: false,
        // ponytail: typed cancel, stay quiet
        error: f.maybeWhen(
          cancelled: () => null,
          orElse: () => f.message,
        ),
      )),
      (_) => emit(state.copyWith(submitting: false)),
    );
  }

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }
}
