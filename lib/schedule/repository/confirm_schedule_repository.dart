import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';

final confirmScheduleRepositoryProvider = Provider<ConfirmScheduleRepository>((
  ref,
) {
  final dio = ref.watch(dioProvider);

  return ConfirmScheduleRepository(baseUrl: 'https://$ip', dio: dio);
});

class ConfirmScheduleRepository {
  final String baseUrl;
  final Dio dio;

  ConfirmScheduleRepository({required this.baseUrl, required this.dio});

  /// 여행 확정 이후 전체 일정 조회
  /// 반환: ConfirmedScheduleModel
  Future<ConfirmedScheduleModel?> fetchConfirmedSchedule({
    required int tripId,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip/$tripId/day-place/places',
        options: Options(headers: {"accessToken": 'true'}),
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        final schedules =
            data
                .map(
                  (e) => ConfirmedDayScheduleModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList();
        return ConfirmedScheduleModel(tripId: tripId, schedules: schedules);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 여행 확정 이후, 특정 일차의 목적지 리스트 조회
  /// 반환: ConfirmedDayScheduleModel
  Future<ConfirmedDayScheduleModel?> fetchConfirmedDaySchedule({
    required int tripId,
    required String dayScheduleId,
    required int day,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip/$tripId/day-place/$dayScheduleId/places',
        options: Options(headers: {"accessToken": 'true'}),
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        final places =
            data
                .map(
                  (e) =>
                      ConfirmedPlaceModel.fromJson(e as Map<String, dynamic>),
                )
                .toList();
        return ConfirmedDayScheduleModel(
          id: dayScheduleId,
          day: day,
          places: places,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 여행 확정 이후, 특정 일차에 목적지 추가
  /// 성공 시 true, 실패 시 false 반환
  Future<bool> addConfirmedPlace({
    required int tripId,
    required String tripDayPlaceId,
    required String name,
    required double latitude,
    required double longitude,
    required String placeType,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/v1/trip/$tripId/day-place/$tripDayPlaceId/places',
        options: Options(headers: {"accessToken": 'true'}),
        data: {
          "name": name,
          "latitude": latitude,
          "longitude": longitude,
          "placeType": placeType,
        },
      );
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

  /// 여행 확정 이후, 특정 일차에서 목적지 삭제
  /// 성공 시 true, 실패 시 false 반환
  Future<bool> deleteConfirmedPlace({
    required int tripId,
    required String tripDayPlaceId,
    required String placeId,
  }) async {
    try {
      final response = await dio.delete(
        '$baseUrl/api/v1/trip/$tripId/day-place/$tripDayPlaceId/places/$placeId',
        options: Options(headers: {"accessToken": 'true'}),
      );
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (e) {
      return false;
    }
  }

  //ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
  //ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

  /// completed 상태에서만 사용하는 day-place 전체 조회 API
  /// 반환: CompletedTripDayPlaceListModel
  Future<CompletedTripDayPlaceListModel?> fetchCompletedTripDayPlaces({
    required int tripId,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip/$tripId/day-place',
        options: Options(headers: {"accessToken": 'true'}),
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        final dayPlaces =
            data
                .map(
                  (e) => CompletedTripDayPlaceModel.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList();
        return CompletedTripDayPlaceListModel(tripId: tripId, data: dayPlaces);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// TODO: pending 상태의 목적지들을 confirmed로 전환하는 API
  /// 성공시 true, 실패시 false 반환
  /// 서버 응답 메시지까지 함께 반환 (성공 여부 + 에러 메시지)
  Future<bool> confirmTripSchedule({
    required int tripId,
    required int lastDay,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/v1/trip/$tripId/complete',
        options: Options(headers: {"accessToken": 'true'}),
        data: {"lastDay": lastDay},
      );
      if (response.statusCode == 201) {
        return true;
      }
      // 서버에서 에러 메시지 반환 시 Exception throw
      final msgRaw = response.data?['message'] ?? response.data?['error'];
      final msg = msgRaw is String ? msgRaw : msgRaw?.toString();
      throw Exception(msg ?? '일정 확정에 실패했습니다');
    } catch (e) {
      if (e is DioError &&
          e.response?.data != null &&
          e.response?.data['message'] != null) {
        throw Exception(e.response?.data['message']);
      }
      throw Exception(e.toString());
    }
  }

  /// 여행 확정 이후 목적지 순서 변경
  Future<bool> reorderConfirmedPlaces({
    required int tripId,
    required String tripDayPlaceId,
    required List<String> orderedPlaceIds,
  }) async {
    try {
      final response = await dio.put(
        '$baseUrl/api/v1/trip/$tripId/day-place/$tripDayPlaceId/places/order',
        options: Options(headers: {"accessToken": 'true'}),
        data: {"orderedPlaceIds": orderedPlaceIds},
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          '순서 변경 실패: status: \\${response.statusCode}, body: \\${response.data}',
        );
        return false;
      }
    } catch (e) {
      print('순서 변경 예외: $e');
      return false;
    }
  }

  /// 확정된 목적지 방문여부 체크 API
  /// PATCH /api/v1/trip/{tripId}/day-place/{tripDayPlaceId}/places/{placeId}/mark
  /// body: {"isVisited": true|false}, accessToken 필요
  /// 성공시 true, 실패시 false 반환
  Future<bool> markPlaceVisited({
    required int tripId,
    required String tripDayPlaceId,
    required String placeId,
    required bool isVisited,
  }) async {
    try {
      final response = await dio.patch(
        '$baseUrl/api/v1/trip/$tripId/day-place/$tripDayPlaceId/places/$placeId/mark',
        options: Options(headers: {"accessToken": 'true'}),
        data: {"isVisited": isVisited},
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print('방문여부 체크 실패: status: \\${response.statusCode}, body: \\${response.data}');
        return false;
      }
    } catch (e) {
      print('방문여부 체크 예외: $e');
      return false;
    }
  }

}
