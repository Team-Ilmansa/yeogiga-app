// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main_trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MainTripModel _$MainTripModelFromJson(Map<String, dynamic> json) =>
    MainTripModel(
      tripId: (json['tripId'] as num).toInt(),
      title: json['title'] as String,
      staredAt: DateTime.parse(json['staredAt'] as String),
      travelStatus: json['travelStatus'] as String,
      day: (json['day'] as num).toInt(),
      places:
          (json['places'] as List<dynamic>)
              .map(
                (e) => MainTripPlaceModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$MainTripModelToJson(MainTripModel instance) =>
    <String, dynamic>{
      'tripId': instance.tripId,
      'title': instance.title,
      'staredAt': instance.staredAt.toIso8601String(),
      'travelStatus': instance.travelStatus,
      'day': instance.day,
      'places': instance.places.map((e) => e.toJson()).toList(),
    };

MainTripPlaceModel _$MainTripPlaceModelFromJson(Map<String, dynamic> json) =>
    MainTripPlaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      placeType: json['placeType'] as String,
      isVisited: json['isVisited'] as bool,
    );

Map<String, dynamic> _$MainTripPlaceModelToJson(MainTripPlaceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'placeType': instance.placeType,
      'isVisited': instance.isVisited,
    };
