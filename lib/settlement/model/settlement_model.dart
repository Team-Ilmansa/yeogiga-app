import 'package:json_annotation/json_annotation.dart';
import 'package:yeogiga/settlement/model/settlement_payer_model.dart';

part 'settlement_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SettlementModel {
  final int id;
  final String name;
  final int totalPrice;
  final String date;
  final String type;
  final int payerId;
  final bool isCompleted;
  final List<SettlementPayerModel> payers;

  SettlementModel({
    required this.id,
    required this.name,
    required this.totalPrice,
    required this.date,
    required this.type,
    required this.payerId,
    required this.isCompleted,
    required this.payers,
  });

  factory SettlementModel.fromJson(Map<String, dynamic> json) =>
      _$SettlementModelFromJson(json);

  Map<String, dynamic> toJson() => _$SettlementModelToJson(this);
}
