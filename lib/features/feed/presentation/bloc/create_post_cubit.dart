import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/models/failure.dart';
import '../../domain/repositories/feed_repository.dart';
import 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit(this._repository) : super(const CreatePostState());

  static const int maxImages = 10;

  final IFeedRepository _repository;

  /// Gallery opens multi-select and appends; camera appends a single shot.
  /// Both respect the 10-image IG-style cap.
  Future<void> pickImages(ImageSource source) async {
    if (state.pickedPaths.length >= maxImages) return;
    final List<String> paths = <String>[];
    try {
      if (source == ImageSource.gallery) {
        final List<XFile> picked = await ImagePicker().pickMultiImage(
          maxWidth: 1080,
          imageQuality: 70,
        );
        paths.addAll(picked.map((XFile f) => f.path));
      } else {
        final XFile? picked = await ImagePicker().pickImage(
          source: source,
          maxWidth: 1080,
          imageQuality: 70,
        );
        if (picked != null) paths.add(picked.path);
      }
    } catch (_) {
      // ponytail: plugin cancel/permission errors — nothing sensible to show
      return;
    }
    if (isClosed || paths.isEmpty) return;
    emit(
      state.copyWith(
        pickedPaths: <String>[
          ...state.pickedPaths,
          ...paths.take(maxImages - state.pickedPaths.length),
        ],
      ),
    );
  }

  void removeImageAt(int index) {
    if (index < 0 || index >= state.pickedPaths.length) return;
    final List<String> updated = <String>[...state.pickedPaths]
      ..removeAt(index);
    emit(state.copyWith(pickedPaths: updated));
  }

  void captionChanged(String value) => emit(state.copyWith(caption: value));

  Future<void> submit() async {
    if (state.pickedPaths.isEmpty || state.submitting) return;
    emit(state.copyWith(submitting: true, error: null));
    final Either<Failure, void> either = await _repository.createPost(
      caption: state.caption.trim(),
      filePaths: state.pickedPaths,
    );
    if (isClosed) return;
    either.fold(
      (Failure f) => emit(state.copyWith(submitting: false, error: f.message)),
      (_) => emit(state.copyWith(submitting: false, success: true)),
    );
  }
}
