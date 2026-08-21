import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';

@freezed
sealed class Post with _$Post {
  const Post._();

  const factory Post({
    required String id,
    required String authorId,
    required String authorUsername,
    String? authorAvatarUrl,
    required List<String> imageUrls,
    @Default('') String caption,
    required DateTime createdAt,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(<String>[]) List<String> tags,
  }) = _Post;

  /// Cover image — first carousel page (single-image posts hold one entry).
  String get imageUrl => imageUrls.first;
}
