import 'package:fpdart/fpdart.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/models/failure.dart';
import '../../../../core/models/post.dart';
import '../models/user_profile.dart';

abstract interface class IProfileRepository {
  Future<Either<Failure, UserProfile>> getProfile({required String uid});

  /// Live stream of the uids this user follows.
  Stream<List<String>> watchFollowingIds({required String uid});

  /// Live: does the CURRENT user follow {uid}?
  Stream<bool> watchIsFollowing({required String uid});

  Future<Either<Failure, void>> toggleFollow({
    required String uid,
    required bool currentlyFollowing,
  });

  Future<Either<Failure, List<AppUser>>> fetchFollowers({required String uid});

  Future<Either<Failure, List<AppUser>>> fetchFollowing({required String uid});

  Stream<List<Post>> watchUserPosts({required String uid, required int limit});
}
