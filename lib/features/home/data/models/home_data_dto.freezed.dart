// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_data_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeDataDto {

 String get welcomeMessage; String get lastUpdated;
/// Create a copy of HomeDataDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeDataDtoCopyWith<HomeDataDto> get copyWith => _$HomeDataDtoCopyWithImpl<HomeDataDto>(this as HomeDataDto, _$identity);

  /// Serializes this HomeDataDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeDataDto&&(identical(other.welcomeMessage, welcomeMessage) || other.welcomeMessage == welcomeMessage)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,welcomeMessage,lastUpdated);

@override
String toString() {
  return 'HomeDataDto(welcomeMessage: $welcomeMessage, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class $HomeDataDtoCopyWith<$Res>  {
  factory $HomeDataDtoCopyWith(HomeDataDto value, $Res Function(HomeDataDto) _then) = _$HomeDataDtoCopyWithImpl;
@useResult
$Res call({
 String welcomeMessage, String lastUpdated
});




}
/// @nodoc
class _$HomeDataDtoCopyWithImpl<$Res>
    implements $HomeDataDtoCopyWith<$Res> {
  _$HomeDataDtoCopyWithImpl(this._self, this._then);

  final HomeDataDto _self;
  final $Res Function(HomeDataDto) _then;

/// Create a copy of HomeDataDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? welcomeMessage = null,Object? lastUpdated = null,}) {
  return _then(_self.copyWith(
welcomeMessage: null == welcomeMessage ? _self.welcomeMessage : welcomeMessage // ignore: cast_nullable_to_non_nullable
as String,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeDataDto].
extension HomeDataDtoPatterns on HomeDataDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeDataDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeDataDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeDataDto value)  $default,){
final _that = this;
switch (_that) {
case _HomeDataDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeDataDto value)?  $default,){
final _that = this;
switch (_that) {
case _HomeDataDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String welcomeMessage,  String lastUpdated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeDataDto() when $default != null:
return $default(_that.welcomeMessage,_that.lastUpdated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String welcomeMessage,  String lastUpdated)  $default,) {final _that = this;
switch (_that) {
case _HomeDataDto():
return $default(_that.welcomeMessage,_that.lastUpdated);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String welcomeMessage,  String lastUpdated)?  $default,) {final _that = this;
switch (_that) {
case _HomeDataDto() when $default != null:
return $default(_that.welcomeMessage,_that.lastUpdated);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeDataDto extends HomeDataDto {
  const _HomeDataDto({required this.welcomeMessage, required this.lastUpdated}): super._();
  factory _HomeDataDto.fromJson(Map<String, dynamic> json) => _$HomeDataDtoFromJson(json);

@override final  String welcomeMessage;
@override final  String lastUpdated;

/// Create a copy of HomeDataDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeDataDtoCopyWith<_HomeDataDto> get copyWith => __$HomeDataDtoCopyWithImpl<_HomeDataDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeDataDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeDataDto&&(identical(other.welcomeMessage, welcomeMessage) || other.welcomeMessage == welcomeMessage)&&(identical(other.lastUpdated, lastUpdated) || other.lastUpdated == lastUpdated));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,welcomeMessage,lastUpdated);

@override
String toString() {
  return 'HomeDataDto(welcomeMessage: $welcomeMessage, lastUpdated: $lastUpdated)';
}


}

/// @nodoc
abstract mixin class _$HomeDataDtoCopyWith<$Res> implements $HomeDataDtoCopyWith<$Res> {
  factory _$HomeDataDtoCopyWith(_HomeDataDto value, $Res Function(_HomeDataDto) _then) = __$HomeDataDtoCopyWithImpl;
@override @useResult
$Res call({
 String welcomeMessage, String lastUpdated
});




}
/// @nodoc
class __$HomeDataDtoCopyWithImpl<$Res>
    implements _$HomeDataDtoCopyWith<$Res> {
  __$HomeDataDtoCopyWithImpl(this._self, this._then);

  final _HomeDataDto _self;
  final $Res Function(_HomeDataDto) _then;

/// Create a copy of HomeDataDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? welcomeMessage = null,Object? lastUpdated = null,}) {
  return _then(_HomeDataDto(
welcomeMessage: null == welcomeMessage ? _self.welcomeMessage : welcomeMessage // ignore: cast_nullable_to_non_nullable
as String,lastUpdated: null == lastUpdated ? _self.lastUpdated : lastUpdated // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
