// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_post_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreatePostState {

 List<String> get pickedPaths; String get caption; bool get submitting; bool get success; String? get error;
/// Create a copy of CreatePostState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePostStateCopyWith<CreatePostState> get copyWith => _$CreatePostStateCopyWithImpl<CreatePostState>(this as CreatePostState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePostState&&const DeepCollectionEquality().equals(other.pickedPaths, pickedPaths)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(pickedPaths),caption,submitting,success,error);

@override
String toString() {
  return 'CreatePostState(pickedPaths: $pickedPaths, caption: $caption, submitting: $submitting, success: $success, error: $error)';
}


}

/// @nodoc
abstract mixin class $CreatePostStateCopyWith<$Res>  {
  factory $CreatePostStateCopyWith(CreatePostState value, $Res Function(CreatePostState) _then) = _$CreatePostStateCopyWithImpl;
@useResult
$Res call({
 List<String> pickedPaths, String caption, bool submitting, bool success, String? error
});




}
/// @nodoc
class _$CreatePostStateCopyWithImpl<$Res>
    implements $CreatePostStateCopyWith<$Res> {
  _$CreatePostStateCopyWithImpl(this._self, this._then);

  final CreatePostState _self;
  final $Res Function(CreatePostState) _then;

/// Create a copy of CreatePostState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pickedPaths = null,Object? caption = null,Object? submitting = null,Object? success = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
pickedPaths: null == pickedPaths ? _self.pickedPaths : pickedPaths // ignore: cast_nullable_to_non_nullable
as List<String>,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreatePostState].
extension CreatePostStatePatterns on CreatePostState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePostState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePostState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePostState value)  $default,){
final _that = this;
switch (_that) {
case _CreatePostState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePostState value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePostState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> pickedPaths,  String caption,  bool submitting,  bool success,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatePostState() when $default != null:
return $default(_that.pickedPaths,_that.caption,_that.submitting,_that.success,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> pickedPaths,  String caption,  bool submitting,  bool success,  String? error)  $default,) {final _that = this;
switch (_that) {
case _CreatePostState():
return $default(_that.pickedPaths,_that.caption,_that.submitting,_that.success,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> pickedPaths,  String caption,  bool submitting,  bool success,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _CreatePostState() when $default != null:
return $default(_that.pickedPaths,_that.caption,_that.submitting,_that.success,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _CreatePostState implements CreatePostState {
  const _CreatePostState({final  List<String> pickedPaths = const <String>[], this.caption = '', this.submitting = false, this.success = false, this.error}): _pickedPaths = pickedPaths;
  

 final  List<String> _pickedPaths;
@override@JsonKey() List<String> get pickedPaths {
  if (_pickedPaths is EqualUnmodifiableListView) return _pickedPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pickedPaths);
}

@override@JsonKey() final  String caption;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool success;
@override final  String? error;

/// Create a copy of CreatePostState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePostStateCopyWith<_CreatePostState> get copyWith => __$CreatePostStateCopyWithImpl<_CreatePostState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePostState&&const DeepCollectionEquality().equals(other._pickedPaths, _pickedPaths)&&(identical(other.caption, caption) || other.caption == caption)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_pickedPaths),caption,submitting,success,error);

@override
String toString() {
  return 'CreatePostState(pickedPaths: $pickedPaths, caption: $caption, submitting: $submitting, success: $success, error: $error)';
}


}

/// @nodoc
abstract mixin class _$CreatePostStateCopyWith<$Res> implements $CreatePostStateCopyWith<$Res> {
  factory _$CreatePostStateCopyWith(_CreatePostState value, $Res Function(_CreatePostState) _then) = __$CreatePostStateCopyWithImpl;
@override @useResult
$Res call({
 List<String> pickedPaths, String caption, bool submitting, bool success, String? error
});




}
/// @nodoc
class __$CreatePostStateCopyWithImpl<$Res>
    implements _$CreatePostStateCopyWith<$Res> {
  __$CreatePostStateCopyWithImpl(this._self, this._then);

  final _CreatePostState _self;
  final $Res Function(_CreatePostState) _then;

/// Create a copy of CreatePostState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pickedPaths = null,Object? caption = null,Object? submitting = null,Object? success = null,Object? error = freezed,}) {
  return _then(_CreatePostState(
pickedPaths: null == pickedPaths ? _self._pickedPaths : pickedPaths // ignore: cast_nullable_to_non_nullable
as List<String>,caption: null == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
