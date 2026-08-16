// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CounterSettingsDto _$CounterSettingsDtoFromJson(Map<String, dynamic> json) =>
    _CounterSettingsDto(
      stepSize: (json['stepSize'] as num?)?.toInt() ?? 1,
      minValue: (json['minValue'] as num?)?.toInt(),
      maxValue: (json['maxValue'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CounterSettingsDtoToJson(_CounterSettingsDto instance) =>
    <String, dynamic>{
      'stepSize': instance.stepSize,
      'minValue': instance.minValue,
      'maxValue': instance.maxValue,
    };
