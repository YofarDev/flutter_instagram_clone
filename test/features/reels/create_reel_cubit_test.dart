import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_instagram_clone/core/models/failure.dart';
import 'package:flutter_instagram_clone/features/reels/domain/repositories/reels_repository.dart';
import 'package:flutter_instagram_clone/features/reels/presentation/bloc/create_reel_cubit.dart';
import 'package:flutter_instagram_clone/features/reels/presentation/bloc/create_reel_state.dart';

class MockIReelsRepository extends Mock implements IReelsRepository {}

void main() {
  late MockIReelsRepository repo;

  setUp(() {
    repo = MockIReelsRepository();
  });

  blocTest<CreateReelCubit, CreateReelState>(
    'captionChanged updates caption',
    build: () => CreateReelCubit(repo),
    act: (CreateReelCubit cubit) => cubit.captionChanged('hello'),
    expect: () => const <CreateReelState>[CreateReelState(caption: 'hello')],
  );

  blocTest<CreateReelCubit, CreateReelState>(
    'submit without video does nothing',
    build: () => CreateReelCubit(repo),
    seed: () => const CreateReelState(caption: 'hi'),
    act: (CreateReelCubit cubit) => cubit.submit(),
    verify: (_) {
      verifyNever(
        () => repo.createReel(
          caption: any(named: 'caption'),
          filePath: any(named: 'filePath'),
        ),
      );
    },
    expect: () => const <CreateReelState>[],
  );

  blocTest<CreateReelCubit, CreateReelState>(
    'submit success emits submitting then success',
    build: () {
      when(
        () => repo.createReel(
          caption: any(named: 'caption'),
          filePath: any(named: 'filePath'),
        ),
      ).thenAnswer((_) async => const Right<Failure, void>(null));
      return CreateReelCubit(repo);
    },
    seed: () =>
        const CreateReelState(pickedPath: '/tmp/vid.mp4', caption: 'hi'),
    act: (CreateReelCubit cubit) => cubit.submit(),
    verify: (_) {
      verify(
        () => repo.createReel(caption: 'hi', filePath: '/tmp/vid.mp4'),
      ).called(1);
    },
    expect: () => const <CreateReelState>[
      CreateReelState(
        pickedPath: '/tmp/vid.mp4',
        caption: 'hi',
        submitting: true,
      ),
      CreateReelState(
        pickedPath: '/tmp/vid.mp4',
        caption: 'hi',
        submitting: false,
        success: true,
      ),
    ],
  );

  blocTest<CreateReelCubit, CreateReelState>(
    'submit failure sets error and keeps success false',
    build: () {
      when(
        () => repo.createReel(
          caption: any(named: 'caption'),
          filePath: any(named: 'filePath'),
        ),
      ).thenAnswer(
        (_) async =>
            const Left<Failure, void>(Failure.serverError(message: 'boom')),
      );
      return CreateReelCubit(repo);
    },
    seed: () => const CreateReelState(pickedPath: '/tmp/vid.mp4'),
    act: (CreateReelCubit cubit) => cubit.submit(),
    expect: () => const <CreateReelState>[
      CreateReelState(pickedPath: '/tmp/vid.mp4', submitting: true),
      CreateReelState(pickedPath: '/tmp/vid.mp4', error: 'boom'),
    ],
  );
}
