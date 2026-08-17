import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/post.dart';
import '../../domain/repositories/explore_repository.dart';
import 'hashtag_state.dart';

class HashtagCubit extends Cubit<HashtagState> {
  HashtagCubit(IExploreRepository repository, {required String tag})
      : super(const HashtagState()) {
    _sub = repository.watchPostsByTag(tag: tag).listen(
          (List<Post> posts) {
            if (isClosed) return;
            emit(state.copyWith(status: HashtagStatus.ready, posts: posts));
          },
          onError: (Object e) {
            if (isClosed) return;
            emit(state.copyWith(error: 'Failed to load posts'));
          },
        );
  }

  StreamSubscription<List<Post>>? _sub;

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
