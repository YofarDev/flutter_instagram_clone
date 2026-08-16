import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../domain/models/comment.dart';
import '../../../../core/models/post.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_firebase_datasource.dart';

class FeedRepositoryImpl implements IFeedRepository {
  const FeedRepositoryImpl(this._ds);

  final IFeedDataSource _ds;

  @override
  Stream<List<Post>> watchFeed({required int limit}) =>
      _ds.watchFeed(limit: limit);

  @override
  Future<Either<Failure, void>> createPost({
    required String caption,
    required String filePath,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.createPost(caption: caption, filePath: filePath),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, Set<String>>> fetchLikedPostIds({
    required List<String> postIds,
  }) async {
    try {
      return Right<Failure, Set<String>>(
        await _ds.fetchLikedPostIds(postIds: postIds),
      );
    } catch (e) {
      return Left<Failure, Set<String>>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> toggleLike({
    required Post post,
    required bool currentlyLiked,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.toggleLike(postId: post.id, currentlyLiked: currentlyLiked),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Stream<List<Comment>> watchComments({required String postId}) =>
      _ds.watchComments(postId: postId);

  @override
  Future<Either<Failure, void>> addComment({
    required String postId,
    required String text,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.addComment(postId: postId, text: text),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  Failure _mapError(Object e) =>
      Failure.serverError(message: e.toString()); // ponytail: firestore errors are descriptive strings
}
