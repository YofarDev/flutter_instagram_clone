import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../../../core/models/comment.dart';
import '../../../../core/models/post.dart';

abstract interface class IFeedRepository {
  /// Live feed, newest first. Raw stream — errors surface via onError.
  Stream<List<Post>> watchFeed({required int limit});

  Future<Either<Failure, void>> createPost({
    required String caption,
    required List<String> filePaths,
  });

  Future<Either<Failure, Set<String>>> fetchLikedPostIds({
    required List<String> postIds,
  });

  Future<Either<Failure, Set<String>>> fetchSavedPostIds({
    required List<String> postIds,
  });

  Future<Either<Failure, Post>> getPostById({required String postId});

  Future<Either<Failure, void>> toggleLike({
    required Post post,
    required bool currentlyLiked,
  });

  Future<Either<Failure, void>> toggleSave({
    required Post post,
    required bool currentlySaved,
  });

  Stream<List<Comment>> watchComments({required String postId});

  Future<Either<Failure, void>> addComment({
    required String postId,
    required String postOwnerId,
    required String text,
  });
}
