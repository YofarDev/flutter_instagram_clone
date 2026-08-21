import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../../../../core/models/comment.dart';
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
    required List<String> filePaths,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.createPost(caption: caption, filePaths: filePaths),
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
  Future<Either<Failure, Set<String>>> fetchSavedPostIds({
    required List<String> postIds,
  }) async {
    try {
      return Right<Failure, Set<String>>(
        await _ds.fetchSavedPostIds(postIds: postIds),
      );
    } catch (e) {
      return Left<Failure, Set<String>>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, Post>> getPostById({required String postId}) async {
    try {
      return Right<Failure, Post>(await _ds.getPostById(postId: postId));
    } catch (e) {
      return Left<Failure, Post>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> toggleLike({
    required Post post,
    required bool currentlyLiked,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.toggleLike(
          postId: post.id,
          postOwnerId: post.authorId,
          postImageUrl: post.imageUrl,
          currentlyLiked: currentlyLiked,
        ),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> toggleSave({
    required Post post,
    required bool currentlySaved,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.toggleSave(postId: post.id, currentlySaved: currentlySaved),
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
    required String postOwnerId,
    required String text,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.addComment(
          postId: postId,
          postOwnerId: postOwnerId,
          text: text,
        ),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    // ponytail: StateError carries the datasource's domain message
    // ('Post not found'), e.toString() would prefix 'Bad state: '
    if (e is StateError) return Failure.serverError(message: e.message);
    return Failure.serverError(message: e.toString());
  }
}
