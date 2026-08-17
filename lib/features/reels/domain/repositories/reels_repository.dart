import 'package:fpdart/fpdart.dart';

import '../../../../core/models/failure.dart';
import '../models/reel.dart';

abstract interface class IReelsRepository {
  Stream<List<Reel>> watchReels({required int limit});
  Future<Either<Failure, void>> createReel({
    required String caption,
    required String filePath,
  });
  Future<Either<Failure, Set<String>>> fetchLikedReelIds({
    required List<String> reelIds,
  });
  Future<Either<Failure, void>> toggleReelLike({
    required String reelId,
    required bool currentlyLiked,
  });
}
