import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../domain/models/story.dart';
import '../../domain/repositories/stories_repository.dart';
import '../datasources/stories_firebase_datasource.dart';

class StoriesRepositoryImpl implements IStoriesRepository {
  const StoriesRepositoryImpl(this._ds);

  final IStoriesDataSource _ds;

  @override
  Stream<List<Story>> watchStories() => _ds.watchStories();

  @override
  Future<Either<Failure, void>> createStory({required String filePath}) async {
    try {
      return Right<Failure, void>(await _ds.createStory(filePath: filePath));
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, Set<String>>> fetchViewedStoryIds({
    required List<String> storyIds,
  }) async {
    try {
      return Right<Failure, Set<String>>(
        await _ds.fetchViewedStoryIds(storyIds: storyIds),
      );
    } catch (e) {
      return Left<Failure, Set<String>>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> markViewed({required String storyId}) async {
    try {
      return Right<Failure, void>(await _ds.markViewed(storyId: storyId));
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    return Failure.serverError(message: e.toString());
  }
}
