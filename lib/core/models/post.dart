import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';

@freezed
sealed class Post with _$Post {
  const factory Post({
    required String id,
    required String authorId,
    required String authorUsername,
    String? authorAvatarUrl,
    required String imageUrl,
    @Default('') String caption,
    required DateTime createdAt,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    @Default(<String>[]) List<String> tags,
  }) = _Post;
}
