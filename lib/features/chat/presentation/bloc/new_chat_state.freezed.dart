// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'new_chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NewChatState {

 String get query; List<AppUser> get users; List<AppUser> get suggestions; bool get suggestionsLoading; bool get searching; bool get opening; String? get error; Conversation? get opened;
/// Create a copy of NewChatState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewChatStateCopyWith<NewChatState> get copyWith => _$NewChatStateCopyWithImpl<NewChatState>(this as NewChatState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NewChatState&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other.users, users)&&const DeepCollectionEquality().equals(other.suggestions, suggestions)&&(identical(other.suggestionsLoading, suggestionsLoading) || other.suggestionsLoading == suggestionsLoading)&&(identical(other.searching, searching) || other.searching == searching)&&(identical(other.opening, opening) || other.opening == opening)&&(identical(other.error, error) || other.error == error)&&(identical(other.opened, opened) || other.opened == opened));
}


@override
int get hashCode => Object.hash(runtimeType,query,const DeepCollectionEquality().hash(users),const DeepCollectionEquality().hash(suggestions),suggestionsLoading,searching,opening,error,opened);

@override
String toString() {
  return 'NewChatState(query: $query, users: $users, suggestions: $suggestions, suggestionsLoading: $suggestionsLoading, searching: $searching, opening: $opening, error: $error, opened: $opened)';
}


}

/// @nodoc
abstract mixin class $NewChatStateCopyWith<$Res>  {
  factory $NewChatStateCopyWith(NewChatState value, $Res Function(NewChatState) _then) = _$NewChatStateCopyWithImpl;
@useResult
$Res call({
 String query, List<AppUser> users, List<AppUser> suggestions, bool suggestionsLoading, bool searching, bool opening, String? error, Conversation? opened
});


$ConversationCopyWith<$Res>? get opened;

}
/// @nodoc
class _$NewChatStateCopyWithImpl<$Res>
    implements $NewChatStateCopyWith<$Res> {
  _$NewChatStateCopyWithImpl(this._self, this._then);

  final NewChatState _self;
  final $Res Function(NewChatState) _then;

/// Create a copy of NewChatState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? users = null,Object? suggestions = null,Object? suggestionsLoading = null,Object? searching = null,Object? opening = null,Object? error = freezed,Object? opened = freezed,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,users: null == users ? _self.users : users // ignore: cast_nullable_to_non_nullable
as List<AppUser>,suggestions: null == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<AppUser>,suggestionsLoading: null == suggestionsLoading ? _self.suggestionsLoading : suggestionsLoading // ignore: cast_nullable_to_non_nullable
as bool,searching: null == searching ? _self.searching : searching // ignore: cast_nullable_to_non_nullable
as bool,opening: null == opening ? _self.opening : opening // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,opened: freezed == opened ? _self.opened : opened // ignore: cast_nullable_to_non_nullable
as Conversation?,
  ));
}
/// Create a copy of NewChatState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationCopyWith<$Res>? get opened {
    if (_self.opened == null) {
    return null;
  }

  return $ConversationCopyWith<$Res>(_self.opened!, (value) {
    return _then(_self.copyWith(opened: value));
  });
}
}


/// Adds pattern-matching-related methods to [NewChatState].
extension NewChatStatePatterns on NewChatState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NewChatState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NewChatState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NewChatState value)  $default,){
final _that = this;
switch (_that) {
case _NewChatState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NewChatState value)?  $default,){
final _that = this;
switch (_that) {
case _NewChatState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  List<AppUser> users,  List<AppUser> suggestions,  bool suggestionsLoading,  bool searching,  bool opening,  String? error,  Conversation? opened)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NewChatState() when $default != null:
return $default(_that.query,_that.users,_that.suggestions,_that.suggestionsLoading,_that.searching,_that.opening,_that.error,_that.opened);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  List<AppUser> users,  List<AppUser> suggestions,  bool suggestionsLoading,  bool searching,  bool opening,  String? error,  Conversation? opened)  $default,) {final _that = this;
switch (_that) {
case _NewChatState():
return $default(_that.query,_that.users,_that.suggestions,_that.suggestionsLoading,_that.searching,_that.opening,_that.error,_that.opened);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  List<AppUser> users,  List<AppUser> suggestions,  bool suggestionsLoading,  bool searching,  bool opening,  String? error,  Conversation? opened)?  $default,) {final _that = this;
switch (_that) {
case _NewChatState() when $default != null:
return $default(_that.query,_that.users,_that.suggestions,_that.suggestionsLoading,_that.searching,_that.opening,_that.error,_that.opened);case _:
  return null;

}
}

}

