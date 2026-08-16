import 'package:freezed_annotation/freezed_annotation.dart';

part 'story.freezed.dart';

@freezed
sealed class Story with _$Story {
  const factory Story({
    required String id,
    required String uid,
    required String authorUsername,
    String? authorAvatarUrl,
    required String imageUrl,
    required DateTime createdAt,
  }) = _Story;
}
