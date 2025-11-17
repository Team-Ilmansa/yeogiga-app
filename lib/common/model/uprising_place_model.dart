import 'package:json_annotation/json_annotation.dart';

part 'uprising_place_model.g.dart';

@JsonSerializable()
class UprisingPlaceModel {
  final int id;
  final String name;
  final String address;
  final String placeCategory;
  final String url;

  UprisingPlaceModel({
    required this.id,
    required this.name,
    required this.address,
    required this.placeCategory,
    required this.url,
  });

  factory UprisingPlaceModel.fromJson(Map<String, dynamic> json) =>
      _$UprisingPlaceModelFromJson(json);

  Map<String, dynamic> toJson() => _$UprisingPlaceModelToJson(this);
}

@JsonSerializable()
class UprisingPlaceResponse {
  final int code;
  final String message;
  final List<UprisingPlaceModel> data;

  UprisingPlaceResponse({
    required this.code,
    required this.message,
    required this.data,
  });

  factory UprisingPlaceResponse.fromJson(Map<String, dynamic> json) =>
      _$UprisingPlaceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UprisingPlaceResponseToJson(this);
}
