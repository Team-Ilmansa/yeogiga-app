import 'package:json_annotation/json_annotation.dart';

part 'schedule_model.g.dart';

@JsonSerializable()
class PendingPlaceModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String placeCategory;

  PendingPlaceModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.placeCategory,
  });

  factory PendingPlaceModel.fromJson(Map<String, dynamic> json) =>
      _$PendingPlaceModelFromJson(json);

  Map<String, dynamic> toJson() => _$PendingPlaceModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PendingDayScheduleModel {
  final int day;
  final List<PendingPlaceModel> places;

  PendingDayScheduleModel({required this.day, required this.places});

  factory PendingDayScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$PendingDayScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$PendingDayScheduleModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PendingScheduleModel {
  final int tripId;
  final List<PendingDayScheduleModel> schedules;

  PendingScheduleModel({required this.tripId, required this.schedules});

  factory PendingScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$PendingScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$PendingScheduleModelToJson(this);
}

//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

//확정 이후 각각 여행 목적지
@JsonSerializable()
class ConfirmedPlaceModel {
  final String id;
  final String name;
  final double? latitude;
  final double? longitude;
  final String placeType;
  final bool isVisited;

  ConfirmedPlaceModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.placeType,
    required this.isVisited,
  });

  factory ConfirmedPlaceModel.fromJson(Map<String, dynamic> json) =>
      _$ConfirmedPlaceModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmedPlaceModelToJson(this);
}

//확정 이후 각각 day스케줄
@JsonSerializable(explicitToJson: true)
class ConfirmedDayScheduleModel {
  final String id;
  final int day;
  final List<ConfirmedPlaceModel> places;

  ConfirmedDayScheduleModel({
    required this.id,
    required this.day,
    required this.places,
  });

  factory ConfirmedDayScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ConfirmedDayScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmedDayScheduleModelToJson(this);
}

//확정 이후 각각 여행별 day스케줄들
@JsonSerializable(explicitToJson: true)
class ConfirmedScheduleModel {
  final String tripId;
  final List<ConfirmedDayScheduleModel> schedules;

  ConfirmedScheduleModel({required this.tripId, required this.schedules});

  factory ConfirmedScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ConfirmedScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmedScheduleModelToJson(this);
}
