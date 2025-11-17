// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uprising_place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UprisingPlaceModel _$UprisingPlaceModelFromJson(Map<String, dynamic> json) =>
    UprisingPlaceModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      address: json['address'] as String,
      placeCategory: json['placeCategory'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$UprisingPlaceModelToJson(UprisingPlaceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'placeCategory': instance.placeCategory,
      'url': instance.url,
    };

UprisingPlaceResponse _$UprisingPlaceResponseFromJson(
  Map<String, dynamic> json,
) => UprisingPlaceResponse(
  code: (json['code'] as num).toInt(),
  message: json['message'] as String,
  data:
      (json['data'] as List<dynamic>)
          .map((e) => UprisingPlaceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$UprisingPlaceResponseToJson(
  UprisingPlaceResponse instance,
) => <String, dynamic>{
  'code': instance.code,
  'message': instance.message,
  'data': instance.data,
};
