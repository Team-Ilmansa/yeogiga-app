import 'package:json_annotation/json_annotation.dart';
import 'package:yeogiga/common/model/response_model.dart';

part 'post_trip_response.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class PostTripResponse<T> {
  final ResponseModel<T?> response;

  PostTripResponse({required this.response});

  // 헬퍼 getter: postTripResponse.data로 바로 접근 가능
  T? get data => response.data;

  factory PostTripResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PostTripResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T? value) toJsonT) =>
      _$PostTripResponseToJson(this, toJsonT);
}

@JsonSerializable()
class PostTripData {
  final int tripId;

  PostTripData({required this.tripId});

  factory PostTripData.fromJson(Map<String, dynamic> json) =>
      _$PostTripDataFromJson(json);
}
