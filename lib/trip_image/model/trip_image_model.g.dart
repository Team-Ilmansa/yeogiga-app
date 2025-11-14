// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingDayTripImage _$PendingDayTripImageFromJson(Map<String, dynamic> json) =>
    PendingDayTripImage(
      tripDayPlaceId: json['tripDayPlaceId'] as String,
      day: (json['day'] as num).toInt(),
      pendingImages:
          (json['pendingImages'] as List<dynamic>)
              .map((e) => PendingImage.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$PendingDayTripImageToJson(
  PendingDayTripImage instance,
) => <String, dynamic>{
  'tripDayPlaceId': instance.tripDayPlaceId,
  'day': instance.day,
  'pendingImages': instance.pendingImages,
};

PendingImage _$PendingImageFromJson(Map<String, dynamic> json) =>
    PendingImage(id: json['id'] as String, url: json['url'] as String);

Map<String, dynamic> _$PendingImageToJson(PendingImage instance) =>
    <String, dynamic>{'id': instance.id, 'url': instance.url};

UnMatchedDayTripImage _$UnMatchedDayTripImageFromJson(
  Map<String, dynamic> json,
) => UnMatchedDayTripImage(
  tripDayPlaceId: json['tripDayPlaceId'] as String,
  day: (json['day'] as num).toInt(),
  unmatchedImages:
      (json['unmatchedImages'] as List<dynamic>)
          .map((e) => UnMatchedImage.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$UnMatchedDayTripImageToJson(
  UnMatchedDayTripImage instance,
) => <String, dynamic>{
  'tripDayPlaceId': instance.tripDayPlaceId,
  'day': instance.day,
  'unmatchedImages': instance.unmatchedImages,
};

UnMatchedImage _$UnMatchedImageFromJson(Map<String, dynamic> json) =>
    UnMatchedImage(
      id: json['id'] as String,
      url: json['url'] as String,
      favorite: json['favorite'] as bool? ?? false,
    );

Map<String, dynamic> _$UnMatchedImageToJson(UnMatchedImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'favorite': instance.favorite,
    };

MatchedDayTripPlaceImage _$MatchedDayTripPlaceImageFromJson(
  Map<String, dynamic> json,
) => MatchedDayTripPlaceImage(
  tripDayPlaceId: json['tripDayPlaceId'] as String,
  day: (json['day'] as num).toInt(),
  placeImagesList:
      (json['placeImagesList'] as List<dynamic>)
          .map(
            (e) =>
                e == null
                    ? null
                    : MatchedPlaceImage.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
);

Map<String, dynamic> _$MatchedDayTripPlaceImageToJson(
  MatchedDayTripPlaceImage instance,
) => <String, dynamic>{
  'tripDayPlaceId': instance.tripDayPlaceId,
  'day': instance.day,
  'placeImagesList': instance.placeImagesList,
};

MatchedPlaceImage _$MatchedPlaceImageFromJson(Map<String, dynamic> json) =>
    MatchedPlaceImage(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      type: json['type'] as String?,
      placeImages:
          (json['placeImages'] as List<dynamic>)
              .map((e) => MatchedImage.fromJson(e as Map<String, dynamic>))
              .toList(),
    );

Map<String, dynamic> _$MatchedPlaceImageToJson(MatchedPlaceImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'type': instance.type,
      'placeImages': instance.placeImages,
    };

MatchedImage _$MatchedImageFromJson(Map<String, dynamic> json) => MatchedImage(
  id: json['id'] as String,
  url: json['url'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  date: json['date'] == null ? null : DateTime.parse(json['date'] as String),
  favorite: json['favorite'] as bool,
);

Map<String, dynamic> _$MatchedImageToJson(MatchedImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'date': instance.date?.toIso8601String(),
      'favorite': instance.favorite,
    };
