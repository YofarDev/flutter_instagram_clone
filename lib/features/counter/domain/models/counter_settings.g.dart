// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CounterSettings _$CounterSettingsFromJson(Map<String, dynamic> json) =>
    _CounterSettings(
      maxValue: (json['maxValue'] as num?)?.toInt(),
      minValue: (json['minValue'] as num?)?.toInt(),
      stepSize: (json['stepSize'] as num?)?.toInt() ?? 1,
      showMilestones: json['showMilestones'] as bool? ?? false,
      milestoneInterval: (json['milestoneInterval'] as num?)?.toInt() ?? 10,
    );

Map<String, dynamic> _$CounterSettingsToJson(_CounterSettings instance) =>
    <String, dynamic>{
      'maxValue': instance.maxValue,
      'minValue': instance.minValue,
      'stepSize': instance.stepSize,
      'showMilestones': instance.showMilestones,
      'milestoneInterval': instance.milestoneInterval,
    };
