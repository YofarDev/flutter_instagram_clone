import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../models/app_user.dart';

abstract interface class IAuthRepository {
  /// Emits a bare AppUser (uid + email only) or null on logout.
  Stream<AppUser?> get authStateChanges;

  Future<Either<Failure, AppUser>> signUp({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, AppUser>> signInWithGoogle();

  Future<Either<Failure, void>> signOut();

  /// Full profile from Firestore; null if the profile doc doesn't exist yet.
  Future<Either<Failure, AppUser?>> findProfile({
    required String uid,
    required String email,
  });

  Future<Either<Failure, void>> saveProfile({required AppUser user});

  /// Uploads local image, returns its Storage download URL.
  Future<Either<Failure, String>> uploadAvatar({
    required String uid,
    required String filePath,
  });
}
