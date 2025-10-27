import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';

final pendingScheduleRepositoryProvider = Provider<PendingScheduleRepository>((
  ref,
) {
  final dio = ref.watch(dioProvider);

  return PendingScheduleRepository(baseUrl: 'https://$ip', dio: dio);
});

// 여행 생성중 레포
class PendingScheduleRepository {
  final String baseUrl;
  final Dio dio;

  PendingScheduleRepository({required this.baseUrl, required this.dio});

  /// 일정 확정 이전 상태에서, 일차에 목적지 추가
  /// 성공 시 true, 실패 시 false 반환
  Future<bool> postPendingPlace({
    required String tripId,
    required int day,
    required String id,
    required String name,
    required double latitude,
    required double longitude,
    required String placeCategory,
    String? address,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/v1/trip/$tripId/days/$day/places',
        options: Options(headers: {"accessToken": 'true'}),
        data: {
          "name": name,
          "latitude": latitude,
          "longitude": longitude,
          "placeType": placeCategory,
          "address": address,
        },
      );
      // 성공: 200, 201 등
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (e) {
      if (e is DioError &&
          e.response?.data != null &&
          e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      return false;
    }
  }

  /// 일정 확정 이전 상태에서, 일차의 모든 목적지 불러오기
  /// 반환: PendingDayScheduleModel(day: day, places: ...)
  Future<PendingDayScheduleModel> getPendingDaySchedule({
    required String tripId,
    required int day,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip/$tripId/days/$day/places',
        options: Options(headers: {"accessToken": 'true'}),
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        final places =
            data
                .map(
                  (e) => PendingPlaceModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();
        return PendingDayScheduleModel(day: day, places: places);
      }
      // 정상 응답이 아니거나 data가 없으면 빈 리스트 반환
      return PendingDayScheduleModel(day: day, places: []);
    } catch (e) {
      // 네트워크 등 예외 상황도 빈 리스트 반환
      return PendingDayScheduleModel(day: day, places: []);
    }
  }

  /// 확정되지 않은 일정에서 목적지 삭제
  /// 성공 시 true, 실패 시 false 반환
  Future<bool> deletePendingPlace({
    required String tripId,
    required int day,
    required String placeId,
  }) async {
    try {
      final response = await dio.delete(
        '$baseUrl/api/v1/trip/$tripId/days/$day/places/$placeId',
        options: Options(headers: {"accessToken": 'true'}),
      );
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (e) {
      return false;
    }
  }

  /// 확정 전 일정에서 목적지 순서 수정
  /// 성공 시 true, 실패 시 false 반환
  Future<bool> reorderPendingPlaces({
    required String tripId,
    required int day,
    required List<String> orderedPlaceIds,
  }) async {
    try {
      final response = await dio.put(
        '$baseUrl/api/v1/trip/$tripId/days/$day/places',
        options: Options(headers: {"accessToken": 'true'}),
        data: {"orderedPlaceIds": orderedPlaceIds},
      );
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (e) {
      return false;
    }
  }
}
