// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Reel {

 String get id; String get uid; String get authorUsername; String? get authorAvatarUrl; String get videoUrl; String get caption; DateTime get createdAt; int get likeCount; int get commentCount;
/// Create a copy of Reel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReelCopyWith<Reel> get copyWith => _$ReelCopyWithImpl<Reel>(this as Reel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reel&&(identical(other.id, id) || other.id == id)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.authorUsername, authorUsername) || other.authorUsername == authorUsername)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,uid,authorUsername,authorAvatarUrl,videoUrl,caption,createdAt,likeCount,commentCount);

@override
String toString() {
  return 'Reel(id: $id, uid: $uid, authorUsername: $authorUsername, authorAvatarUrl: $authorAvatarUrl, videoUrl: $videoUrl, caption: $caption, createdAt: $createdAt, likeCount: $likeCount, commentCount: $commentCount)';
}


}

/// @nodoc
abstract mixin class $ReelCopyWith<$Res>  {
  factory $ReelCopyWith(Reel value, $Res Function(Reel) _then) = _$ReelCopyWithImpl;
@useResult
$Res call({
 String id, String uid, String authorUsername, String? authorAvatarUrl, String videoUrl, String caption, DateTime createdAt, int likeCount, int commentCount
});




}
/// @nodoc
class _$ReelCopyWithImpl<$Res>
    implements $ReelCopyWith<$Res> {
  _$ReelCopyWithImpl(this._self, this._then);

  final Reel _self;
  final $Res Function(Reel) _then;

/// Create a copy of Reel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uid = null,Object? authorUsername = null,Object? authorAvatarUrl = freezed,Object? videoUrl = null,Object? caption = null,Object? createdAt = null,Object? likeCount = null,Object? commentCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,authorUsername: null == authorUsername ? _self.authorUsername : authorUsername // ignore: cast_nullable_to_non_nullable
as String,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Reel].
extension ReelPatterns on Reel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reel value)  $default,){
final _that = this;
switch (_that) {
case _Reel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reel value)?  $default,){
final _that = this;
switch (_that) {
case _Reel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String uid,  String authorUsername,  String? authorAvatarUrl,  String videoUrl,  String caption,  DateTime createdAt,  int likeCount,  int commentCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reel() when $default != null:
return $default(_that.id,_that.uid,_that.authorUsername,_that.authorAvatarUrl,_that.videoUrl,_that.caption,_that.createdAt,_that.likeCount,_that.commentCount);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String uid,  String authorUsername,  String? authorAvatarUrl,  String videoUrl,  String caption,  DateTime createdAt,  int likeCount,  int commentCount)  $default,) {final _that = this;
switch (_that) {
case _Reel():
return $default(_that.id,_that.uid,_that.authorUsername,_that.authorAvatarUrl,_that.videoUrl,_that.caption,_that.createdAt,_that.likeCount,_that.commentCount);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String uid,  String authorUsername,  String? authorAvatarUrl,  String videoUrl,  String caption,  DateTime createdAt,  int likeCount,  int commentCount)?  $default,) {final _that = this;
switch (_that) {
case _Reel() when $default != null:
return $default(_that.id,_that.uid,_that.authorUsername,_that.authorAvatarUrl,_that.videoUrl,_that.caption,_that.createdAt,_that.likeCount,_that.commentCount);case _:
  return null;

}
}

}

/// @nodoc


class _Reel implements Reel {
  const _Reel({required this.id, required this.uid, required this.authorUsername, this.authorAvatarUrl, required this.videoUrl, this.caption = '', required this.createdAt, this.likeCount = 0, this.commentCount = 0});
  

@override final  String id;
@override final  String uid;
@override final  String authorUsername;
@override final  String? authorAvatarUrl;
@override final  String videoUrl;
@override@JsonKey() final  String caption;
@override final  DateTime createdAt;
@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int commentCount;

/// Create a copy of Reel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReelCopyWith<_Reel> get copyWith => __$ReelCopyWithImpl<_Reel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reel&&(identical(other.id, id) || other.id == id)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.authorUsername, authorUsername) || other.authorUsername == authorUsername)&&(identical(other.authorAvatarUrl, authorAvatarUrl) || other.authorAvatarUrl == authorAvatarUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,uid,authorUsername,authorAvatarUrl,videoUrl,caption,createdAt,likeCount,commentCount);

@override
String toString() {
  return 'Reel(id: $id, uid: $uid, authorUsername: $authorUsername, authorAvatarUrl: $authorAvatarUrl, videoUrl: $videoUrl, caption: $caption, createdAt: $createdAt, likeCount: $likeCount, commentCount: $commentCount)';
}


}

/// @nodoc
abstract mixin class _$ReelCopyWith<$Res> implements $ReelCopyWith<$Res> {
  factory _$ReelCopyWith(_Reel value, $Res Function(_Reel) _then) = __$ReelCopyWithImpl;
@override @useResult
$Res call({
 String id, String uid, String authorUsername, String? authorAvatarUrl, String videoUrl, String caption, DateTime createdAt, int likeCount, int commentCount
});




}
/// @nodoc
class __$ReelCopyWithImpl<$Res>
    implements _$ReelCopyWith<$Res> {
  __$ReelCopyWithImpl(this._self, this._then);

  final _Reel _self;
  final $Res Function(_Reel) _then;

/// Create a copy of Reel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uid = null,Object? authorUsername = null,Object? authorAvatarUrl = freezed,Object? videoUrl = null,Object? caption = null,Object? createdAt = null,Object? likeCount = null,Object? commentCount = null,}) {
  return _then(_Reel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,authorUsername: null == authorUsername ? _self.authorUsername : authorUsername // ignore: cast_nullable_to_non_nullable
as String,authorAvatarUrl: freezed == authorAvatarUrl ? _self.authorAvatarUrl : authorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
