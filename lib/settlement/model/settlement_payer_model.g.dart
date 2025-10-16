// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement_payer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettlementPayerModel _$SettlementPayerModelFromJson(
  Map<String, dynamic> json,
) => SettlementPayerModel(
  id: (json['id'] as num).toInt(),
  userId: (json['userId'] as num).toInt(),
  nickname: json['nickname'] as String,
  imageUrl: json['imageUrl'] as String?,
  price: (json['price'] as num).toInt(),
  isCompleted: json['isCompleted'] as bool,
);

Map<String, dynamic> _$SettlementPayerModelToJson(
  SettlementPayerModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'nickname': instance.nickname,
  'imageUrl': instance.imageUrl,
  'price': instance.price,
  'isCompleted': instance.isCompleted,
};
