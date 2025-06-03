// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'naver_place_search_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NaverPlaceSearchResponse _$NaverPlaceSearchResponseFromJson(
  Map<String, dynamic> json,
) => NaverPlaceSearchResponse(
  lastBuildDate: json['lastBuildDate'] as String,
  total: (json['total'] as num).toInt(),
  start: (json['start'] as num).toInt(),
  display: (json['display'] as num).toInt(),
  items:
      (json['items'] as List<dynamic>)
          .map((e) => NaverPlaceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
);

Map<String, dynamic> _$NaverPlaceSearchResponseToJson(
  NaverPlaceSearchResponse instance,
) => <String, dynamic>{
  'lastBuildDate': instance.lastBuildDate,
  'total': instance.total,
  'start': instance.start,
  'display': instance.display,
  'items': instance.items.map((e) => e.toJson()).toList(),
};

NaverPlaceItem _$NaverPlaceItemFromJson(Map<String, dynamic> json) =>
    NaverPlaceItem(
      title: json['title'] as String,
      link: json['link'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      telephone: json['telephone'] as String,
      address: json['address'] as String,
      roadAddress: json['roadAddress'] as String,
      mapx: json['mapx'] as String,
      mapy: json['mapy'] as String,
    );

Map<String, dynamic> _$NaverPlaceItemToJson(NaverPlaceItem instance) =>
    <String, dynamic>{
      'title': instance.title,
      'link': instance.link,
      'category': instance.category,
      'description': instance.description,
      'telephone': instance.telephone,
      'address': instance.address,
      'roadAddress': instance.roadAddress,
      'mapx': instance.mapx,
      'mapy': instance.mapy,
    };
