import 'package:fpdart/fpdart.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/models/failure.dart';
import '../../../../core/models/post.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_firebase_datasource.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  const ProfileRepositoryImpl(this._ds);

  final IProfileDataSource _ds;

  @override
  Future<Either<Failure, UserProfile>> getProfile({required String uid}) async {
    try {
      return Right<Failure, UserProfile>(await _ds.getProfile(uid: uid));
    } catch (e) {
      return Left<Failure, UserProfile>(_mapError(e));
    }
  }

  @override
  Stream<List<String>> watchFollowingIds({required String uid}) =>
      _ds.watchFollowingIds(uid: uid);

  @override
  Stream<bool> watchIsFollowing({required String uid}) =>
      _ds.watchIsFollowing(uid: uid);

  @override
  Stream<List<Post>> watchUserPosts({
    required String uid,
    required int limit,
  }) => _ds.watchUserPosts(uid: uid, limit: limit);

  @override
  Future<Either<Failure, void>> toggleFollow({
    required String uid,
    required bool currentlyFollowing,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.toggleFollow(
          uid: uid,
          currentlyFollowing: currentlyFollowing,
        ),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, List<AppUser>>> fetchFollowers({
    required String uid,
  }) async {
    try {
      return Right<Failure, List<AppUser>>(await _ds.fetchFollowers(uid: uid));
    } catch (e) {
      return Left<Failure, List<AppUser>>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, List<AppUser>>> fetchFollowing({
    required String uid,
  }) async {
    try {
      return Right<Failure, List<AppUser>>(await _ds.fetchFollowing(uid: uid));
    } catch (e) {
      return Left<Failure, List<AppUser>>(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    // ponytail: StateError carries the datasource's domain message
    // ('Profile not found'), e.toString() would prefix 'Bad state: '
    if (e is StateError) return Failure.serverError(message: e.message);
    return Failure.serverError(message: e.toString());
  }
}
