// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  username: json['username'] as String,
  nickname: json['nickname'] as String,
  email: json['email'] as String,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'username': instance.username,
  'nickname': instance.nickname,
  'email': instance.email,
};

UserDeletedData _$UserDeletedDataFromJson(Map<String, dynamic> json) =>
    UserDeletedData(
      userId: (json['userId'] as num).toInt(),
      nickname: json['nickname'] as String,
      imageUrl: json['imageUrl'] as String?,
      deletionExpiration: json['deletionExpiration'] as String,
    );

Map<String, dynamic> _$UserDeletedDataToJson(UserDeletedData instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nickname': instance.nickname,
      'imageUrl': instance.imageUrl,
      'deletionExpiration': instance.deletionExpiration,
    };

UserResponseModel _$UserResponseModelFromJson(Map<String, dynamic> json) =>
    UserResponseModel(
      code: (json['code'] as num).toInt(),
      message: json['message'] as String,
      data:
          json['data'] == null
              ? null
              : UserModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserResponseModelToJson(UserResponseModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'data': instance.data,
    };
