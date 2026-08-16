// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feed_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedState {

 FeedStatus get status; List<Post> get posts; Set<String> get likedIds; bool get hasMore; String? get error;
/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedStateCopyWith<FeedState> get copyWith => _$FeedStateCopyWithImpl<FeedState>(this as FeedState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.posts, posts)&&const DeepCollectionEquality().equals(other.likedIds, likedIds)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(posts),const DeepCollectionEquality().hash(likedIds),hasMore,error);

@override
String toString() {
  return 'FeedState(status: $status, posts: $posts, likedIds: $likedIds, hasMore: $hasMore, error: $error)';
}


}

/// @nodoc
abstract mixin class $FeedStateCopyWith<$Res>  {
  factory $FeedStateCopyWith(FeedState value, $Res Function(FeedState) _then) = _$FeedStateCopyWithImpl;
@useResult
$Res call({
 FeedStatus status, List<Post> posts, Set<String> likedIds, bool hasMore, String? error
});




}
/// @nodoc
class _$FeedStateCopyWithImpl<$Res>
    implements $FeedStateCopyWith<$Res> {
  _$FeedStateCopyWithImpl(this._self, this._then);

  final FeedState _self;
  final $Res Function(FeedState) _then;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? posts = null,Object? likedIds = null,Object? hasMore = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FeedStatus,posts: null == posts ? _self.posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,likedIds: null == likedIds ? _self.likedIds : likedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedState].
extension FeedStatePatterns on FeedState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedState value)  $default,){
final _that = this;
switch (_that) {
case _FeedState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedState value)?  $default,){
final _that = this;
switch (_that) {
case _FeedState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FeedStatus status,  List<Post> posts,  Set<String> likedIds,  bool hasMore,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedState() when $default != null:
return $default(_that.status,_that.posts,_that.likedIds,_that.hasMore,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FeedStatus status,  List<Post> posts,  Set<String> likedIds,  bool hasMore,  String? error)  $default,) {final _that = this;
switch (_that) {
case _FeedState():
return $default(_that.status,_that.posts,_that.likedIds,_that.hasMore,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FeedStatus status,  List<Post> posts,  Set<String> likedIds,  bool hasMore,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _FeedState() when $default != null:
return $default(_that.status,_that.posts,_that.likedIds,_that.hasMore,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _FeedState implements FeedState {
  const _FeedState({this.status = FeedStatus.loading, final  List<Post> posts = const <Post>[], final  Set<String> likedIds = const <String>{}, this.hasMore = true, this.error}): _posts = posts,_likedIds = likedIds;
  

@override@JsonKey() final  FeedStatus status;
 final  List<Post> _posts;
@override@JsonKey() List<Post> get posts {
  if (_posts is EqualUnmodifiableListView) return _posts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_posts);
}

 final  Set<String> _likedIds;
@override@JsonKey() Set<String> get likedIds {
  if (_likedIds is EqualUnmodifiableSetView) return _likedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_likedIds);
}

@override@JsonKey() final  bool hasMore;
@override final  String? error;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedStateCopyWith<_FeedState> get copyWith => __$FeedStateCopyWithImpl<_FeedState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._posts, _posts)&&const DeepCollectionEquality().equals(other._likedIds, _likedIds)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_posts),const DeepCollectionEquality().hash(_likedIds),hasMore,error);

@override
String toString() {
  return 'FeedState(status: $status, posts: $posts, likedIds: $likedIds, hasMore: $hasMore, error: $error)';
}


}

/// @nodoc
abstract mixin class _$FeedStateCopyWith<$Res> implements $FeedStateCopyWith<$Res> {
  factory _$FeedStateCopyWith(_FeedState value, $Res Function(_FeedState) _then) = __$FeedStateCopyWithImpl;
@override @useResult
$Res call({
 FeedStatus status, List<Post> posts, Set<String> likedIds, bool hasMore, String? error
});




}
/// @nodoc
class __$FeedStateCopyWithImpl<$Res>
    implements _$FeedStateCopyWith<$Res> {
  __$FeedStateCopyWithImpl(this._self, this._then);

  final _FeedState _self;
  final $Res Function(_FeedState) _then;

/// Create a copy of FeedState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? posts = null,Object? likedIds = null,Object? hasMore = null,Object? error = freezed,}) {
  return _then(_FeedState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as FeedStatus,posts: null == posts ? _self._posts : posts // ignore: cast_nullable_to_non_nullable
as List<Post>,likedIds: null == likedIds ? _self._likedIds : likedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
