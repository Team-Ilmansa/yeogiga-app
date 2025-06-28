import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/trip/model/trip_host_route_day.dart';

final tripHostRouteRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return TripHostRouteRepository(dio: dio, baseUrl: 'https://$ip');
});

class TripHostRouteRepository {
  final Dio dio;
  final String baseUrl;

  TripHostRouteRepository({required this.dio, required this.baseUrl});

  /// TODO: 여행 방장 위치 저장 (5분마다 fcm으로 실행)
  Future<bool> saveHostLocation({
    required String tripId,
    required int day,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = '$baseUrl/api/v1/trip/$tripId/days/$day/routes';
      await dio.post(
        url,
        data: {'latitude': latitude, 'longitude': longitude},
        options: Options(headers: {'accessToken': 'true'}),
      );
      return true;
    } catch (e) {
      if (e is DioError &&
          e.response?.data != null &&
          e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      return false;
    }
  }

  /// 여행 방장 위치 전체 이력 조회 (끝난 여행 지도 들어갈 시 호출)
  Future<List<TripHostRouteDay>> fetchHostRoutes({
    required String tripId,
  }) async {
    try {
      final url = '$baseUrl/api/v1/trip/$tripId/routes';
      final response = await dio.get(
        url,
        options: Options(headers: {'accessToken': 'true'}),
      );
      final data = response.data;
      if (data['code'] == 200 && data['data'] is List) {
        return (data['data'] as List)
            .map((e) => TripHostRouteDay.fromJson(e))
            .toList();
      }
      return [];
    } catch (e) {
      if (e is DioError &&
          e.response?.data != null &&
          e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      rethrow;
    }
  }
}