/// @nodoc


class _NewChatState implements NewChatState {
  const _NewChatState({this.query = '', final  List<AppUser> users = const <AppUser>[], final  List<AppUser> suggestions = const <AppUser>[], this.suggestionsLoading = true, this.searching = false, this.opening = false, this.error, this.opened}): _users = users,_suggestions = suggestions;
  

@override@JsonKey() final  String query;
 final  List<AppUser> _users;
@override@JsonKey() List<AppUser> get users {
  if (_users is EqualUnmodifiableListView) return _users;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_users);
}

 final  List<AppUser> _suggestions;
@override@JsonKey() List<AppUser> get suggestions {
  if (_suggestions is EqualUnmodifiableListView) return _suggestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_suggestions);
}

@override@JsonKey() final  bool suggestionsLoading;
@override@JsonKey() final  bool searching;
@override@JsonKey() final  bool opening;
@override final  String? error;
@override final  Conversation? opened;

/// Create a copy of NewChatState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewChatStateCopyWith<_NewChatState> get copyWith => __$NewChatStateCopyWithImpl<_NewChatState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NewChatState&&(identical(other.query, query) || other.query == query)&&const DeepCollectionEquality().equals(other._users, _users)&&const DeepCollectionEquality().equals(other._suggestions, _suggestions)&&(identical(other.suggestionsLoading, suggestionsLoading) || other.suggestionsLoading == suggestionsLoading)&&(identical(other.searching, searching) || other.searching == searching)&&(identical(other.opening, opening) || other.opening == opening)&&(identical(other.error, error) || other.error == error)&&(identical(other.opened, opened) || other.opened == opened));
}


@override
int get hashCode => Object.hash(runtimeType,query,const DeepCollectionEquality().hash(_users),const DeepCollectionEquality().hash(_suggestions),suggestionsLoading,searching,opening,error,opened);

@override
String toString() {
  return 'NewChatState(query: $query, users: $users, suggestions: $suggestions, suggestionsLoading: $suggestionsLoading, searching: $searching, opening: $opening, error: $error, opened: $opened)';
}


}

/// @nodoc
abstract mixin class _$NewChatStateCopyWith<$Res> implements $NewChatStateCopyWith<$Res> {
  factory _$NewChatStateCopyWith(_NewChatState value, $Res Function(_NewChatState) _then) = __$NewChatStateCopyWithImpl;
@override @useResult
$Res call({
 String query, List<AppUser> users, List<AppUser> suggestions, bool suggestionsLoading, bool searching, bool opening, String? error, Conversation? opened
});


@override $ConversationCopyWith<$Res>? get opened;

}
/// @nodoc
class __$NewChatStateCopyWithImpl<$Res>
    implements _$NewChatStateCopyWith<$Res> {
  __$NewChatStateCopyWithImpl(this._self, this._then);

  final _NewChatState _self;
  final $Res Function(_NewChatState) _then;

/// Create a copy of NewChatState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? users = null,Object? suggestions = null,Object? suggestionsLoading = null,Object? searching = null,Object? opening = null,Object? error = freezed,Object? opened = freezed,}) {
  return _then(_NewChatState(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,users: null == users ? _self._users : users // ignore: cast_nullable_to_non_nullable
as List<AppUser>,suggestions: null == suggestions ? _self._suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as List<AppUser>,suggestionsLoading: null == suggestionsLoading ? _self.suggestionsLoading : suggestionsLoading // ignore: cast_nullable_to_non_nullable
as bool,searching: null == searching ? _self.searching : searching // ignore: cast_nullable_to_non_nullable
as bool,opening: null == opening ? _self.opening : opening // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,opened: freezed == opened ? _self.opened : opened // ignore: cast_nullable_to_non_nullable
as Conversation?,
  ));
}

/// Create a copy of NewChatState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ConversationCopyWith<$Res>? get opened {
    if (_self.opened == null) {
    return null;
  }

  return $ConversationCopyWith<$Res>(_self.opened!, (value) {
    return _then(_self.copyWith(opened: value));
  });
}
}

// dart format on
