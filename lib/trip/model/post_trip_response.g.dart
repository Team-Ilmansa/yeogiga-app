// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_trip_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostTripResponse<T> _$PostTripResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PostTripResponse<T>(
  response: ResponseModel<T?>.fromJson(
    json['response'] as Map<String, dynamic>,
    (value) => _$nullableGenericFromJson(value, fromJsonT),
  ),
);

Map<String, dynamic> _$PostTripResponseToJson<T>(
  PostTripResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'response': instance.response.toJson(
    (value) => _$nullableGenericToJson(value, toJsonT),
  ),
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

PostTripData _$PostTripDataFromJson(Map<String, dynamic> json) =>
    PostTripData(tripId: (json['tripId'] as num).toInt());

Map<String, dynamic> _$PostTripDataToJson(PostTripData instance) =>
    <String, dynamic>{'tripId': instance.tripId};
