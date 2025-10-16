import 'package:json_annotation/json_annotation.dart';

part 'settlement_payer_model.g.dart';

@JsonSerializable()
class SettlementPayerModel {
  final int id;
  final int userId;
  final String nickname;
  final String? imageUrl;
  final int price;
  final bool isCompleted;

  SettlementPayerModel({
    required this.id,
    required this.userId,
    required this.nickname,
    this.imageUrl,
    required this.price,
    required this.isCompleted,
  });

  factory SettlementPayerModel.fromJson(Map<String, dynamic> json) =>
      _$SettlementPayerModelFromJson(json);

  Map<String, dynamic> toJson() => _$SettlementPayerModelToJson(this);
}
