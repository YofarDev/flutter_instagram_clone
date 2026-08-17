import 'package:fpdart/fpdart.dart';

import '../../../../core/models/app_user.dart';
import '../../../../core/models/failure.dart';
import '../../../../core/models/post.dart';
import '../../domain/repositories/explore_repository.dart';
import '../datasources/explore_firebase_datasource.dart';

class ExploreRepositoryImpl implements IExploreRepository {
  const ExploreRepositoryImpl(this._ds);

  final IExploreDataSource _ds;

  @override
  Stream<List<Post>> watchExplorePosts({required int limit}) =>
      _ds.watchExplorePosts(limit: limit);

  @override
  Stream<List<Post>> watchPostsByTag({required String tag}) =>
      _ds.watchPostsByTag(tag: tag);

  @override
  Future<Either<Failure, List<AppUser>>> searchUsers(
      {required String query}) async {
    try {
      return Right<Failure, List<AppUser>>(
        await _ds.searchUsers(query: query),
      );
    } catch (e) {
      return Left<Failure, List<AppUser>>(_mapError(e));
    }
  }

  Failure _mapError(Object e) =>
      Failure.serverError(message: e.toString()); // ponytail: firestore errors are descriptive strings
}
