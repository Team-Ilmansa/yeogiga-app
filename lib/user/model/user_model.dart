import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

// 베이스
abstract class UserModelBase {}

// 에러 났을 때
class UserModelError extends UserModelBase {
  final String message;

  UserModelError({required this.message});
}

//로그인 중일 때 쓸거
class UserModelLoading extends UserModelBase {}

// 유저 모델
@JsonSerializable()
class UserModel extends UserModelBase {
  final String username;
  final String nickname;
  final String email;

  UserModel({
    required this.username,
    required this.nickname,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

@JsonSerializable()
class UserResponseModel extends UserModelBase {
  final int code;
  final String message;
  final UserModel? data;

  UserResponseModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory UserResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UserResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserResponseModelToJson(this);
}
