// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stories_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoriesState {

 StoriesStatus get status; List<StoryTray> get trays; Set<String> get viewedIds; String? get error;
/// Create a copy of StoriesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoriesStateCopyWith<StoriesState> get copyWith => _$StoriesStateCopyWithImpl<StoriesState>(this as StoriesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoriesState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.trays, trays)&&const DeepCollectionEquality().equals(other.viewedIds, viewedIds)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(trays),const DeepCollectionEquality().hash(viewedIds),error);

@override
String toString() {
  return 'StoriesState(status: $status, trays: $trays, viewedIds: $viewedIds, error: $error)';
}


}

/// @nodoc
abstract mixin class $StoriesStateCopyWith<$Res>  {
  factory $StoriesStateCopyWith(StoriesState value, $Res Function(StoriesState) _then) = _$StoriesStateCopyWithImpl;
@useResult
$Res call({
 StoriesStatus status, List<StoryTray> trays, Set<String> viewedIds, String? error
});




}
/// @nodoc
class _$StoriesStateCopyWithImpl<$Res>
    implements $StoriesStateCopyWith<$Res> {
  _$StoriesStateCopyWithImpl(this._self, this._then);

  final StoriesState _self;
  final $Res Function(StoriesState) _then;

/// Create a copy of StoriesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? trays = null,Object? viewedIds = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StoriesStatus,trays: null == trays ? _self.trays : trays // ignore: cast_nullable_to_non_nullable
as List<StoryTray>,viewedIds: null == viewedIds ? _self.viewedIds : viewedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StoriesState].
extension StoriesStatePatterns on StoriesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoriesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoriesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoriesState value)  $default,){
final _that = this;
switch (_that) {
case _StoriesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoriesState value)?  $default,){
final _that = this;
switch (_that) {
case _StoriesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StoriesStatus status,  List<StoryTray> trays,  Set<String> viewedIds,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoriesState() when $default != null:
return $default(_that.status,_that.trays,_that.viewedIds,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StoriesStatus status,  List<StoryTray> trays,  Set<String> viewedIds,  String? error)  $default,) {final _that = this;
switch (_that) {
case _StoriesState():
return $default(_that.status,_that.trays,_that.viewedIds,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StoriesStatus status,  List<StoryTray> trays,  Set<String> viewedIds,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _StoriesState() when $default != null:
return $default(_that.status,_that.trays,_that.viewedIds,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _StoriesState implements StoriesState {
  const _StoriesState({this.status = StoriesStatus.loading, final  List<StoryTray> trays = const <StoryTray>[], final  Set<String> viewedIds = const <String>{}, this.error}): _trays = trays,_viewedIds = viewedIds;
  

@override@JsonKey() final  StoriesStatus status;
 final  List<StoryTray> _trays;
@override@JsonKey() List<StoryTray> get trays {
  if (_trays is EqualUnmodifiableListView) return _trays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trays);
}

 final  Set<String> _viewedIds;
@override@JsonKey() Set<String> get viewedIds {
  if (_viewedIds is EqualUnmodifiableSetView) return _viewedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_viewedIds);
}

@override final  String? error;

/// Create a copy of StoriesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoriesStateCopyWith<_StoriesState> get copyWith => __$StoriesStateCopyWithImpl<_StoriesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoriesState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._trays, _trays)&&const DeepCollectionEquality().equals(other._viewedIds, _viewedIds)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_trays),const DeepCollectionEquality().hash(_viewedIds),error);

@override
String toString() {
  return 'StoriesState(status: $status, trays: $trays, viewedIds: $viewedIds, error: $error)';
}


}

/// @nodoc
abstract mixin class _$StoriesStateCopyWith<$Res> implements $StoriesStateCopyWith<$Res> {
  factory _$StoriesStateCopyWith(_StoriesState value, $Res Function(_StoriesState) _then) = __$StoriesStateCopyWithImpl;
@override @useResult
$Res call({
 StoriesStatus status, List<StoryTray> trays, Set<String> viewedIds, String? error
});




}
/// @nodoc
class __$StoriesStateCopyWithImpl<$Res>
    implements _$StoriesStateCopyWith<$Res> {
  __$StoriesStateCopyWithImpl(this._self, this._then);

  final _StoriesState _self;
  final $Res Function(_StoriesState) _then;

/// Create a copy of StoriesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? trays = null,Object? viewedIds = null,Object? error = freezed,}) {
  return _then(_StoriesState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as StoriesStatus,trays: null == trays ? _self._trays : trays // ignore: cast_nullable_to_non_nullable
as List<StoryTray>,viewedIds: null == viewedIds ? _self._viewedIds : viewedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
