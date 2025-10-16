// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_day_list_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettlementDayListModel _$SettlementDayListModelFromJson(
  Map<String, dynamic> json,
) => SettlementDayListModel(
  data: (json['data'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(
      k,
      (e as List<dynamic>)
          .map((e) => SettlementModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    ),
  ),
);

Map<String, dynamic> _$SettlementDayListModelToJson(
  SettlementDayListModel instance,
) => <String, dynamic>{
  'data': instance.data.map(
    (k, e) => MapEntry(k, e.map((e) => e.toJson()).toList()),
  ),
};
