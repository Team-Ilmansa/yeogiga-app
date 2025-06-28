import 'package:json_annotation/json_annotation.dart';

part 'register_response.g.dart';

@JsonSerializable()
class RegisterResponse {
  final dynamic code;
  final String? message;
  final Map<String, dynamic>? errors;

  RegisterResponse({required this.code, this.message, this.errors});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseFromJson(json);
}
