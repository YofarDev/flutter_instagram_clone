// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_story_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreateStoryState {

 String? get pickedPath; bool get submitting; bool get success; String? get error;
/// Create a copy of CreateStoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateStoryStateCopyWith<CreateStoryState> get copyWith => _$CreateStoryStateCopyWithImpl<CreateStoryState>(this as CreateStoryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateStoryState&&(identical(other.pickedPath, pickedPath) || other.pickedPath == pickedPath)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,pickedPath,submitting,success,error);

@override
String toString() {
  return 'CreateStoryState(pickedPath: $pickedPath, submitting: $submitting, success: $success, error: $error)';
}


}

/// @nodoc
abstract mixin class $CreateStoryStateCopyWith<$Res>  {
  factory $CreateStoryStateCopyWith(CreateStoryState value, $Res Function(CreateStoryState) _then) = _$CreateStoryStateCopyWithImpl;
@useResult
$Res call({
 String? pickedPath, bool submitting, bool success, String? error
});




}
/// @nodoc
class _$CreateStoryStateCopyWithImpl<$Res>
    implements $CreateStoryStateCopyWith<$Res> {
  _$CreateStoryStateCopyWithImpl(this._self, this._then);

  final CreateStoryState _self;
  final $Res Function(CreateStoryState) _then;

/// Create a copy of CreateStoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pickedPath = freezed,Object? submitting = null,Object? success = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
pickedPath: freezed == pickedPath ? _self.pickedPath : pickedPath // ignore: cast_nullable_to_non_nullable
as String?,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateStoryState].
extension CreateStoryStatePatterns on CreateStoryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateStoryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateStoryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateStoryState value)  $default,){
final _that = this;
switch (_that) {
case _CreateStoryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateStoryState value)?  $default,){
final _that = this;
switch (_that) {
case _CreateStoryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? pickedPath,  bool submitting,  bool success,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateStoryState() when $default != null:
return $default(_that.pickedPath,_that.submitting,_that.success,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? pickedPath,  bool submitting,  bool success,  String? error)  $default,) {final _that = this;
switch (_that) {
case _CreateStoryState():
return $default(_that.pickedPath,_that.submitting,_that.success,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? pickedPath,  bool submitting,  bool success,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _CreateStoryState() when $default != null:
return $default(_that.pickedPath,_that.submitting,_that.success,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CreateStoryState implements CreateStoryState {
  const _CreateStoryState({this.pickedPath, this.submitting = false, this.success = false, this.error});
  

@override final  String? pickedPath;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool success;
@override final  String? error;

/// Create a copy of CreateStoryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateStoryStateCopyWith<_CreateStoryState> get copyWith => __$CreateStoryStateCopyWithImpl<_CreateStoryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateStoryState&&(identical(other.pickedPath, pickedPath) || other.pickedPath == pickedPath)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,pickedPath,submitting,success,error);

@override
String toString() {
  return 'CreateStoryState(pickedPath: $pickedPath, submitting: $submitting, success: $success, error: $error)';
}


}

/// @nodoc
abstract mixin class _$CreateStoryStateCopyWith<$Res> implements $CreateStoryStateCopyWith<$Res> {
  factory _$CreateStoryStateCopyWith(_CreateStoryState value, $Res Function(_CreateStoryState) _then) = __$CreateStoryStateCopyWithImpl;
@override @useResult
$Res call({
 String? pickedPath, bool submitting, bool success, String? error
});




}
/// @nodoc
class __$CreateStoryStateCopyWithImpl<$Res>
    implements _$CreateStoryStateCopyWith<$Res> {
  __$CreateStoryStateCopyWithImpl(this._self, this._then);

  final _CreateStoryState _self;
  final $Res Function(_CreateStoryState) _then;

/// Create a copy of CreateStoryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pickedPath = freezed,Object? submitting = null,Object? success = null,Object? error = freezed,}) {
  return _then(_CreateStoryState(
pickedPath: freezed == pickedPath ? _self.pickedPath : pickedPath // ignore: cast_nullable_to_non_nullable
as String?,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
