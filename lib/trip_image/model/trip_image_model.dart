import 'package:json_annotation/json_annotation.dart';

part 'trip_image_model.g.dart';

@JsonSerializable()
class PendingDayTripImage {
  final String tripDayPlaceId;
  final int day;
  final List<PendingImage> pendingImages;

  PendingDayTripImage({
    required this.tripDayPlaceId,
    required this.day,
    required this.pendingImages,
  });

  factory PendingDayTripImage.fromJson(Map<String, dynamic> json) =>
      _$PendingDayTripImageFromJson(json);

  Map<String, dynamic> toJson() => _$PendingDayTripImageToJson(this);
}

@JsonSerializable()
class PendingImage {
  final String id;
  final String url;

  PendingImage({required this.id, required this.url});

  factory PendingImage.fromJson(Map<String, dynamic> json) =>
      _$PendingImageFromJson(json);

  Map<String, dynamic> toJson() => _$PendingImageToJson(this);
}

//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

@JsonSerializable()
class UnMatchedDayTripImage {
  final String tripDayPlaceId;
  final int day;
  final List<UnMatchedImage> unmatchedImages;

  UnMatchedDayTripImage({
    required this.tripDayPlaceId,
    required this.day,
    required this.unmatchedImages,
  });

  factory UnMatchedDayTripImage.fromJson(Map<String, dynamic> json) =>
      _$UnMatchedDayTripImageFromJson(json);
  Map<String, dynamic> toJson() => _$UnMatchedDayTripImageToJson(this);
}

@JsonSerializable()
class UnMatchedImage {
  final String id;
  final String url;
  final bool favorite;

  UnMatchedImage({
    required this.id,
    required this.url,
    this.favorite = false,
  });

  factory UnMatchedImage.fromJson(Map<String, dynamic> json) =>
      _$UnMatchedImageFromJson(json);
  Map<String, dynamic> toJson() => _$UnMatchedImageToJson(this);
}

//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
//ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

@JsonSerializable()
class MatchedDayTripPlaceImage {
  final String tripDayPlaceId;
  final int day;
  final List<MatchedPlaceImage?> placeImagesList;

  MatchedDayTripPlaceImage({
    required this.tripDayPlaceId,
    required this.day,
    required this.placeImagesList,
  });

  factory MatchedDayTripPlaceImage.fromJson(Map<String, dynamic> json) =>
      _$MatchedDayTripPlaceImageFromJson(json);
  Map<String, dynamic> toJson() => _$MatchedDayTripPlaceImageToJson(this);
}

@JsonSerializable()
class MatchedPlaceImage {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? type;
  final List<MatchedImage> placeImages;

  MatchedPlaceImage({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.placeImages,
  });

  factory MatchedPlaceImage.fromJson(Map<String, dynamic> json) {
    return MatchedPlaceImage(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      type: json['placeType'] as String? ?? '', // 여기 때문에 맵핑 안됐었음.
      placeImages:
          (json['images'] as List<dynamic>?) // 여기 때문에 맵핑 안됐었음.
              ?.map((e) => MatchedImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
  Map<String, dynamic> toJson() => _$MatchedPlaceImageToJson(this);
}

@JsonSerializable()
class MatchedImage {
  final String id;
  final String url;
  final double latitude;
  final double longitude;
  final DateTime date;
  final bool favorite;

  MatchedImage({
    required this.id,
    required this.url,
    required this.latitude,
    required this.longitude,
    required this.date,
    required this.favorite,
  });

  factory MatchedImage.fromJson(Map<String, dynamic> json) =>
      _$MatchedImageFromJson(json);
  Map<String, dynamic> toJson() => _$MatchedImageToJson(this);
}
