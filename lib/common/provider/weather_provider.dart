import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 위치 정보 가져오기
Future<Position> getCurrentPosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('위치 서비스가 비활성화되어 있습니다.');
  }
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('위치 권한이 거부되었습니다.');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    throw Exception('위치 권한이 영구적으로 거부되었습니다.');
  }
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

/// 날씨 API 호출 (OpenWeatherMap)
Future<Map<String, dynamic>> fetchWeather(
  double lat,
  double lon,
  String apiKey,
) async {
  final dio = Dio();
  final url =
      'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=kr';
  final response = await dio.get(url);
  if (response.statusCode == 200) {
    return response.data;
  } else {
    throw Exception('날씨 정보를 불러오지 못했습니다.');
  }
}

/// 날씨 상태 Provider

final weatherProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final position = await getCurrentPosition();
  final apiKey = "ccb5c8dd74fd149643a029d4f58b486a";
  return await fetchWeather(position.latitude, position.longitude, apiKey);
});
