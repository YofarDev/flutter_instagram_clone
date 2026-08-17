// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationItem {

 String get id; NotificationType get type; String get ownerUid; String get actorId; String get actorUsername; String? get actorAvatarUrl; String? get postId; String? get postImageUrl; String? get commentText; DateTime get createdAt; bool get read;
/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationItemCopyWith<NotificationItem> get copyWith => _$NotificationItemCopyWithImpl<NotificationItem>(this as NotificationItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.actorUsername, actorUsername) || other.actorUsername == actorUsername)&&(identical(other.actorAvatarUrl, actorAvatarUrl) || other.actorAvatarUrl == actorAvatarUrl)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.postImageUrl, postImageUrl) || other.postImageUrl == postImageUrl)&&(identical(other.commentText, commentText) || other.commentText == commentText)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.read, read) || other.read == read));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,ownerUid,actorId,actorUsername,actorAvatarUrl,postId,postImageUrl,commentText,createdAt,read);

@override
String toString() {
  return 'NotificationItem(id: $id, type: $type, ownerUid: $ownerUid, actorId: $actorId, actorUsername: $actorUsername, actorAvatarUrl: $actorAvatarUrl, postId: $postId, postImageUrl: $postImageUrl, commentText: $commentText, createdAt: $createdAt, read: $read)';
}


}

/// @nodoc
abstract mixin class $NotificationItemCopyWith<$Res>  {
  factory $NotificationItemCopyWith(NotificationItem value, $Res Function(NotificationItem) _then) = _$NotificationItemCopyWithImpl;
@useResult
$Res call({
 String id, NotificationType type, String ownerUid, String actorId, String actorUsername, String? actorAvatarUrl, String? postId, String? postImageUrl, String? commentText, DateTime createdAt, bool read
});




}
/// @nodoc
class _$NotificationItemCopyWithImpl<$Res>
    implements $NotificationItemCopyWith<$Res> {
  _$NotificationItemCopyWithImpl(this._self, this._then);

  final NotificationItem _self;
  final $Res Function(NotificationItem) _then;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? ownerUid = null,Object? actorId = null,Object? actorUsername = null,Object? actorAvatarUrl = freezed,Object? postId = freezed,Object? postImageUrl = freezed,Object? commentText = freezed,Object? createdAt = null,Object? read = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,actorUsername: null == actorUsername ? _self.actorUsername : actorUsername // ignore: cast_nullable_to_non_nullable
as String,actorAvatarUrl: freezed == actorAvatarUrl ? _self.actorAvatarUrl : actorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String?,postImageUrl: freezed == postImageUrl ? _self.postImageUrl : postImageUrl // ignore: cast_nullable_to_non_nullable
as String?,commentText: freezed == commentText ? _self.commentText : commentText // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationItem].
extension NotificationItemPatterns on NotificationItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationItem value)  $default,){
final _that = this;
switch (_that) {
case _NotificationItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationItem value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  NotificationType type,  String ownerUid,  String actorId,  String actorUsername,  String? actorAvatarUrl,  String? postId,  String? postImageUrl,  String? commentText,  DateTime createdAt,  bool read)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
return $default(_that.id,_that.type,_that.ownerUid,_that.actorId,_that.actorUsername,_that.actorAvatarUrl,_that.postId,_that.postImageUrl,_that.commentText,_that.createdAt,_that.read);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  NotificationType type,  String ownerUid,  String actorId,  String actorUsername,  String? actorAvatarUrl,  String? postId,  String? postImageUrl,  String? commentText,  DateTime createdAt,  bool read)  $default,) {final _that = this;
switch (_that) {
case _NotificationItem():
return $default(_that.id,_that.type,_that.ownerUid,_that.actorId,_that.actorUsername,_that.actorAvatarUrl,_that.postId,_that.postImageUrl,_that.commentText,_that.createdAt,_that.read);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  NotificationType type,  String ownerUid,  String actorId,  String actorUsername,  String? actorAvatarUrl,  String? postId,  String? postImageUrl,  String? commentText,  DateTime createdAt,  bool read)?  $default,) {final _that = this;
switch (_that) {
case _NotificationItem() when $default != null:
return $default(_that.id,_that.type,_that.ownerUid,_that.actorId,_that.actorUsername,_that.actorAvatarUrl,_that.postId,_that.postImageUrl,_that.commentText,_that.createdAt,_that.read);case _:
  return null;

}
}

}

