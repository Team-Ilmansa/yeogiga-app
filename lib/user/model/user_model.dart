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

//닉네임 반드시 추가해줘야하는 놈
class UserModelGuest extends UserModelBase {}

// 유저 모델
@JsonSerializable()
class UserModel extends UserModelBase {
  final String? username;  // 소셜로그인 시 null 가능
  final String nickname;
  final String? email;     // 소셜로그인 시 null 가능
  final String? imageUrl;

  UserModel({
    this.username,
    required this.nickname,
    this.email,
    this.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

// 탈퇴한 사용자 정보
@JsonSerializable()
class UserDeletedData {
  final int userId;
  final String nickname;
  final String? imageUrl;
  final String deletionExpiration;

  UserDeletedData({
    required this.userId,
    required this.nickname,
    this.imageUrl,
    required this.deletionExpiration,
  });

  factory UserDeletedData.fromJson(Map<String, dynamic> json) =>
      _$UserDeletedDataFromJson(json);

  Map<String, dynamic> toJson() => _$UserDeletedDataToJson(this);
}

// 탈퇴한 사용자 상태
class UserDeleteModel extends UserModelBase {
  final String code;
  final String message;
  final UserDeletedData data;

  UserDeleteModel({
    required this.code,
    required this.message,
    required this.data,
  });
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
