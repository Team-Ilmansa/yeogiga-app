import 'package:json_annotation/json_annotation.dart';
import 'package:yeogiga/settlement/model/settlement_model.dart';

part 'settlement_day_list_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SettlementDayListModel {
  final Map<String, List<SettlementModel>> data;

  SettlementDayListModel({required this.data});

  // 커스텀 fromJson - API 응답의 Map<String, List> 구조를 변환
  factory SettlementDayListModel.fromJson(Map<String, dynamic> json) {
    Map<String, List<SettlementModel>> data = {};
    json.forEach((date, items) {
      data[date] = (items as List)
          .map((e) => SettlementModel.fromJson(e as Map<String, dynamic>))
          .toList();
    });
    return SettlementDayListModel(data: data);
  }

  Map<String, dynamic> toJson() => _$SettlementDayListModelToJson(this);
}
