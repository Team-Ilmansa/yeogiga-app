import 'package:json_annotation/json_annotation.dart';

part 'ping_model.g.dart';

@JsonSerializable()
class PingModel {
  final String place;
  final double latitude;
  final double longitude;
  final DateTime time;

  PingModel({
    required this.place,
    required this.latitude,
    required this.longitude,
    required this.time,
  });

  factory PingModel.fromJson(Map<String, dynamic> json) =>
      _$PingModelFromJson(json);

  Map<String, dynamic> toJson() => _$PingModelToJson(this);
}
