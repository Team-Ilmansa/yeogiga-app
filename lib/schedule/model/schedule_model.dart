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

  //TODO: optimistic UI 적용을 위한 copyWith
  PendingDayScheduleModel copyWith({
    int? day,
    List<PendingPlaceModel>? places,
  }) {
    return PendingDayScheduleModel(
      day: day ?? this.day,
      places: places ?? this.places,
    );
  }
}

@JsonSerializable(explicitToJson: true)
class PendingScheduleModel {
  final int tripId;
  final List<PendingDayScheduleModel> schedules;

  PendingScheduleModel({required this.tripId, required this.schedules});

  factory PendingScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$PendingScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$PendingScheduleModelToJson(this);

  PendingScheduleModel copyWith({
    int? tripId,
    List<PendingDayScheduleModel>? schedules,
  }) {
    return PendingScheduleModel(
      tripId: tripId ?? this.tripId,
      schedules: schedules ?? this.schedules,
    );
  }
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

  factory ConfirmedPlaceModel.fromJson(Map<String, dynamic> json) {
    print('[ConfirmedPlaceModel.fromJson] json: $json');
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
      return null;
    }

    return ConfirmedPlaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      placeType: json['placeType'] as String,
      isVisited: json['isVisited'] as bool,
    );
  }

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

  ConfirmedDayScheduleModel copyWith({
    String? id,
    int? day,
    List<ConfirmedPlaceModel>? places,
  }) {
    return ConfirmedDayScheduleModel(
      id: id ?? this.id,
      day: day ?? this.day,
      places: places ?? this.places,
    );
  }
}

//확정 이후 각각 여행별 day스케줄들
@JsonSerializable(explicitToJson: true)
class ConfirmedScheduleModel {
  final int tripId;
  final List<ConfirmedDayScheduleModel> schedules;

  ConfirmedScheduleModel({required this.tripId, required this.schedules});

  factory ConfirmedScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$ConfirmedScheduleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConfirmedScheduleModelToJson(this);

  ConfirmedScheduleModel copyWith({
    int? tripId,
    List<ConfirmedDayScheduleModel>? schedules,
  }) {
    return ConfirmedScheduleModel(
      tripId: tripId ?? this.tripId,
      schedules: schedules ?? this.schedules,
    );
  }
}

//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

// 여행별 data 묶음
@JsonSerializable(explicitToJson: true)
class CompletedTripDayPlaceListModel {
  final int tripId;
  final List<CompletedTripDayPlaceModel> data;

  CompletedTripDayPlaceListModel({required this.tripId, required this.data});

  factory CompletedTripDayPlaceListModel.fromJson(Map<String, dynamic> json) =>
      _$CompletedTripDayPlaceListModelFromJson(json);
  Map<String, dynamic> toJson() => _$CompletedTripDayPlaceListModelToJson(this);
}

// (일차별 묶음) 목적지 묶음 및 매칭 안된 사진들
@JsonSerializable(explicitToJson: true)
class CompletedTripDayPlaceModel {
  final String id;
  final int day;
  final List<CompletedTripPlaceModel> places;
  final CompletedTripImageModel? unmatchedImage;

  CompletedTripDayPlaceModel({
    required this.id,
    required this.day,
    required this.places,
    required this.unmatchedImage,
  });

  factory CompletedTripDayPlaceModel.fromJson(Map<String, dynamic> json) =>
      _$CompletedTripDayPlaceModelFromJson(json);
  Map<String, dynamic> toJson() => _$CompletedTripDayPlaceModelToJson(this);
}

// 목적지
@JsonSerializable(explicitToJson: true)
class CompletedTripPlaceModel {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String type;
  final CompletedTripImageModel? image;

  CompletedTripPlaceModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.image,
  });

  factory CompletedTripPlaceModel.fromJson(Map<String, dynamic> json) =>
      _$CompletedTripPlaceModelFromJson(json);
  Map<String, dynamic> toJson() => _$CompletedTripPlaceModelToJson(this);
}

// 목적지에 매칭된 이미지
@JsonSerializable()
class CompletedTripImageModel {
  final String id;
  final String url;
  final double? latitude;
  final double? longitude;
  final DateTime? date;

  CompletedTripImageModel({
    required this.id,
    required this.url,
    required this.latitude,
    required this.longitude,
    required this.date,
  });

  factory CompletedTripImageModel.fromJson(Map<String, dynamic> json) =>
      _$CompletedTripImageModelFromJson(json);
  Map<String, dynamic> toJson() => _$CompletedTripImageModelToJson(this);
}
