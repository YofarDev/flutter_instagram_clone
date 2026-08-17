import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/stories/domain/repositories/stories_repository.dart';
import 'package:flutter_instagram_clone/features/stories/presentation/bloc/create_story_cubit.dart';
import 'package:flutter_instagram_clone/features/stories/presentation/bloc/create_story_state.dart';

class MockIStoriesRepository extends Mock implements IStoriesRepository {}

void main() {
  late MockIStoriesRepository repo;

  setUp(() {
    repo = MockIStoriesRepository();
  });

  blocTest<CreateStoryCubit, CreateStoryState>(
    'submit without image does nothing',
    build: () => CreateStoryCubit(repo),
    act: (CreateStoryCubit cubit) => cubit.submit(),
    verify: (_) {
      verifyNever(() => repo.createStory(filePath: any(named: 'filePath')));
    },
    expect: () => const <CreateStoryState>[],
  );

  blocTest<CreateStoryCubit, CreateStoryState>(
    'submit success emits submitting then success',
    build: () {
      when(
        () => repo.createStory(filePath: any(named: 'filePath')),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      return CreateStoryCubit(repo);
    },
    seed: () => const CreateStoryState(pickedPath: '/tmp/story.jpg'),
    act: (CreateStoryCubit cubit) => cubit.submit(),
    verify: (_) {
      verify(() => repo.createStory(filePath: '/tmp/story.jpg')).called(1);
    },
    expect: () => const <CreateStoryState>[
      CreateStoryState(pickedPath: '/tmp/story.jpg', submitting: true),
      CreateStoryState(
        pickedPath: '/tmp/story.jpg',
        submitting: false,
        success: true,
      ),
    ],
  );

  blocTest<CreateStoryCubit, CreateStoryState>(
    'submit failure sets error and keeps success false',
    build: () {
      when(() => repo.createStory(filePath: any(named: 'filePath'))).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return CreateStoryCubit(repo);
    },
    seed: () => const CreateStoryState(pickedPath: '/tmp/story.jpg'),
    act: (CreateStoryCubit cubit) => cubit.submit(),
    expect: () => const <CreateStoryState>[
      CreateStoryState(pickedPath: '/tmp/story.jpg', submitting: true),
      CreateStoryState(pickedPath: '/tmp/story.jpg', error: 'boom'),
    ],
  );
}
