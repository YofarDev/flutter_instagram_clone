// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_HomeData _$HomeDataFromJson(Map<String, dynamic> json) => _HomeData(
  welcomeMessage: json['welcomeMessage'] as String,
  lastUpdated: DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$HomeDataToJson(_HomeData instance) => <String, dynamic>{
  'welcomeMessage': instance.welcomeMessage,
  'lastUpdated': instance.lastUpdated.toIso8601String(),
};
