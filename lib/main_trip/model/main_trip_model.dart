import 'package:json_annotation/json_annotation.dart';

part 'main_trip_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MainTripModel {
  final int tripId;
  final String title;
  final DateTime staredAt;
  final String travelStatus;
  final int day;
  final List<MainTripPlaceModel> places;

  MainTripModel({
    required this.tripId,
    required this.title,
    required this.staredAt,
    required this.travelStatus,
    required this.day,
    required this.places,
  });

  factory MainTripModel.fromJson(Map<String, dynamic> json) => _$MainTripModelFromJson(json);
  Map<String, dynamic> toJson() => _$MainTripModelToJson(this);
}

@JsonSerializable()
class MainTripPlaceModel {
  final String id;
  final String name;
  final String placeType;
  final bool isVisited;

  MainTripPlaceModel({
    required this.id,
    required this.name,
    required this.placeType,
    required this.isVisited,
  });

  factory MainTripPlaceModel.fromJson(Map<String, dynamic> json) => _$MainTripPlaceModelFromJson(json);
  Map<String, dynamic> toJson() => _$MainTripPlaceModelToJson(this);
}
