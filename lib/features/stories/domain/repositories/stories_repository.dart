import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../models/story.dart';

abstract interface class IStoriesRepository {
  /// Live stream of active (last 24h) stories, newest first.
  Stream<List<Story>> watchStories();

  Future<Either<Failure, void>> createStory({required String filePath});

  Future<Either<Failure, Set<String>>> fetchViewedStoryIds({
    required List<String> storyIds,
  });

  Future<Either<Failure, void>> markViewed({required String storyId});
}
