// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_list_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripListResponseModel _$TripListResponseModelFromJson(
  Map<String, dynamic> json,
) => TripListResponseModel(
  code: (json['code'] as num).toInt(),
  message: json['message'] as String,
  data:
      (json['data'] as List<dynamic>)
          .map((e) => TripModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$TripListResponseModelToJson(
  TripListResponseModel instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};
