// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reel_comments_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ReelCommentsState {

 ReelCommentsStatus get status; List<Comment> get comments; bool get sending; String? get error;
/// Create a copy of ReelCommentsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReelCommentsStateCopyWith<ReelCommentsState> get copyWith => _$ReelCommentsStateCopyWithImpl<ReelCommentsState>(this as ReelCommentsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReelCommentsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.comments, comments)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(comments),sending,error);

@override
String toString() {
  return 'ReelCommentsState(status: $status, comments: $comments, sending: $sending, error: $error)';
}


}

/// @nodoc
abstract mixin class $ReelCommentsStateCopyWith<$Res>  {
  factory $ReelCommentsStateCopyWith(ReelCommentsState value, $Res Function(ReelCommentsState) _then) = _$ReelCommentsStateCopyWithImpl;
@useResult
$Res call({
 ReelCommentsStatus status, List<Comment> comments, bool sending, String? error
});




}
/// @nodoc
class _$ReelCommentsStateCopyWithImpl<$Res>
    implements $ReelCommentsStateCopyWith<$Res> {
  _$ReelCommentsStateCopyWithImpl(this._self, this._then);

  final ReelCommentsState _self;
  final $Res Function(ReelCommentsState) _then;

/// Create a copy of ReelCommentsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? comments = null,Object? sending = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReelCommentsStatus,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as List<Comment>,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReelCommentsState].
extension ReelCommentsStatePatterns on ReelCommentsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReelCommentsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReelCommentsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReelCommentsState value)  $default,){
final _that = this;
switch (_that) {
case _ReelCommentsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReelCommentsState value)?  $default,){
final _that = this;
switch (_that) {
case _ReelCommentsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReelCommentsStatus status,  List<Comment> comments,  bool sending,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReelCommentsState() when $default != null:
return $default(_that.status,_that.comments,_that.sending,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReelCommentsStatus status,  List<Comment> comments,  bool sending,  String? error)  $default,) {final _that = this;
switch (_that) {
case _ReelCommentsState():
return $default(_that.status,_that.comments,_that.sending,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReelCommentsStatus status,  List<Comment> comments,  bool sending,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _ReelCommentsState() when $default != null:
return $default(_that.status,_that.comments,_that.sending,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ReelCommentsState implements ReelCommentsState {
  const _ReelCommentsState({this.status = ReelCommentsStatus.loading, final  List<Comment> comments = const <Comment>[], this.sending = false, this.error}): _comments = comments;
  

@override@JsonKey() final  ReelCommentsStatus status;
 final  List<Comment> _comments;
@override@JsonKey() List<Comment> get comments {
  if (_comments is EqualUnmodifiableListView) return _comments;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comments);
}

@override@JsonKey() final  bool sending;
@override final  String? error;

/// Create a copy of ReelCommentsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReelCommentsStateCopyWith<_ReelCommentsState> get copyWith => __$ReelCommentsStateCopyWithImpl<_ReelCommentsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReelCommentsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._comments, _comments)&&(identical(other.sending, sending) || other.sending == sending)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_comments),sending,error);

@override
String toString() {
  return 'ReelCommentsState(status: $status, comments: $comments, sending: $sending, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ReelCommentsStateCopyWith<$Res> implements $ReelCommentsStateCopyWith<$Res> {
  factory _$ReelCommentsStateCopyWith(_ReelCommentsState value, $Res Function(_ReelCommentsState) _then) = __$ReelCommentsStateCopyWithImpl;
@override @useResult
$Res call({
 ReelCommentsStatus status, List<Comment> comments, bool sending, String? error
});




}
/// @nodoc
class __$ReelCommentsStateCopyWithImpl<$Res>
    implements _$ReelCommentsStateCopyWith<$Res> {
  __$ReelCommentsStateCopyWithImpl(this._self, this._then);

  final _ReelCommentsState _self;
  final $Res Function(_ReelCommentsState) _then;

/// Create a copy of ReelCommentsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? comments = null,Object? sending = null,Object? error = freezed,}) {
  return _then(_ReelCommentsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReelCommentsStatus,comments: null == comments ? _self._comments : comments // ignore: cast_nullable_to_non_nullable
as List<Comment>,sending: null == sending ? _self.sending : sending // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
