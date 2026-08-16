// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FollowListState {

 List<AppUser> get users; bool get loading; String? get error;
/// Create a copy of FollowListState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowListStateCopyWith<FollowListState> get copyWith => _$FollowListStateCopyWithImpl<FollowListState>(this as FollowListState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowListState&&const DeepCollectionEquality().equals(other.users, users)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(users),loading,error);

@override
String toString() {
  return 'FollowListState(users: $users, loading: $loading, error: $error)';
}


}

/// @nodoc
abstract mixin class $FollowListStateCopyWith<$Res>  {
  factory $FollowListStateCopyWith(FollowListState value, $Res Function(FollowListState) _then) = _$FollowListStateCopyWithImpl;
@useResult
$Res call({
 List<AppUser> users, bool loading, String? error
});




}
/// @nodoc
class _$FollowListStateCopyWithImpl<$Res>
    implements $FollowListStateCopyWith<$Res> {
  _$FollowListStateCopyWithImpl(this._self, this._then);

  final FollowListState _self;
  final $Res Function(FollowListState) _then;

/// Create a copy of FollowListState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? users = null,Object? loading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<AppUser>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowListState].
extension FollowListStatePatterns on FollowListState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowListState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowListState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowListState value)  $default,){
final _that = this;
switch (_that) {
case _FollowListState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowListState value)?  $default,){
final _that = this;
switch (_that) {
case _FollowListState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<AppUser> users,  bool loading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowListState() when $default != null:
return $default(_that.users,_that.loading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<AppUser> users,  bool loading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _FollowListState():
return $default(_that.users,_that.loading,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<AppUser> users,  bool loading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _FollowListState() when $default != null:
return $default(_that.users,_that.loading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _FollowListState implements FollowListState {
  const _FollowListState({final  List<AppUser> users = const <AppUser>[], this.loading = false, this.error}): _users = users;
  

 final  List<AppUser> _users;
@override@JsonKey() List<AppUser> get users {
  if (_users is EqualUnmodifiableListView) return _users;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_users);
}

@override@JsonKey() final  bool loading;
@override final  String? error;

/// Create a copy of FollowListState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowListStateCopyWith<_FollowListState> get copyWith => __$FollowListStateCopyWithImpl<_FollowListState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowListState&&const DeepCollectionEquality().equals(other._users, _users)&&(identical(other.loading, loading) || other.loading == loading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_users),loading,error);

@override
String toString() {
  return 'FollowListState(users: $users, loading: $loading, error: $error)';
}


}

/// @nodoc
abstract mixin class _$FollowListStateCopyWith<$Res> implements $FollowListStateCopyWith<$Res> {
  factory _$FollowListStateCopyWith(_FollowListState value, $Res Function(_FollowListState) _then) = __$FollowListStateCopyWithImpl;
@override @useResult
$Res call({
 List<AppUser> users, bool loading, String? error
});




}
/// @nodoc
class __$FollowListStateCopyWithImpl<$Res>
    implements _$FollowListStateCopyWith<$Res> {
  __$FollowListStateCopyWithImpl(this._self, this._then);

  final _FollowListState _self;
  final $Res Function(_FollowListState) _then;

/// Create a copy of FollowListState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? users = null,Object? loading = null,Object? error = freezed,}) {
  return _then(_FollowListState(
users: null == users ? _self._users : users // ignore: cast_nullable_to_non_nullable
as List<AppUser>,loading: null == loading ? _self.loading : loading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
