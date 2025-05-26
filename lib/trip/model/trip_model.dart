import 'package:json_annotation/json_annotation.dart';

part 'trip_model.g.dart';

enum TripStatus { SETTING, PLANNED, IN_PROGRESS, COMPLETED }

class TripBaseModel {}

//여행 없음
class NoTripModel extends TripBaseModel {}

//여행 생성중
class SettingTripModel extends TripModel {
  SettingTripModel({required TripModel trip})
    : super(
        tripId: trip.tripId,
        title: trip.title,
        city: trip.city,
        leaderId: trip.leaderId,
        startedAt: trip.startedAt,
        endedAt: trip.endedAt,
        status: trip.status,
        members: trip.members,
      );
}

//여행 생성 완료 (여행 시작 전)
class PlannedTripModel extends TripModel {
  PlannedTripModel({required TripModel trip})
    : super(
        tripId: trip.tripId,
        title: trip.title,
        city: trip.city,
        leaderId: trip.leaderId,
        startedAt: trip.startedAt,
        endedAt: trip.endedAt,
        status: trip.status,
        members: trip.members,
      );
}

//여행 생성 완료 (여행 진행 중)
class InProgressTripModel extends TripModel {
  InProgressTripModel({required TripModel trip})
    : super(
        tripId: trip.tripId,
        title: trip.title,
        city: trip.city,
        leaderId: trip.leaderId,
        startedAt: trip.startedAt,
        endedAt: trip.endedAt,
        status: trip.status,
        members: trip.members,
      );
}

// 끝난 여행
class CompletedTripModel extends TripModel {
  CompletedTripModel({required TripModel trip})
    : super(
        tripId: trip.tripId,
        title: trip.title,
        city: trip.city,
        leaderId: trip.leaderId,
        startedAt: trip.startedAt,
        endedAt: trip.endedAt,
        status: trip.status,
        members: trip.members,
      );
}

//여행 정보
@JsonSerializable()
class TripModel extends TripBaseModel {
  final int tripId;
  final String title;
  final String? city;
  final int leaderId;
  final String? startedAt;
  final String? endedAt;
  final TripStatus status;
  final List<TripMember> members;

  TripModel({
    required this.tripId,
    required this.title,
    required this.city,
    required this.leaderId,
    required this.startedAt,
    required this.endedAt,
    required this.status,
    required this.members,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) =>
      _$TripModelFromJson(json);

  Map<String, dynamic> toJson() => _$TripModelToJson(this);
}

//여행 멤버 클래스
@JsonSerializable()
class TripMember {
  final int userId;
  final String nickname;
  final String? imageUrl;

  TripMember({
    required this.userId,
    required this.nickname,
    required this.imageUrl,
  });

  factory TripMember.fromJson(Map<String, dynamic> json) =>
      _$TripMemberFromJson(json);

  Map<String, dynamic> toJson() => _$TripMemberToJson(this);
}
