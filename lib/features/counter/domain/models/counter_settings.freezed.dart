// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'counter_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CounterSettings {

/// The maximum value the counter can reach.
/// Use `null` for no limit.
 int? get maxValue;/// The minimum value the counter can reach.
/// Use `null` for no limit.
 int? get minValue;/// The step size for increment/decrement operations.
/// Default is 1.
 int get stepSize;/// Whether to show milestone notifications (e.g., every 10 counts).
 bool get showMilestones;/// The interval for milestone notifications.
/// Only used if showMilestones is true.
 int get milestoneInterval;
/// Create a copy of CounterSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CounterSettingsCopyWith<CounterSettings> get copyWith => _$CounterSettingsCopyWithImpl<CounterSettings>(this as CounterSettings, _$identity);

  /// Serializes this CounterSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CounterSettings&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue)&&(identical(other.minValue, minValue) || other.minValue == minValue)&&(identical(other.stepSize, stepSize) || other.stepSize == stepSize)&&(identical(other.showMilestones, showMilestones) || other.showMilestones == showMilestones)&&(identical(other.milestoneInterval, milestoneInterval) || other.milestoneInterval == milestoneInterval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxValue,minValue,stepSize,showMilestones,milestoneInterval);

@override
String toString() {
  return 'CounterSettings(maxValue: $maxValue, minValue: $minValue, stepSize: $stepSize, showMilestones: $showMilestones, milestoneInterval: $milestoneInterval)';
}


}

/// @nodoc
abstract mixin class $CounterSettingsCopyWith<$Res>  {
  factory $CounterSettingsCopyWith(CounterSettings value, $Res Function(CounterSettings) _then) = _$CounterSettingsCopyWithImpl;
@useResult
$Res call({
 int? maxValue, int? minValue, int stepSize, bool showMilestones, int milestoneInterval
});




}
/// @nodoc
class _$CounterSettingsCopyWithImpl<$Res>
    implements $CounterSettingsCopyWith<$Res> {
  _$CounterSettingsCopyWithImpl(this._self, this._then);

  final CounterSettings _self;
  final $Res Function(CounterSettings) _then;

/// Create a copy of CounterSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? maxValue = freezed,Object? minValue = freezed,Object? stepSize = null,Object? showMilestones = null,Object? milestoneInterval = null,}) {
  return _then(_self.copyWith(
maxValue: freezed == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as int?,minValue: freezed == minValue ? _self.minValue : minValue // ignore: cast_nullable_to_non_nullable
as int?,stepSize: null == stepSize ? _self.stepSize : stepSize // ignore: cast_nullable_to_non_nullable
as int,showMilestones: null == showMilestones ? _self.showMilestones : showMilestones // ignore: cast_nullable_to_non_nullable
as bool,milestoneInterval: null == milestoneInterval ? _self.milestoneInterval : milestoneInterval // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CounterSettings].
extension CounterSettingsPatterns on CounterSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CounterSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CounterSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CounterSettings value)  $default,){
final _that = this;
switch (_that) {
case _CounterSettings():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CounterSettings value)?  $default,){
final _that = this;
switch (_that) {
case _CounterSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? maxValue,  int? minValue,  int stepSize,  bool showMilestones,  int milestoneInterval)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CounterSettings() when $default != null:
return $default(_that.maxValue,_that.minValue,_that.stepSize,_that.showMilestones,_that.milestoneInterval);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? maxValue,  int? minValue,  int stepSize,  bool showMilestones,  int milestoneInterval)  $default,) {final _that = this;
switch (_that) {
case _CounterSettings():
return $default(_that.maxValue,_that.minValue,_that.stepSize,_that.showMilestones,_that.milestoneInterval);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? maxValue,  int? minValue,  int stepSize,  bool showMilestones,  int milestoneInterval)?  $default,) {final _that = this;
switch (_that) {
case _CounterSettings() when $default != null:
return $default(_that.maxValue,_that.minValue,_that.stepSize,_that.showMilestones,_that.milestoneInterval);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CounterSettings extends CounterSettings {
  const _CounterSettings({this.maxValue, this.minValue, this.stepSize = 1, this.showMilestones = false, this.milestoneInterval = 10}): super._();
  factory _CounterSettings.fromJson(Map<String, dynamic> json) => _$CounterSettingsFromJson(json);

/// The maximum value the counter can reach.
/// Use `null` for no limit.
@override final  int? maxValue;
/// The minimum value the counter can reach.
/// Use `null` for no limit.
@override final  int? minValue;
/// The step size for increment/decrement operations.
/// Default is 1.
@override@JsonKey() final  int stepSize;
/// Whether to show milestone notifications (e.g., every 10 counts).
@override@JsonKey() final  bool showMilestones;
/// The interval for milestone notifications.
/// Only used if showMilestones is true.
@override@JsonKey() final  int milestoneInterval;

/// Create a copy of CounterSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CounterSettingsCopyWith<_CounterSettings> get copyWith => __$CounterSettingsCopyWithImpl<_CounterSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CounterSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CounterSettings&&(identical(other.maxValue, maxValue) || other.maxValue == maxValue)&&(identical(other.minValue, minValue) || other.minValue == minValue)&&(identical(other.stepSize, stepSize) || other.stepSize == stepSize)&&(identical(other.showMilestones, showMilestones) || other.showMilestones == showMilestones)&&(identical(other.milestoneInterval, milestoneInterval) || other.milestoneInterval == milestoneInterval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,maxValue,minValue,stepSize,showMilestones,milestoneInterval);

@override
String toString() {
  return 'CounterSettings(maxValue: $maxValue, minValue: $minValue, stepSize: $stepSize, showMilestones: $showMilestones, milestoneInterval: $milestoneInterval)';
}


}

/// @nodoc
abstract mixin class _$CounterSettingsCopyWith<$Res> implements $CounterSettingsCopyWith<$Res> {
  factory _$CounterSettingsCopyWith(_CounterSettings value, $Res Function(_CounterSettings) _then) = __$CounterSettingsCopyWithImpl;
@override @useResult
$Res call({
 int? maxValue, int? minValue, int stepSize, bool showMilestones, int milestoneInterval
});




}
/// @nodoc
class __$CounterSettingsCopyWithImpl<$Res>
    implements _$CounterSettingsCopyWith<$Res> {
  __$CounterSettingsCopyWithImpl(this._self, this._then);

  final _CounterSettings _self;
  final $Res Function(_CounterSettings) _then;

/// Create a copy of CounterSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? maxValue = freezed,Object? minValue = freezed,Object? stepSize = null,Object? showMilestones = null,Object? milestoneInterval = null,}) {
  return _then(_CounterSettings(
maxValue: freezed == maxValue ? _self.maxValue : maxValue // ignore: cast_nullable_to_non_nullable
as int?,minValue: freezed == minValue ? _self.minValue : minValue // ignore: cast_nullable_to_non_nullable
as int?,stepSize: null == stepSize ? _self.stepSize : stepSize // ignore: cast_nullable_to_non_nullable
as int,showMilestones: null == showMilestones ? _self.showMilestones : showMilestones // ignore: cast_nullable_to_non_nullable
as bool,milestoneInterval: null == milestoneInterval ? _self.milestoneInterval : milestoneInterval // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
