import 'package:json_annotation/json_annotation.dart';

part 'notice_model.g.dart';

@JsonSerializable()
class NoticeModel {
  final int id;
  final String title;
  final String description;
  final bool completed;
  final DateTime createdAt;
  final int authorId;
  final String nickname;
  final String? imageUrl;

  NoticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.completed,
    required this.createdAt,
    required this.authorId,
    required this.nickname,
    this.imageUrl,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) =>
      _$NoticeModelFromJson(json);

  Map<String, dynamic> toJson() => _$NoticeModelToJson(this);
}