/// @nodoc


class _NotificationItem implements NotificationItem {
  const _NotificationItem({required this.id, required this.type, required this.ownerUid, required this.actorId, required this.actorUsername, this.actorAvatarUrl, this.postId, this.postImageUrl, this.commentText, required this.createdAt, this.read = false});
  

@override final  String id;
@override final  NotificationType type;
@override final  String ownerUid;
@override final  String actorId;
@override final  String actorUsername;
@override final  String? actorAvatarUrl;
@override final  String? postId;
@override final  String? postImageUrl;
@override final  String? commentText;
@override final  DateTime createdAt;
@override@JsonKey() final  bool read;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationItemCopyWith<_NotificationItem> get copyWith => __$NotificationItemCopyWithImpl<_NotificationItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationItem&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&(identical(other.actorId, actorId) || other.actorId == actorId)&&(identical(other.actorUsername, actorUsername) || other.actorUsername == actorUsername)&&(identical(other.actorAvatarUrl, actorAvatarUrl) || other.actorAvatarUrl == actorAvatarUrl)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.postImageUrl, postImageUrl) || other.postImageUrl == postImageUrl)&&(identical(other.commentText, commentText) || other.commentText == commentText)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.read, read) || other.read == read));
}


@override
int get hashCode => Object.hash(runtimeType,id,type,ownerUid,actorId,actorUsername,actorAvatarUrl,postId,postImageUrl,commentText,createdAt,read);

@override
String toString() {
  return 'NotificationItem(id: $id, type: $type, ownerUid: $ownerUid, actorId: $actorId, actorUsername: $actorUsername, actorAvatarUrl: $actorAvatarUrl, postId: $postId, postImageUrl: $postImageUrl, commentText: $commentText, createdAt: $createdAt, read: $read)';
}


}

/// @nodoc
abstract mixin class _$NotificationItemCopyWith<$Res> implements $NotificationItemCopyWith<$Res> {
  factory _$NotificationItemCopyWith(_NotificationItem value, $Res Function(_NotificationItem) _then) = __$NotificationItemCopyWithImpl;
@override @useResult
$Res call({
 String id, NotificationType type, String ownerUid, String actorId, String actorUsername, String? actorAvatarUrl, String? postId, String? postImageUrl, String? commentText, DateTime createdAt, bool read
});




}
/// @nodoc
class __$NotificationItemCopyWithImpl<$Res>
    implements _$NotificationItemCopyWith<$Res> {
  __$NotificationItemCopyWithImpl(this._self, this._then);

  final _NotificationItem _self;
  final $Res Function(_NotificationItem) _then;

/// Create a copy of NotificationItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? ownerUid = null,Object? actorId = null,Object? actorUsername = null,Object? actorAvatarUrl = freezed,Object? postId = freezed,Object? postImageUrl = freezed,Object? commentText = freezed,Object? createdAt = null,Object? read = null,}) {
  return _then(_NotificationItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,actorId: null == actorId ? _self.actorId : actorId // ignore: cast_nullable_to_non_nullable
as String,actorUsername: null == actorUsername ? _self.actorUsername : actorUsername // ignore: cast_nullable_to_non_nullable
as String,actorAvatarUrl: freezed == actorAvatarUrl ? _self.actorAvatarUrl : actorAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String?,postImageUrl: freezed == postImageUrl ? _self.postImageUrl : postImageUrl // ignore: cast_nullable_to_non_nullable
as String?,commentText: freezed == commentText ? _self.commentText : commentText // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,read: null == read ? _self.read : read // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
