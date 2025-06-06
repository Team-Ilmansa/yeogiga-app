class TripHostRouteDay {
  final int day;
  final List<TripHostRoute> routes;

  TripHostRouteDay({required this.day, required this.routes});

  factory TripHostRouteDay.fromJson(Map<String, dynamic> json) {
    return TripHostRouteDay(
      day: json['day'] as int,
      routes:
          (json['routes'] as List)
              .map((e) => TripHostRoute.fromJson(e))
              .toList(),
    );
  }
}

class TripHostRoute {
  final double latitude;
  final double longitude;
  final DateTime time;

  TripHostRoute({
    required this.latitude,
    required this.longitude,
    required this.time,
  });

  factory TripHostRoute.fromJson(Map<String, dynamic> json) {
    return TripHostRoute(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      time: DateTime.parse(json['time'] as String),
    );
  }
}
