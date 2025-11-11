import 'package:json_annotation/json_annotation.dart';

part 'basic_response.g.dart';

@JsonSerializable()
class BasicResponse {
  final dynamic code;
  final String message;

  BasicResponse({
    required this.code,
    required this.message,
  });

  factory BasicResponse.fromJson(Map<String, dynamic> json) =>
      _$BasicResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BasicResponseToJson(this);
}
