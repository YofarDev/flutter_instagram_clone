import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/models/failure.dart';
import '../../domain/models/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_firebase_datasource.dart';
import '../models/user_dto.dart';

class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl(this._ds);

  final IAuthDataSource _ds;

  @override
  Stream<AppUser?> get authStateChanges => _ds.authStateChanges;

  @override
  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return Right<Failure, AppUser>(
        await _ds.signUp(email: email, password: password),
      );
    } catch (e) {
      return Left<Failure, AppUser>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return Right<Failure, AppUser>(
        await _ds.signIn(email: email, password: password),
      );
    } catch (e) {
      return Left<Failure, AppUser>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      return Right<Failure, AppUser>(await _ds.signInWithGoogle());
    } catch (e) {
      return Left<Failure, AppUser>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      return Right<Failure, void>(await _ds.signOut());
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, AppUser?>> findProfile({
    required String uid,
    required String email,
  }) async {
    try {
      final Map<String, dynamic>? map = await _ds.fetchProfileDoc(uid);
      if (map == null) return const Right<Failure, AppUser?>(null);
      final UserDto dto = UserDto.fromMap(map);
      return Right<Failure, AppUser?>(
        AppUser(
          uid: uid,
          email: dto.email,
          username: dto.username,
          bio: dto.bio,
          avatarUrl: dto.avatarUrl,
        ),
      );
    } catch (e) {
      return Left<Failure, AppUser?>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveProfile({required AppUser user}) async {
    try {
      return Right<Failure, void>(
        await _ds.saveProfileDoc(
          uid: user.uid,
          data: UserDto(
            email: user.email,
            username: user.username,
            bio: user.bio,
            avatarUrl: user.avatarUrl,
          ).toMap(),
        ),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, String>> uploadAvatar({
    required String uid,
    required String filePath,
  }) async {
    try {
      return Right<Failure, String>(
        await _ds.uploadAvatar(uid: uid, filePath: filePath),
      );
    } catch (e) {
      return Left<Failure, String>(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    if (e is GoogleSignInException) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // ponytail: typed cancel sentinel, cubit ignores it
        return const Failure.cancelled();
      }
      return Failure.serverError(message: e.description ?? 'Google sign-in failed');
    }
    if (e is FirebaseAuthException) {
      return switch (e.code) {
        'network-request-failed' => const Failure.networkError(),
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' ||
        'invalid-credential-password' ||
        'invalid-credential-email' =>
          const Failure.serverError(message: 'Invalid email or password'),
        'email-already-in-use' =>
          const Failure.serverError(message: 'Email already in use'),
        'weak-password' =>
          const Failure.serverError(message: 'Password is too weak'),
        _ => Failure.serverError(message: e.message ?? 'Authentication error'),
      };
    }
    return Failure.serverError(message: e.toString());
  }
}
