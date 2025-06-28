import 'package:json_annotation/json_annotation.dart';
import '../../trip/model/trip_model.dart';

part 'trip_list_response_model.g.dart';

@JsonSerializable()
class TripListResponseModel {
  final int code;
  final String message;
  final List<TripModel> data;

  TripListResponseModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory TripListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TripListResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TripListResponseModelToJson(this);
}
