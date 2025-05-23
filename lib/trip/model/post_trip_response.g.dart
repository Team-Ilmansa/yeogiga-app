// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_trip_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostTripResponse _$PostTripResponseFromJson(Map<String, dynamic> json) =>
    PostTripResponse(
      code: json['code'],
      message: json['message'] as String,
      data:
          json['data'] == null
              ? null
              : PostTripData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$PostTripResponseToJson(PostTripResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };

PostTripData _$PostTripDataFromJson(Map<String, dynamic> json) =>
    PostTripData(tripId: (json['tripId'] as num).toInt());

Map<String, dynamic> _$PostTripDataToJson(PostTripData instance) =>
    <String, dynamic>{'tripId': instance.tripId};
