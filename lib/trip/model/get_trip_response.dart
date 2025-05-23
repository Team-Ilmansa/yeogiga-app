import 'package:json_annotation/json_annotation.dart';
import 'package:yeogiga/common/model/response_model.dart';
import 'package:yeogiga/trip/model/trip_model.dart';

part 'get_trip_response.g.dart';

@JsonSerializable()
class GetTripResponse extends ResponseModel<TripModel?> {
  GetTripResponse({
    required super.code,
    required super.message,
    required super.data,
  });

  factory GetTripResponse.fromJson(Map<String, dynamic> json) =>
      _$GetTripResponseFromJson(json);

  // toJson 오버라이드 제거! 필요시 instance.toJson((t) => t?.toJson()) 사용
  TripModel? get tripData => data;
}
