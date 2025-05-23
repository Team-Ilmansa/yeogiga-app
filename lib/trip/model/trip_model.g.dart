// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trip_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TripModel _$TripModelFromJson(Map<String, dynamic> json) => TripModel(
  tripId: (json['tripId'] as num).toInt(),
  title: json['title'] as String,
  city: json['city'] as String?,
  startedAt: json['startedAt'] as String?,
  endedAt: json['endedAt'] as String?,
  status: $enumDecode(_$TripStatusEnumMap, json['status']),
  members:
      (json['members'] as List<dynamic>)
          .map((e) => TripMember.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$TripModelToJson(TripModel instance) => <String, dynamic>{
  'tripId': instance.tripId,
  'title': instance.title,
  'city': instance.city,
  'startedAt': instance.startedAt,
  'endedAt': instance.endedAt,
  'status': _$TripStatusEnumMap[instance.status]!,
  'members': instance.members,
};

const _$TripStatusEnumMap = {
  TripStatus.SETTING: 'SETTING',
  TripStatus.PLANNED: 'PLANNED',
  TripStatus.IN_PROGRESS: 'IN_PROGRESS',
};

TripMember _$TripMemberFromJson(Map<String, dynamic> json) => TripMember(
  userId: (json['userId'] as num).toInt(),
  nickname: json['nickname'] as String,
  imageUrl: json['imageUrl'] as String,
);

Map<String, dynamic> _$TripMemberToJson(TripMember instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'imageUrl': instance.imageUrl,
    };
