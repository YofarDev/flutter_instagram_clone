import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/feed/domain/repositories/feed_repository.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/create_post_cubit.dart';
import 'package:flutter_instagram_clone/features/feed/presentation/bloc/create_post_state.dart';

class MockIFeedRepository extends Mock implements IFeedRepository {}

void main() {
  late MockIFeedRepository repo;

  setUp(() {
    repo = MockIFeedRepository();
  });

  blocTest<CreatePostCubit, CreatePostState>(
    'captionChanged updates caption',
    build: () => CreatePostCubit(repo),
    act: (CreatePostCubit cubit) => cubit.captionChanged('hello'),
    expect: () => const <CreatePostState>[CreatePostState(caption: 'hello')],
  );

  blocTest<CreatePostCubit, CreatePostState>(
    'removeImageAt drops the page and keeps order',
    build: () => CreatePostCubit(repo),
    seed: () => const CreatePostState(
      pickedPaths: <String>['/a.jpg', '/b.jpg', '/c.jpg'],
    ),
    act: (CreatePostCubit cubit) => cubit.removeImageAt(1),
    expect: () => const <CreatePostState>[
      CreatePostState(pickedPaths: <String>['/a.jpg', '/c.jpg']),
    ],
  );

  blocTest<CreatePostCubit, CreatePostState>(
    'removeImageAt ignores out-of-range index',
    build: () => CreatePostCubit(repo),
    seed: () => const CreatePostState(pickedPaths: <String>['/a.jpg']),
    act: (CreatePostCubit cubit) => cubit.removeImageAt(5),
    expect: () => const <CreatePostState>[],
  );

  blocTest<CreatePostCubit, CreatePostState>(
    'submit without images does nothing',
    build: () => CreatePostCubit(repo),
    seed: () => const CreatePostState(caption: 'hi'),
    act: (CreatePostCubit cubit) => cubit.submit(),
    verify: (_) {
      verifyNever(
        () => repo.createPost(
          caption: any(named: 'caption'),
          filePaths: any(named: 'filePaths'),
        ),
      );
    },
    expect: () => const <CreatePostState>[],
  );

  blocTest<CreatePostCubit, CreatePostState>(
    'submit success emits submitting then success with trimmed caption',
    build: () {
      when(
        () => repo.createPost(
          caption: any(named: 'caption'),
          filePaths: any(named: 'filePaths'),
        ),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      return CreatePostCubit(repo);
    },
    seed: () => const CreatePostState(
      pickedPaths: <String>['/tmp/img.jpg'],
      caption: ' hi ',
    ),
    act: (CreatePostCubit cubit) => cubit.submit(),
    verify: (_) {
      verify(
        () => repo.createPost(
          caption: 'hi',
          filePaths: const <String>['/tmp/img.jpg'],
        ),
      ).called(1);
    },
    expect: () => const <CreatePostState>[
      CreatePostState(
        pickedPaths: <String>['/tmp/img.jpg'],
        caption: ' hi ',
        submitting: true,
      ),
      CreatePostState(
        pickedPaths: <String>['/tmp/img.jpg'],
        caption: ' hi ',
        submitting: false,
        success: true,
      ),
    ],
  );

  blocTest<CreatePostCubit, CreatePostState>(
    'submit failure sets error and keeps success false',
    build: () {
      when(
        () => repo.createPost(
          caption: any(named: 'caption'),
          filePaths: any(named: 'filePaths'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return CreatePostCubit(repo);
    },
    seed: () => const CreatePostState(pickedPaths: <String>['/tmp/img.jpg']),
    act: (CreatePostCubit cubit) => cubit.submit(),
    expect: () => const <CreatePostState>[
      CreatePostState(pickedPaths: <String>['/tmp/img.jpg'], submitting: true),
      CreatePostState(pickedPaths: <String>['/tmp/img.jpg'], error: 'boom'),
    ],
  );
}
