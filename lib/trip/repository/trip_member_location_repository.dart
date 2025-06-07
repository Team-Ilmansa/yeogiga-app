import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/trip/model/trip_member_location.dart';

final tripMemberLocationRepository = Provider((ref) {
  final dio = ref.watch(dioProvider);

  return TripMemberLocationRepository(baseUrl: 'https://$ip', dio: dio);
});

class TripMemberLocationRepository {
  final Dio dio;
  final String baseUrl;

  TripMemberLocationRepository({required this.dio, required this.baseUrl});

  // TODO: 내 위치 저장 (fcm으로 주기적으로 전송)
  Future<bool> saveMemberLocation({
    required String tripId,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = '$baseUrl/api/v1/trip/$tripId/members/location';
      await dio.post(
        url,
        data: {'latitude': latitude, 'longitude': longitude},
        options: Options(headers: {'accessToken': 'true'}),
      );
      return true;
    } catch (e) {
      if (e is DioError && e.response?.data != null) {
        final data = e.response?.data;
        if (data['code'] == 'T102' && data['message'] != null) {
          throw Exception(data['message']);
        }
        if (data['code'] == 'G002' && data['errors'] != null) {
          final errors = (data['errors'] as Map<String, dynamic>).values
              .whereType<String>()
              .join('\n');
          throw Exception(errors);
        }
        if (data['message'] != null) {
          throw Exception(data['message']);
        }
      }
      return false;
    }
  }

  /// 여행 멤버들의 현재 위치를 조회 (지도 화면에 들어가면 5분마다 조회)
  Future<List<TripMemberLocation>> fetchMemberLocations({
    required String tripId,
  }) async {
    try {
      final url = '$baseUrl/api/v1/trip/$tripId/members/location';
      final response = await dio.get(
        url,
        options: Options(headers: {'accessToken': 'true'}),
      );
      final data = response.data;

      return (data['data'] as List)
          .map((e) => TripMemberLocation.fromJson(e))
          .toList();
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
