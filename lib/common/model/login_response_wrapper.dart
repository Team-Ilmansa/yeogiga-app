import 'package:json_annotation/json_annotation.dart';
import 'login_response.dart';

part 'login_response_wrapper.g.dart';

@JsonSerializable()
class LoginResponseWrapper {
  final dynamic code; // int or String
  final String message;
  final dynamic data; // LoginResponse or UserDeletedData

  LoginResponseWrapper({
    required this.code,
    required this.message,
    this.data,
  });

  factory LoginResponseWrapper.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseWrapperFromJson(json);
}
