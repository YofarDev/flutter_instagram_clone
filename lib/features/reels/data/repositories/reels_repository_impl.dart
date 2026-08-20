import 'package:fpdart/fpdart.dart';

import '../../../../core/models/comment.dart';
import '../../../../core/models/failure.dart';
import '../../domain/models/reel.dart';
import '../../domain/repositories/reels_repository.dart';
import '../datasources/reels_firebase_datasource.dart';

class ReelsRepositoryImpl implements IReelsRepository {
  const ReelsRepositoryImpl(this._ds);

  final IReelsDataSource _ds;

  @override
  Stream<List<Reel>> watchReels({required int limit}) =>
      _ds.watchReels(limit: limit);

  @override
  Future<Either<Failure, void>> createReel({
    required String caption,
    required String filePath,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.createReel(caption: caption, filePath: filePath),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, Set<String>>> fetchLikedReelIds({
    required List<String> reelIds,
  }) async {
    try {
      return Right<Failure, Set<String>>(
        await _ds.fetchLikedReelIds(reelIds: reelIds),
      );
    } catch (e) {
      return Left<Failure, Set<String>>(_mapError(e));
    }
  }

  @override
  Future<Either<Failure, void>> toggleReelLike({
    required String reelId,
    required String reelOwnerId,
    required bool currentlyLiked,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.toggleReelLike(
          reelId: reelId,
          reelOwnerId: reelOwnerId,
          currentlyLiked: currentlyLiked,
        ),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  @override
  Stream<List<Comment>> watchReelComments({required String reelId}) =>
      _ds.watchReelComments(reelId: reelId);

  @override
  Future<Either<Failure, void>> addReelComment({
    required String reelId,
    required String reelOwnerId,
    required String text,
  }) async {
    try {
      return Right<Failure, void>(
        await _ds.addReelComment(
          reelId: reelId,
          reelOwnerId: reelOwnerId,
          text: text,
        ),
      );
    } catch (e) {
      return Left<Failure, void>(_mapError(e));
    }
  }

  Failure _mapError(Object e) {
    return Failure.serverError(message: e.toString());
  }
}
