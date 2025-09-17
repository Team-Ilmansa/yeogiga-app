// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ping_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PingModel _$PingModelFromJson(Map<String, dynamic> json) => PingModel(
  place: json['place'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  time: DateTime.parse(json['time'] as String),
);

Map<String, dynamic> _$PingModelToJson(PingModel instance) => <String, dynamic>{
  'place': instance.place,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'time': instance.time.toIso8601String(),
};
