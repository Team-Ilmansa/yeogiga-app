class TripMemberLocation {
  final double latitude;
  final double longitude;
  final int userId;
  final String nickname;
  final String? imageUrl;

  TripMemberLocation({
    required this.latitude,
    required this.longitude,
    required this.userId,
    required this.nickname,
    this.imageUrl,
  });

  factory TripMemberLocation.fromJson(Map<String, dynamic> json) {
    return TripMemberLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      userId: json['userId'] as int,
      nickname: json['nickname'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
