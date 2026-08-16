// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'story_viewer_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StoryViewerState {

 List<StoryTray> get trays; int get trayIndex; int get storyIndex; Set<String> get viewedIds; bool get finished;
/// Create a copy of StoryViewerState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StoryViewerStateCopyWith<StoryViewerState> get copyWith => _$StoryViewerStateCopyWithImpl<StoryViewerState>(this as StoryViewerState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StoryViewerState&&const DeepCollectionEquality().equals(other.trays, trays)&&(identical(other.trayIndex, trayIndex) || other.trayIndex == trayIndex)&&(identical(other.storyIndex, storyIndex) || other.storyIndex == storyIndex)&&const DeepCollectionEquality().equals(other.viewedIds, viewedIds)&&(identical(other.finished, finished) || other.finished == finished));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(trays),trayIndex,storyIndex,const DeepCollectionEquality().hash(viewedIds),finished);

@override
String toString() {
  return 'StoryViewerState(trays: $trays, trayIndex: $trayIndex, storyIndex: $storyIndex, viewedIds: $viewedIds, finished: $finished)';
}


}

/// @nodoc
abstract mixin class $StoryViewerStateCopyWith<$Res>  {
  factory $StoryViewerStateCopyWith(StoryViewerState value, $Res Function(StoryViewerState) _then) = _$StoryViewerStateCopyWithImpl;
@useResult
$Res call({
 List<StoryTray> trays, int trayIndex, int storyIndex, Set<String> viewedIds, bool finished
});




}
/// @nodoc
class _$StoryViewerStateCopyWithImpl<$Res>
    implements $StoryViewerStateCopyWith<$Res> {
  _$StoryViewerStateCopyWithImpl(this._self, this._then);

  final StoryViewerState _self;
  final $Res Function(StoryViewerState) _then;

/// Create a copy of StoryViewerState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? trays = null,Object? trayIndex = null,Object? storyIndex = null,Object? viewedIds = null,Object? finished = null,}) {
  return _then(_self.copyWith(
trays: null == trays ? _self.trays : trays // ignore: cast_nullable_to_non_nullable
as List<StoryTray>,trayIndex: null == trayIndex ? _self.trayIndex : trayIndex // ignore: cast_nullable_to_non_nullable
as int,storyIndex: null == storyIndex ? _self.storyIndex : storyIndex // ignore: cast_nullable_to_non_nullable
as int,viewedIds: null == viewedIds ? _self.viewedIds : viewedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,finished: null == finished ? _self.finished : finished // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StoryViewerState].
extension StoryViewerStatePatterns on StoryViewerState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StoryViewerState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StoryViewerState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StoryViewerState value)  $default,){
final _that = this;
switch (_that) {
case _StoryViewerState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StoryViewerState value)?  $default,){
final _that = this;
switch (_that) {
case _StoryViewerState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<StoryTray> trays,  int trayIndex,  int storyIndex,  Set<String> viewedIds,  bool finished)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StoryViewerState() when $default != null:
return $default(_that.trays,_that.trayIndex,_that.storyIndex,_that.viewedIds,_that.finished);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<StoryTray> trays,  int trayIndex,  int storyIndex,  Set<String> viewedIds,  bool finished)  $default,) {final _that = this;
switch (_that) {
case _StoryViewerState():
return $default(_that.trays,_that.trayIndex,_that.storyIndex,_that.viewedIds,_that.finished);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<StoryTray> trays,  int trayIndex,  int storyIndex,  Set<String> viewedIds,  bool finished)?  $default,) {final _that = this;
switch (_that) {
case _StoryViewerState() when $default != null:
return $default(_that.trays,_that.trayIndex,_that.storyIndex,_that.viewedIds,_that.finished);case _:
  return null;

}
}

}

/// @nodoc


class _StoryViewerState implements StoryViewerState {
  const _StoryViewerState({required final  List<StoryTray> trays, this.trayIndex = 0, this.storyIndex = 0, final  Set<String> viewedIds = const <String>{}, this.finished = false}): _trays = trays,_viewedIds = viewedIds;
  

 final  List<StoryTray> _trays;
@override List<StoryTray> get trays {
  if (_trays is EqualUnmodifiableListView) return _trays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_trays);
}

@override@JsonKey() final  int trayIndex;
@override@JsonKey() final  int storyIndex;
 final  Set<String> _viewedIds;
@override@JsonKey() Set<String> get viewedIds {
  if (_viewedIds is EqualUnmodifiableSetView) return _viewedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_viewedIds);
}

@override@JsonKey() final  bool finished;

/// Create a copy of StoryViewerState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StoryViewerStateCopyWith<_StoryViewerState> get copyWith => __$StoryViewerStateCopyWithImpl<_StoryViewerState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StoryViewerState&&const DeepCollectionEquality().equals(other._trays, _trays)&&(identical(other.trayIndex, trayIndex) || other.trayIndex == trayIndex)&&(identical(other.storyIndex, storyIndex) || other.storyIndex == storyIndex)&&const DeepCollectionEquality().equals(other._viewedIds, _viewedIds)&&(identical(other.finished, finished) || other.finished == finished));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_trays),trayIndex,storyIndex,const DeepCollectionEquality().hash(_viewedIds),finished);

@override
String toString() {
  return 'StoryViewerState(trays: $trays, trayIndex: $trayIndex, storyIndex: $storyIndex, viewedIds: $viewedIds, finished: $finished)';
}


}

/// @nodoc
abstract mixin class _$StoryViewerStateCopyWith<$Res> implements $StoryViewerStateCopyWith<$Res> {
  factory _$StoryViewerStateCopyWith(_StoryViewerState value, $Res Function(_StoryViewerState) _then) = __$StoryViewerStateCopyWithImpl;
@override @useResult
$Res call({
 List<StoryTray> trays, int trayIndex, int storyIndex, Set<String> viewedIds, bool finished
});




}
/// @nodoc
class __$StoryViewerStateCopyWithImpl<$Res>
    implements _$StoryViewerStateCopyWith<$Res> {
  __$StoryViewerStateCopyWithImpl(this._self, this._then);

  final _StoryViewerState _self;
  final $Res Function(_StoryViewerState) _then;

/// Create a copy of StoryViewerState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? trays = null,Object? trayIndex = null,Object? storyIndex = null,Object? viewedIds = null,Object? finished = null,}) {
  return _then(_StoryViewerState(
trays: null == trays ? _self._trays : trays // ignore: cast_nullable_to_non_nullable
as List<StoryTray>,trayIndex: null == trayIndex ? _self.trayIndex : trayIndex // ignore: cast_nullable_to_non_nullable
as int,storyIndex: null == storyIndex ? _self.storyIndex : storyIndex // ignore: cast_nullable_to_non_nullable
as int,viewedIds: null == viewedIds ? _self._viewedIds : viewedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,finished: null == finished ? _self.finished : finished // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
