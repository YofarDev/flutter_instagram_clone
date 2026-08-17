// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reels_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReelsState {

 ReelsStatus get status; List<Reel> get reels; Set<String> get likedIds; bool get hasMore; String? get error;
/// Create a copy of ReelsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReelsStateCopyWith<ReelsState> get copyWith => _$ReelsStateCopyWithImpl<ReelsState>(this as ReelsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReelsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.reels, reels)&&const DeepCollectionEquality().equals(other.likedIds, likedIds)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(reels),const DeepCollectionEquality().hash(likedIds),hasMore,error);

@override
String toString() {
  return 'ReelsState(status: $status, reels: $reels, likedIds: $likedIds, hasMore: $hasMore, error: $error)';
}


}

/// @nodoc
abstract mixin class $ReelsStateCopyWith<$Res>  {
  factory $ReelsStateCopyWith(ReelsState value, $Res Function(ReelsState) _then) = _$ReelsStateCopyWithImpl;
@useResult
$Res call({
 ReelsStatus status, List<Reel> reels, Set<String> likedIds, bool hasMore, String? error
});




}
/// @nodoc
class _$ReelsStateCopyWithImpl<$Res>
    implements $ReelsStateCopyWith<$Res> {
  _$ReelsStateCopyWithImpl(this._self, this._then);

  final ReelsState _self;
  final $Res Function(ReelsState) _then;

/// Create a copy of ReelsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? reels = null,Object? likedIds = null,Object? hasMore = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReelsStatus,reels: null == reels ? _self.reels : reels // ignore: cast_nullable_to_non_nullable
as List<Reel>,likedIds: null == likedIds ? _self.likedIds : likedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReelsState].
extension ReelsStatePatterns on ReelsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReelsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReelsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReelsState value)  $default,){
final _that = this;
switch (_that) {
case _ReelsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReelsState value)?  $default,){
final _that = this;
switch (_that) {
case _ReelsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReelsStatus status,  List<Reel> reels,  Set<String> likedIds,  bool hasMore,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReelsState() when $default != null:
return $default(_that.status,_that.reels,_that.likedIds,_that.hasMore,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReelsStatus status,  List<Reel> reels,  Set<String> likedIds,  bool hasMore,  String? error)  $default,) {final _that = this;
switch (_that) {
case _ReelsState():
return $default(_that.status,_that.reels,_that.likedIds,_that.hasMore,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReelsStatus status,  List<Reel> reels,  Set<String> likedIds,  bool hasMore,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _ReelsState() when $default != null:
return $default(_that.status,_that.reels,_that.likedIds,_that.hasMore,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ReelsState implements ReelsState {
  const _ReelsState({this.status = ReelsStatus.loading, final  List<Reel> reels = const <Reel>[], final  Set<String> likedIds = const <String>{}, this.hasMore = true, this.error}): _reels = reels,_likedIds = likedIds;
  

@override@JsonKey() final  ReelsStatus status;
 final  List<Reel> _reels;
@override@JsonKey() List<Reel> get reels {
  if (_reels is EqualUnmodifiableListView) return _reels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reels);
}

 final  Set<String> _likedIds;
@override@JsonKey() Set<String> get likedIds {
  if (_likedIds is EqualUnmodifiableSetView) return _likedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_likedIds);
}

@override@JsonKey() final  bool hasMore;
@override final  String? error;

/// Create a copy of ReelsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReelsStateCopyWith<_ReelsState> get copyWith => __$ReelsStateCopyWithImpl<_ReelsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReelsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._reels, _reels)&&const DeepCollectionEquality().equals(other._likedIds, _likedIds)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_reels),const DeepCollectionEquality().hash(_likedIds),hasMore,error);

@override
String toString() {
  return 'ReelsState(status: $status, reels: $reels, likedIds: $likedIds, hasMore: $hasMore, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ReelsStateCopyWith<$Res> implements $ReelsStateCopyWith<$Res> {
  factory _$ReelsStateCopyWith(_ReelsState value, $Res Function(_ReelsState) _then) = __$ReelsStateCopyWithImpl;
@override @useResult
$Res call({
 ReelsStatus status, List<Reel> reels, Set<String> likedIds, bool hasMore, String? error
});




}
/// @nodoc
class __$ReelsStateCopyWithImpl<$Res>
    implements _$ReelsStateCopyWith<$Res> {
  __$ReelsStateCopyWithImpl(this._self, this._then);

  final _ReelsState _self;
  final $Res Function(_ReelsState) _then;

/// Create a copy of ReelsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? reels = null,Object? likedIds = null,Object? hasMore = null,Object? error = freezed,}) {
  return _then(_ReelsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReelsStatus,reels: null == reels ? _self._reels : reels // ignore: cast_nullable_to_non_nullable
as List<Reel>,likedIds: null == likedIds ? _self._likedIds : likedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
