import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/failure.dart';
import '../../domain/repositories/reels_repository.dart';
import 'create_reel_state.dart';

// ponytail: minimal for Task 4 route wiring — full tests/UX land in Task 5
class CreateReelCubit extends Cubit<CreateReelState> {
  CreateReelCubit(this._repository) : super(const CreateReelState());

  final IReelsRepository _repository;

  Future<void> pickVideo(ImageSource source) async {
    XFile? picked;
    try {
      picked = await ImagePicker().pickVideo(source: source);
    } catch (_) {
      // ponytail: plugin cancel/permission errors — nothing sensible to show
      return;
    }
    if (isClosed) return;
    if (picked != null) {
      emit(state.copyWith(pickedPath: picked.path));
    }
  }

  void captionChanged(String caption) => emit(state.copyWith(caption: caption));

  Future<void> submit() async {
    if (state.pickedPath == null || state.submitting) return;
    emit(state.copyWith(submitting: true, error: null));
    final Either<Failure, void> either = await _repository.createReel(
      caption: state.caption,
      filePath: state.pickedPath!,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(submitting: false, error: f.message)),
      (_) => emit(state.copyWith(submitting: false, success: true)),
    );
  }
}
