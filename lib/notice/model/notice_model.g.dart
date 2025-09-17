// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoticeModel _$NoticeModelFromJson(Map<String, dynamic> json) => NoticeModel(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  description: json['description'] as String,
  completed: json['completed'] as bool,
  createdAt: DateTime.parse(json['createdAt'] as String),
  authorId: (json['authorId'] as num).toInt(),
  nickname: json['nickname'] as String,
  imageUrl: json['imageUrl'] as String?,
);

Map<String, dynamic> _$NoticeModelToJson(NoticeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'completed': instance.completed,
      'createdAt': instance.createdAt.toIso8601String(),
      'authorId': instance.authorId,
      'nickname': instance.nickname,
      'imageUrl': instance.imageUrl,
    };
