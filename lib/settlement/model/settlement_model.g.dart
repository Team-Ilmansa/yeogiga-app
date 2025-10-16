// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettlementModel _$SettlementModelFromJson(Map<String, dynamic> json) =>
    SettlementModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      totalPrice: (json['totalPrice'] as num).toInt(),
      date: json['date'] as String,
      type: json['type'] as String,
      payerId: (json['payerId'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool,
      payers:
          (json['payers'] as List<dynamic>)
              .map(
                (e) => SettlementPayerModel.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );

Map<String, dynamic> _$SettlementModelToJson(SettlementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'totalPrice': instance.totalPrice,
      'date': instance.date,
      'type': instance.type,
      'payerId': instance.payerId,
      'isCompleted': instance.isCompleted,
      'payers': instance.payers.map((e) => e.toJson()).toList(),
    };
