// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingPlaceModel _$PendingPlaceModelFromJson(Map<String, dynamic> json) =>
    PendingPlaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      placeCategory: json['placeCategory'] as String,
    );

Map<String, dynamic> _$PendingPlaceModelToJson(PendingPlaceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'placeCategory': instance.placeCategory,
    };

PendingDayScheduleModel _$PendingDayScheduleModelFromJson(
  Map<String, dynamic> json,
) => PendingDayScheduleModel(
  day: (json['day'] as num).toInt(),
  places:
      (json['places'] as List<dynamic>)
          .map((e) => PendingPlaceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$PendingDayScheduleModelToJson(
  PendingDayScheduleModel instance,
) => <String, dynamic>{
  'day': instance.day,
  'places': instance.places.map((e) => e.toJson()).toList(),
};

PendingScheduleModel _$PendingScheduleModelFromJson(
  Map<String, dynamic> json,
) => PendingScheduleModel(
  tripId: (json['tripId'] as num).toInt(),
  schedules:
      (json['schedules'] as List<dynamic>)
          .map(
            (e) => PendingDayScheduleModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$PendingScheduleModelToJson(
  PendingScheduleModel instance,
) => <String, dynamic>{
  'tripId': instance.tripId,
  'schedules': instance.schedules.map((e) => e.toJson()).toList(),
};

ConfirmedPlaceModel _$ConfirmedPlaceModelFromJson(Map<String, dynamic> json) =>
    ConfirmedPlaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      placeType: json['placeType'] as String,
      isVisited: json['isVisited'] as bool,
    );

Map<String, dynamic> _$ConfirmedPlaceModelToJson(
  ConfirmedPlaceModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'placeType': instance.placeType,
  'isVisited': instance.isVisited,
};

ConfirmedDayScheduleModel _$ConfirmedDayScheduleModelFromJson(
  Map<String, dynamic> json,
) => ConfirmedDayScheduleModel(
  id: json['id'] as String,
  day: (json['day'] as num).toInt(),
  places:
      (json['places'] as List<dynamic>)
          .map((e) => ConfirmedPlaceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$ConfirmedDayScheduleModelToJson(
  ConfirmedDayScheduleModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'day': instance.day,
  'places': instance.places.map((e) => e.toJson()).toList(),
};

ConfirmedScheduleModel _$ConfirmedScheduleModelFromJson(
  Map<String, dynamic> json,
) => ConfirmedScheduleModel(
  tripId: (json['tripId'] as num).toInt(),
  schedules:
      (json['schedules'] as List<dynamic>)
          .map(
            (e) =>
                ConfirmedDayScheduleModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$ConfirmedScheduleModelToJson(
  ConfirmedScheduleModel instance,
) => <String, dynamic>{
  'tripId': instance.tripId,
  'schedules': instance.schedules.map((e) => e.toJson()).toList(),
};

CompletedTripDayPlaceListModel _$CompletedTripDayPlaceListModelFromJson(
  Map<String, dynamic> json,
) => CompletedTripDayPlaceListModel(
  tripId: (json['tripId'] as num).toInt(),
  data:
      (json['data'] as List<dynamic>)
          .map(
            (e) =>
                CompletedTripDayPlaceModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$CompletedTripDayPlaceListModelToJson(
  CompletedTripDayPlaceListModel instance,
) => <String, dynamic>{
  'tripId': instance.tripId,
  'data': instance.data.map((e) => e.toJson()).toList(),
};

CompletedTripDayPlaceModel _$CompletedTripDayPlaceModelFromJson(
  Map<String, dynamic> json,
) => CompletedTripDayPlaceModel(
  id: json['id'] as String,
  day: (json['day'] as num).toInt(),
  places:
      (json['places'] as List<dynamic>)
          .map(
            (e) => CompletedTripPlaceModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
  unmatchedImage:
      json['unmatchedImage'] == null
          ? null
          : CompletedTripImageModel.fromJson(
            json['unmatchedImage'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$CompletedTripDayPlaceModelToJson(
  CompletedTripDayPlaceModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'day': instance.day,
  'places': instance.places.map((e) => e.toJson()).toList(),
  'unmatchedImage': instance.unmatchedImage?.toJson(),
};

CompletedTripPlaceModel _$CompletedTripPlaceModelFromJson(
  Map<String, dynamic> json,
) => CompletedTripPlaceModel(
  id: json['id'] as String,
  name: json['name'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  type: json['type'] as String,
  image:
      json['image'] == null
          ? null
          : CompletedTripImageModel.fromJson(
            json['image'] as Map<String, dynamic>,
          ),
);

Map<String, dynamic> _$CompletedTripPlaceModelToJson(
  CompletedTripPlaceModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'type': instance.type,
  'image': instance.image?.toJson(),
};

CompletedTripImageModel _$CompletedTripImageModelFromJson(
  Map<String, dynamic> json,
) => CompletedTripImageModel(
  id: json['id'] as String,
  url: json['url'] as String,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
);

Map<String, dynamic> _$CompletedTripImageModelToJson(
  CompletedTripImageModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'url': instance.url,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'date': instance.date?.toIso8601String(),
};
