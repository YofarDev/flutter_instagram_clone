// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'hashtag_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HashtagState {

 HashtagStatus get status; List<Post> get posts; String? get error;
/// Create a copy of HashtagState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HashtagStateCopyWith<HashtagState> get copyWith => _$HashtagStateCopyWithImpl<HashtagState>(this as HashtagState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HashtagState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.posts, posts)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(posts),error);

@override
String toString() {
  return 'HashtagState(status: $status, posts: $posts, error: $error)';
}


}

/// @nodoc
abstract mixin class $HashtagStateCopyWith<$Res>  {
  factory $HashtagStateCopyWith(HashtagState value, $Res Function(HashtagState) _then) = _$HashtagStateCopyWithImpl;
@useResult
$Res call({
 HashtagStatus status, List<Post> posts, String? error
});




}
/// @nodoc
class _$HashtagStateCopyWithImpl<$Res>
    implements $HashtagStateCopyWith<$Res> {
  _$HashtagStateCopyWithImpl(this._self, this._then);

  final HashtagState _self;
  final $Res Function(HashtagState) _then;

/// Create a copy of HashtagState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? posts = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HashtagStatus,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HashtagState].
extension HashtagStatePatterns on HashtagState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HashtagState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HashtagState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HashtagState value)  $default,){
final _that = this;
switch (_that) {
case _HashtagState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HashtagState value)?  $default,){
final _that = this;
switch (_that) {
case _HashtagState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HashtagStatus status,  List<Post> posts,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HashtagState() when $default != null:
return $default(_that.status,_that.posts,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HashtagStatus status,  List<Post> posts,  String? error)  $default,) {final _that = this;
switch (_that) {
case _HashtagState():
return $default(_that.status,_that.posts,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HashtagStatus status,  List<Post> posts,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _HashtagState() when $default != null:
return $default(_that.status,_that.posts,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _HashtagState implements HashtagState {
  const _HashtagState({this.status = HashtagStatus.loading, final  List<Post> posts = const <Post>[], this.error}): _posts = posts;
  

@override@JsonKey() final  HashtagStatus status;
 final  List<Post> _posts;
@override@JsonKey() List<Post> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

@override final  String? error;

/// Create a copy of HashtagState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HashtagStateCopyWith<_HashtagState> get copyWith => __$HashtagStateCopyWithImpl<_HashtagState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HashtagState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._posts, _posts)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_posts),error);

@override
String toString() {
  return 'HashtagState(status: $status, posts: $posts, error: $error)';
}


}

/// @nodoc
abstract mixin class _$HashtagStateCopyWith<$Res> implements $HashtagStateCopyWith<$Res> {
  factory _$HashtagStateCopyWith(_HashtagState value, $Res Function(_HashtagState) _then) = __$HashtagStateCopyWithImpl;
@override @useResult
$Res call({
 HashtagStatus status, List<Post> posts, String? error
});




}
/// @nodoc
class __$HashtagStateCopyWithImpl<$Res>
    implements _$HashtagStateCopyWith<$Res> {
  __$HashtagStateCopyWithImpl(this._self, this._then);

  final _HashtagState _self;
  final $Res Function(_HashtagState) _then;

/// Create a copy of HashtagState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? posts = null,Object? error = freezed,}) {
  return _then(_HashtagState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HashtagStatus,posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
