import 'package:json_annotation/json_annotation.dart';

part 'response_model.g.dart';

//전체 response 모델
@JsonSerializable(genericArgumentFactories: true)
class ResponseModel<T> {
  final dynamic code; //String 또는 int로 옴!!
  final String message;
  final T data; //얘는 계층적으로 계속 탈 수도 있음.

  ResponseModel({
    required this.code,
    required this.message,
    required this.data,
  });

  factory ResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$ResponseModelFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$ResponseModelToJson(this, toJsonT);
}
