import 'package:freezed_annotation/freezed_annotation.dart';

part 'reel.freezed.dart';

@freezed
sealed class Reel with _$Reel {
  const factory Reel({
    required String id,
    required String uid,
    required String authorUsername,
    String? authorAvatarUrl,
    required String videoUrl,
    @Default('') String caption,
    required DateTime createdAt,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
  }) = _Reel;
}
