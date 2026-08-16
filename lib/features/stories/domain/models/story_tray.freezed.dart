// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_tray.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoryTray {

 String get uid; String get username; String? get avatarUrl; List<Story> get stories;
/// Create a copy of StoryTray
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryTrayCopyWith<StoryTray> get copyWith => _$StoryTrayCopyWithImpl<StoryTray>(this as StoryTray, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryTray&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&const DeepCollectionEquality().equals(other.stories, stories));
}


@override
int get hashCode => Object.hash(runtimeType,uid,username,avatarUrl,const DeepCollectionEquality().hash(stories));

@override
String toString() {
  return 'StoryTray(uid: $uid, username: $username, avatarUrl: $avatarUrl, stories: $stories)';
}


}

/// @nodoc
abstract mixin class $StoryTrayCopyWith<$Res>  {
  factory $StoryTrayCopyWith(StoryTray value, $Res Function(StoryTray) _then) = _$StoryTrayCopyWithImpl;
@useResult
$Res call({
 String uid, String username, String? avatarUrl, List<Story> stories
});




}
/// @nodoc
class _$StoryTrayCopyWithImpl<$Res>
    implements $StoryTrayCopyWith<$Res> {
  _$StoryTrayCopyWithImpl(this._self, this._then);

  final StoryTray _self;
  final $Res Function(StoryTray) _then;

/// Create a copy of StoryTray
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? username = null,Object? avatarUrl = freezed,Object? stories = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,stories: null == stories ? _self.stories : stories // ignore: cast_nullable_to_non_nullable
as List<Story>,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryTray].
extension StoryTrayPatterns on StoryTray {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryTray value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryTray() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryTray value)  $default,){
final _that = this;
switch (_that) {
case _StoryTray():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryTray value)?  $default,){
final _that = this;
switch (_that) {
case _StoryTray() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String username,  String? avatarUrl,  List<Story> stories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryTray() when $default != null:
return $default(_that.uid,_that.username,_that.avatarUrl,_that.stories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String username,  String? avatarUrl,  List<Story> stories)  $default,) {final _that = this;
switch (_that) {
case _StoryTray():
return $default(_that.uid,_that.username,_that.avatarUrl,_that.stories);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String username,  String? avatarUrl,  List<Story> stories)?  $default,) {final _that = this;
switch (_that) {
case _StoryTray() when $default != null:
return $default(_that.uid,_that.username,_that.avatarUrl,_that.stories);case _:
  return null;

}
}

}

/// @nodoc


class _StoryTray implements StoryTray {
  const _StoryTray({required this.uid, required this.username, this.avatarUrl, required final  List<Story> stories}): _stories = stories;
  

@override final  String uid;
@override final  String username;
@override final  String? avatarUrl;
 final  List<Story> _stories;
@override List<Story> get stories {
  if (_stories is EqualUnmodifiableListView) return _stories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stories);
}


/// Create a copy of StoryTray
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryTrayCopyWith<_StoryTray> get copyWith => __$StoryTrayCopyWithImpl<_StoryTray>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryTray&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.username, username) || other.username == username)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&const DeepCollectionEquality().equals(other._stories, _stories));
}


@override
int get hashCode => Object.hash(runtimeType,uid,username,avatarUrl,const DeepCollectionEquality().hash(_stories));

@override
String toString() {
  return 'StoryTray(uid: $uid, username: $username, avatarUrl: $avatarUrl, stories: $stories)';
}


}

/// @nodoc
abstract mixin class _$StoryTrayCopyWith<$Res> implements $StoryTrayCopyWith<$Res> {
  factory _$StoryTrayCopyWith(_StoryTray value, $Res Function(_StoryTray) _then) = __$StoryTrayCopyWithImpl;
@override @useResult
$Res call({
 String uid, String username, String? avatarUrl, List<Story> stories
});




}
/// @nodoc
class __$StoryTrayCopyWithImpl<$Res>
    implements _$StoryTrayCopyWith<$Res> {
  __$StoryTrayCopyWithImpl(this._self, this._then);

  final _StoryTray _self;
  final $Res Function(_StoryTray) _then;

/// Create a copy of StoryTray
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? username = null,Object? avatarUrl = freezed,Object? stories = null,}) {
  return _then(_StoryTray(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,stories: null == stories ? _self._stories : stories // ignore: cast_nullable_to_non_nullable
as List<Story>,
  ));
}


}

// dart format on
