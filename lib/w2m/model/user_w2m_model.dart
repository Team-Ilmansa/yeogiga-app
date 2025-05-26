import 'package:json_annotation/json_annotation.dart';

part 'user_w2m_model.g.dart';

class UserW2mBaseModel {}

class NoUserW2mModel extends UserW2mBaseModel {}

@JsonSerializable()
class UserW2mModel extends UserW2mBaseModel {
  final List<String> availableDates;

  UserW2mModel({required this.availableDates});

  factory UserW2mModel.fromJson(Map<String, dynamic> json) => _$UserW2mModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserW2mModelToJson(this);
}
