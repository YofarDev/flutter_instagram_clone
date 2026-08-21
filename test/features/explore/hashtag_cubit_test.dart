import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/post.dart';
import 'package:flutter_instagram_clone/features/explore/domain/repositories/explore_repository.dart';
import 'package:flutter_instagram_clone/features/explore/presentation/bloc/hashtag_cubit.dart';
import 'package:flutter_instagram_clone/features/explore/presentation/bloc/hashtag_state.dart';

class MockIExploreRepository extends Mock implements IExploreRepository {}

final Post post = Post(
  id: 'p1',
  authorId: 'u1',
  authorUsername: 'yo',
  imageUrls: <String>['http://img'],
  createdAt: DateTime(2026, 1, 1),
);

void main() {
  late MockIExploreRepository repo;

  setUp(() {
    repo = MockIExploreRepository();
  });

  blocTest<HashtagCubit, HashtagState>(
    'stream emits ready with tagged posts',
    build: () {
      when(
        () => repo.watchPostsByTag(tag: 'sunset'),
      ).thenAnswer((_) => Stream<List<Post>>.value(<Post>[post]));
      return HashtagCubit(repo, tag: 'sunset');
    },
    verify: (HashtagCubit cubit) {
      verify(() => repo.watchPostsByTag(tag: 'sunset')).called(1);
    },
    expect: () => <HashtagState>[
      HashtagState(status: HashtagStatus.ready, posts: <Post>[post]),
    ],
  );

  blocTest<HashtagCubit, HashtagState>(
    'stream error sets error message',
    build: () {
      final StreamController<List<Post>> controller =
          StreamController<List<Post>>();
      addTearDown(controller.close);
      when(
        () => repo.watchPostsByTag(tag: 'sunset'),
      ).thenAnswer((_) => controller.stream);
      controller.addError(Exception('db down'));
      return HashtagCubit(repo, tag: 'sunset');
    },
    expect: () => <HashtagState>[HashtagState(error: 'Failed to load posts')],
  );
}
