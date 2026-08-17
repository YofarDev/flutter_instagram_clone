// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversations_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConversationsState {

 ConversationsStatus get status; List<Conversation> get conversations; String? get error;
/// Create a copy of ConversationsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationsStateCopyWith<ConversationsState> get copyWith => _$ConversationsStateCopyWithImpl<ConversationsState>(this as ConversationsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConversationsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.conversations, conversations)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(conversations),error);

@override
String toString() {
  return 'ConversationsState(status: $status, conversations: $conversations, error: $error)';
}


}

/// @nodoc
abstract mixin class $ConversationsStateCopyWith<$Res>  {
  factory $ConversationsStateCopyWith(ConversationsState value, $Res Function(ConversationsState) _then) = _$ConversationsStateCopyWithImpl;
@useResult
$Res call({
 ConversationsStatus status, List<Conversation> conversations, String? error
});




}
/// @nodoc
class _$ConversationsStateCopyWithImpl<$Res>
    implements $ConversationsStateCopyWith<$Res> {
  _$ConversationsStateCopyWithImpl(this._self, this._then);

  final ConversationsState _self;
  final $Res Function(ConversationsState) _then;

/// Create a copy of ConversationsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? conversations = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConversationsStatus,conversations: null == conversations ? _self.conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<Conversation>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ConversationsState].
extension ConversationsStatePatterns on ConversationsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ConversationsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ConversationsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ConversationsState value)  $default,){
final _that = this;
switch (_that) {
case _ConversationsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ConversationsState value)?  $default,){
final _that = this;
switch (_that) {
case _ConversationsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ConversationsStatus status,  List<Conversation> conversations,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ConversationsState() when $default != null:
return $default(_that.status,_that.conversations,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ConversationsStatus status,  List<Conversation> conversations,  String? error)  $default,) {final _that = this;
switch (_that) {
case _ConversationsState():
return $default(_that.status,_that.conversations,_that.error);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ConversationsStatus status,  List<Conversation> conversations,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _ConversationsState() when $default != null:
return $default(_that.status,_that.conversations,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _ConversationsState implements ConversationsState {
  const _ConversationsState({this.status = ConversationsStatus.loading, final  List<Conversation> conversations = const <Conversation>[], this.error}): _conversations = conversations;
  

@override@JsonKey() final  ConversationsStatus status;
 final  List<Conversation> _conversations;
@override@JsonKey() List<Conversation> get conversations {
  if (_conversations is EqualUnmodifiableListView) return _conversations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conversations);
}

@override final  String? error;

/// Create a copy of ConversationsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationsStateCopyWith<_ConversationsState> get copyWith => __$ConversationsStateCopyWithImpl<_ConversationsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ConversationsState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._conversations, _conversations)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_conversations),error);

@override
String toString() {
  return 'ConversationsState(status: $status, conversations: $conversations, error: $error)';
}


}

/// @nodoc
abstract mixin class _$ConversationsStateCopyWith<$Res> implements $ConversationsStateCopyWith<$Res> {
  factory _$ConversationsStateCopyWith(_ConversationsState value, $Res Function(_ConversationsState) _then) = __$ConversationsStateCopyWithImpl;
@override @useResult
$Res call({
 ConversationsStatus status, List<Conversation> conversations, String? error
});




}
/// @nodoc
class __$ConversationsStateCopyWithImpl<$Res>
    implements _$ConversationsStateCopyWith<$Res> {
  __$ConversationsStateCopyWithImpl(this._self, this._then);

  final _ConversationsState _self;
  final $Res Function(_ConversationsState) _then;

/// Create a copy of ConversationsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? conversations = null,Object? error = freezed,}) {
  return _then(_ConversationsState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConversationsStatus,conversations: null == conversations ? _self._conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<Conversation>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
