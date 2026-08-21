// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'conversation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Conversation {

 String get id; AppUser get otherUser; String get lastMessageText; String? get lastMessageSenderId; DateTime? get lastMessageAt;/// 'text' or 'image' — image previews render a localized "Photo".
 String get lastMessageType;/// Messages from the other user I haven't read yet (denormalized).
 int get unreadCount;
/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConversationCopyWith<Conversation> get copyWith => _$ConversationCopyWithImpl<Conversation>(this as Conversation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Conversation&&(identical(other.id, id) || other.id == id)&&(identical(other.otherUser, otherUser) || other.otherUser == otherUser)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageType, lastMessageType) || other.lastMessageType == lastMessageType)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,otherUser,lastMessageText,lastMessageSenderId,lastMessageAt,lastMessageType,unreadCount);

@override
String toString() {
  return 'Conversation(id: $id, otherUser: $otherUser, lastMessageText: $lastMessageText, lastMessageSenderId: $lastMessageSenderId, lastMessageAt: $lastMessageAt, lastMessageType: $lastMessageType, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class $ConversationCopyWith<$Res>  {
  factory $ConversationCopyWith(Conversation value, $Res Function(Conversation) _then) = _$ConversationCopyWithImpl;
@useResult
$Res call({
 String id, AppUser otherUser, String lastMessageText, String? lastMessageSenderId, DateTime? lastMessageAt, String lastMessageType, int unreadCount
});


$AppUserCopyWith<$Res> get otherUser;

}
/// @nodoc
class _$ConversationCopyWithImpl<$Res>
    implements $ConversationCopyWith<$Res> {
  _$ConversationCopyWithImpl(this._self, this._then);

  final Conversation _self;
  final $Res Function(Conversation) _then;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? otherUser = null,Object? lastMessageText = null,Object? lastMessageSenderId = freezed,Object? lastMessageAt = freezed,Object? lastMessageType = null,Object? unreadCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,otherUser: null == otherUser ? _self.otherUser : otherUser // ignore: cast_nullable_to_non_nullable
as AppUser,lastMessageText: null == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessageType: null == lastMessageType ? _self.lastMessageType : lastMessageType // ignore: cast_nullable_to_non_nullable
as String,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res> get otherUser {
  
  return $AppUserCopyWith<$Res>(_self.otherUser, (value) {
    return _then(_self.copyWith(otherUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [Conversation].
extension ConversationPatterns on Conversation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Conversation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Conversation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Conversation value)  $default,){
final _that = this;
switch (_that) {
case _Conversation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Conversation value)?  $default,){
final _that = this;
switch (_that) {
case _Conversation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  AppUser otherUser,  String lastMessageText,  String? lastMessageSenderId,  DateTime? lastMessageAt,  String lastMessageType,  int unreadCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that.id,_that.otherUser,_that.lastMessageText,_that.lastMessageSenderId,_that.lastMessageAt,_that.lastMessageType,_that.unreadCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  AppUser otherUser,  String lastMessageText,  String? lastMessageSenderId,  DateTime? lastMessageAt,  String lastMessageType,  int unreadCount)  $default,) {final _that = this;
switch (_that) {
case _Conversation():
return $default(_that.id,_that.otherUser,_that.lastMessageText,_that.lastMessageSenderId,_that.lastMessageAt,_that.lastMessageType,_that.unreadCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  AppUser otherUser,  String lastMessageText,  String? lastMessageSenderId,  DateTime? lastMessageAt,  String lastMessageType,  int unreadCount)?  $default,) {final _that = this;
switch (_that) {
case _Conversation() when $default != null:
return $default(_that.id,_that.otherUser,_that.lastMessageText,_that.lastMessageSenderId,_that.lastMessageAt,_that.lastMessageType,_that.unreadCount);case _:
  return null;

}
}

}

/// @nodoc


class _Conversation extends Conversation {
  const _Conversation({required this.id, required this.otherUser, this.lastMessageText = '', this.lastMessageSenderId, this.lastMessageAt, this.lastMessageType = 'text', this.unreadCount = 0}): super._();
  

@override final  String id;
@override final  AppUser otherUser;
@override@JsonKey() final  String lastMessageText;
@override final  String? lastMessageSenderId;
@override final  DateTime? lastMessageAt;
/// 'text' or 'image' — image previews render a localized "Photo".
@override@JsonKey() final  String lastMessageType;
/// Messages from the other user I haven't read yet (denormalized).
@override@JsonKey() final  int unreadCount;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ConversationCopyWith<_Conversation> get copyWith => __$ConversationCopyWithImpl<_Conversation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Conversation&&(identical(other.id, id) || other.id == id)&&(identical(other.otherUser, otherUser) || other.otherUser == otherUser)&&(identical(other.lastMessageText, lastMessageText) || other.lastMessageText == lastMessageText)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessageType, lastMessageType) || other.lastMessageType == lastMessageType)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount));
}


@override
int get hashCode => Object.hash(runtimeType,id,otherUser,lastMessageText,lastMessageSenderId,lastMessageAt,lastMessageType,unreadCount);

@override
String toString() {
  return 'Conversation(id: $id, otherUser: $otherUser, lastMessageText: $lastMessageText, lastMessageSenderId: $lastMessageSenderId, lastMessageAt: $lastMessageAt, lastMessageType: $lastMessageType, unreadCount: $unreadCount)';
}


}

/// @nodoc
abstract mixin class _$ConversationCopyWith<$Res> implements $ConversationCopyWith<$Res> {
  factory _$ConversationCopyWith(_Conversation value, $Res Function(_Conversation) _then) = __$ConversationCopyWithImpl;
@override @useResult
$Res call({
 String id, AppUser otherUser, String lastMessageText, String? lastMessageSenderId, DateTime? lastMessageAt, String lastMessageType, int unreadCount
});


@override $AppUserCopyWith<$Res> get otherUser;

}
/// @nodoc
class __$ConversationCopyWithImpl<$Res>
    implements _$ConversationCopyWith<$Res> {
  __$ConversationCopyWithImpl(this._self, this._then);

  final _Conversation _self;
  final $Res Function(_Conversation) _then;

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? otherUser = null,Object? lastMessageText = null,Object? lastMessageSenderId = freezed,Object? lastMessageAt = freezed,Object? lastMessageType = null,Object? unreadCount = null,}) {
  return _then(_Conversation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,otherUser: null == otherUser ? _self.otherUser : otherUser // ignore: cast_nullable_to_non_nullable
as AppUser,lastMessageText: null == lastMessageText ? _self.lastMessageText : lastMessageText // ignore: cast_nullable_to_non_nullable
as String,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessageType: null == lastMessageType ? _self.lastMessageType : lastMessageType // ignore: cast_nullable_to_non_nullable
as String,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of Conversation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res> get otherUser {
  
  return $AppUserCopyWith<$Res>(_self.otherUser, (value) {
    return _then(_self.copyWith(otherUser: value));
  });
}
}

// dart format on
