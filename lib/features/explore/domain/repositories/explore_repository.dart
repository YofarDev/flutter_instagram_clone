import 'package:fpdart/fpdart.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/models/failure.dart';
import '../../../../core/models/post.dart';

abstract interface class IExploreRepository {
  Stream<List<Post>> watchExplorePosts({required int limit});
  Future<Either<Failure, List<AppUser>>> searchUsers({required String query});
  Stream<List<Post>> watchPostsByTag({required String tag});
}
