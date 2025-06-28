// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_trip_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetTripResponse _$GetTripResponseFromJson(Map<String, dynamic> json) =>
    GetTripResponse(
      code: json['code'],
      message: json['message'] as String,
      data:
          json['data'] == null
              ? null
              : TripModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GetTripResponseToJson(GetTripResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
