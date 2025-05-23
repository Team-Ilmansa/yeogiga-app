// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_wrapper.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponseWrapper _$LoginResponseWrapperFromJson(
  Map<String, dynamic> json,
) => LoginResponseWrapper(
  code: json['code'],
  message: json['message'] as String,
  data:
      json['data'] == null
          ? null
          : LoginResponse.fromJson(json['data'] as Map<String, dynamic>),
);

Map<String, dynamic> _$LoginResponseWrapperToJson(
  LoginResponseWrapper instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};
