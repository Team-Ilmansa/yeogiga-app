import 'package:json_annotation/json_annotation.dart';
import 'package:yeogiga/common/model/response_model.dart';

part 'post_trip_response.g.dart';

@JsonSerializable()
class PostTripResponse extends ResponseModel<PostTripData?> {
  PostTripResponse({
    required super.code,
    required super.message,
    required super.data,
  });

  factory PostTripResponse.fromJson(Map<String, dynamic> json) =>
      _$PostTripResponseFromJson(json);

  // toJson 오버라이드 제거! 필요시 instance.toJson((t) => t?.toJson()) 사용
  // 헬퍼 getter: postTripResponse.data로 바로 접근 가능
  PostTripData? get tripData => data;
}

@JsonSerializable()
class PostTripData {
  final int tripId;

  PostTripData({required this.tripId});

  factory PostTripData.fromJson(Map<String, dynamic> json) =>
      _$PostTripDataFromJson(json);
}
