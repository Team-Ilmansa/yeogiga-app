import 'package:json_annotation/json_annotation.dart';

part 'naver_place_search_response.g.dart';

@JsonSerializable(explicitToJson: true)
class NaverPlaceSearchResponse {
  final String lastBuildDate;
  final int total;
  final int start;
  final int display;
  final List<NaverPlaceItem> items;

  NaverPlaceSearchResponse({
    required this.lastBuildDate,
    required this.total,
    required this.start,
    required this.display,
    required this.items,
  });

  factory NaverPlaceSearchResponse.fromJson(Map<String, dynamic> json) => _$NaverPlaceSearchResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NaverPlaceSearchResponseToJson(this);
}

@JsonSerializable()
class NaverPlaceItem {
  final String title;
  final String link;
  final String category;
  final String description;
  final String telephone;
  final String address;
  final String roadAddress;
  final String mapx;
  final String mapy;

  // HTML 태그 제거 함수
  static String _removeHtmlTags(String input) => input.replaceAll(RegExp(r'<[^>]*>'), '');

  NaverPlaceItem({
    required String title,
    required this.link,
    required this.category,
    required String description,
    required this.telephone,
    required String address,
    required String roadAddress,
    required this.mapx,
    required this.mapy,
  })  : title = _removeHtmlTags(title),
        description = _removeHtmlTags(description),
        address = _removeHtmlTags(address),
        roadAddress = _removeHtmlTags(roadAddress);

  /// 변환된 좌표값(double). 예: '1231234567' -> 123.1234567
  double get mapxCoord => _convertCoord(mapx);
  double get mapyCoord => _convertCoord(mapy);

  static double _convertCoord(String value) {
    if (value.length <= 7) return double.tryParse(value) ?? 0.0;
    final intPart = value.substring(0, value.length - 7);
    final fracPart = value.substring(value.length - 7);
    return double.parse('$intPart.$fracPart');
  }

  factory NaverPlaceItem.fromJson(Map<String, dynamic> json) => _$NaverPlaceItemFromJson(json);
  Map<String, dynamic> toJson() => _$NaverPlaceItemToJson(this);
}
