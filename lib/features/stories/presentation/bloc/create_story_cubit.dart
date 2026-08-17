import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/failure.dart';
import '../../domain/repositories/stories_repository.dart';
import 'create_story_state.dart';

class CreateStoryCubit extends Cubit<CreateStoryState> {
  CreateStoryCubit(this._repository) : super(const CreateStoryState());

  final IStoriesRepository _repository;

  Future<void> pickImage(ImageSource source) async {
    XFile? picked;
    try {
      picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1080,
        imageQuality: 70,
      );
    } catch (_) {
      // ponytail: plugin cancel/permission errors — nothing sensible to show
      return;
    }
    if (isClosed) return;
    if (picked != null) {
      emit(state.copyWith(pickedPath: picked.path));
    }
  }

  Future<void> submit() async {
    if (state.pickedPath == null || state.submitting) return;
    emit(state.copyWith(submitting: true, error: null));
    final Either<Failure, void> either = await _repository.createStory(
      filePath: state.pickedPath!,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(submitting: false, error: f.message)),
      (_) => emit(state.copyWith(submitting: false, success: true)),
    );
  }
}
