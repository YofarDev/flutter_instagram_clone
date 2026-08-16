// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'counter_settings_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CounterSettingsDto {

 int get stepSize; int? get minValue; int? get maxValue;
/// Create a copy of CounterSettingsDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CounterSettingsDtoCopyWith<CounterSettingsDto> get copyWith => _$CounterSettingsDtoCopyWithImpl<CounterSettingsDto>(this as CounterSettingsDto, _$identity);

  /// Serializes this CounterSettingsDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CounterSettingsDto&&(identical(other.stepSize, stepSize) || other.stepSize == stepSize)&&(identical(other.minValue, minValue) || other.minValue == minValue)&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stepSize,minValue,maxValue);

@override
String toString() {
  return 'CounterSettingsDto(stepSize: $stepSize, minValue: $minValue, maxValue: $maxValue)';
}


}

/// @nodoc
abstract mixin class $CounterSettingsDtoCopyWith<$Res>  {
  factory $CounterSettingsDtoCopyWith(CounterSettingsDto value, $Res Function(CounterSettingsDto) _then) = _$CounterSettingsDtoCopyWithImpl;
@useResult
$Res call({
 int stepSize, int? minValue, int? maxValue
});




}
/// @nodoc
class _$CounterSettingsDtoCopyWithImpl<$Res>
    implements $CounterSettingsDtoCopyWith<$Res> {
  _$CounterSettingsDtoCopyWithImpl(this._self, this._then);

  final CounterSettingsDto _self;
  final $Res Function(CounterSettingsDto) _then;

/// Create a copy of CounterSettingsDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? stepSize = null,Object? minValue = freezed,Object? maxValue = freezed,}) {
  return _then(_self.copyWith(
stepSize: null == stepSize ? _self.stepSize : stepSize // ignore: cast_nullable_to_non_nullable
as int,minValue: freezed == minValue ? _self.minValue : minValue // ignore: cast_nullable_to_non_nullable
as int?,maxValue: freezed == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CounterSettingsDto].
extension CounterSettingsDtoPatterns on CounterSettingsDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CounterSettingsDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CounterSettingsDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CounterSettingsDto value)  $default,){
final _that = this;
switch (_that) {
case _CounterSettingsDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CounterSettingsDto value)?  $default,){
final _that = this;
switch (_that) {
case _CounterSettingsDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int stepSize,  int? minValue,  int? maxValue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CounterSettingsDto() when $default != null:
return $default(_that.stepSize,_that.minValue,_that.maxValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int stepSize,  int? minValue,  int? maxValue)  $default,) {final _that = this;
switch (_that) {
case _CounterSettingsDto():
return $default(_that.stepSize,_that.minValue,_that.maxValue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int stepSize,  int? minValue,  int? maxValue)?  $default,) {final _that = this;
switch (_that) {
case _CounterSettingsDto() when $default != null:
return $default(_that.stepSize,_that.minValue,_that.maxValue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CounterSettingsDto extends CounterSettingsDto {
  const _CounterSettingsDto({this.stepSize = 1, this.minValue, this.maxValue}): super._();
  factory _CounterSettingsDto.fromJson(Map<String, dynamic> json) => _$CounterSettingsDtoFromJson(json);

@override@JsonKey() final  int stepSize;
@override final  int? minValue;
@override final  int? maxValue;

/// Create a copy of CounterSettingsDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CounterSettingsDtoCopyWith<_CounterSettingsDto> get copyWith => __$CounterSettingsDtoCopyWithImpl<_CounterSettingsDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CounterSettingsDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CounterSettingsDto&&(identical(other.stepSize, stepSize) || other.stepSize == stepSize)&&(identical(other.minValue, minValue) || other.minValue == minValue)&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,stepSize,minValue,maxValue);

@override
String toString() {
  return 'CounterSettingsDto(stepSize: $stepSize, minValue: $minValue, maxValue: $maxValue)';
}


}

/// @nodoc
abstract mixin class _$CounterSettingsDtoCopyWith<$Res> implements $CounterSettingsDtoCopyWith<$Res> {
  factory _$CounterSettingsDtoCopyWith(_CounterSettingsDto value, $Res Function(_CounterSettingsDto) _then) = __$CounterSettingsDtoCopyWithImpl;
@override @useResult
$Res call({
 int stepSize, int? minValue, int? maxValue
});




}
/// @nodoc
class __$CounterSettingsDtoCopyWithImpl<$Res>
    implements _$CounterSettingsDtoCopyWith<$Res> {
  __$CounterSettingsDtoCopyWithImpl(this._self, this._then);

  final _CounterSettingsDto _self;
  final $Res Function(_CounterSettingsDto) _then;

/// Create a copy of CounterSettingsDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? stepSize = null,Object? minValue = freezed,Object? maxValue = freezed,}) {
  return _then(_CounterSettingsDto(
stepSize: null == stepSize ? _self.stepSize : stepSize // ignore: cast_nullable_to_non_nullable
as int,minValue: freezed == minValue ? _self.minValue : minValue // ignore: cast_nullable_to_non_nullable
as int?,maxValue: freezed == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
