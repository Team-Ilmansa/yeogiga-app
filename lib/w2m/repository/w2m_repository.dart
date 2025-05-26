import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';

final w2mRepositoryProvider = Provider<W2mRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return W2mRepository(baseUrl: 'https://$ip', dio: dio);
});

//========================================================================================
//========================================================================================

class W2mRepository {
  final String baseUrl;
  final Dio dio;

  W2mRepository({required this.baseUrl, required this.dio});

  //TODO: 나중에는 오류난건지, w2m 확정을 안한건지도 구분 해야함.
  //일단 provider에 담아놓긴 해야함.
  //여행의 w2m 불러오기
  Future<List<Map<String, dynamic>>?> getTripW2m({required int tripId}) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip/$tripId/calendars',
        options: Options(headers: {"accessToken": 'true'}),
      );

      final data = response.data;
      final availabilities = data['data']['availabilities'] as List<dynamic>;
      // 각 요소를 Map<String, dynamic>으로 변환해서 리스트로 반환
      return availabilities.map((e) => Map<String, dynamic>.from(e)).toList();
    } on DioException catch (e) {
      return null;
    }
  }

  //TODO: 나중에는 오류난건지, w2m을 안적은건지도 구분 해야함.
  //유저의 w2m 불러오기.
  Future<List<String>?> getUserW2m({required int tripId}) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip/$tripId/calendars/me',
        options: Options(headers: {"accessToken": 'true'}),
      );

      final data = response.data;
      return data['availableDates'];
    } on DioException catch (e) {
      return null;
    }
  }

  //TODO: 뭐 때문에 실패했는지 분기도 나눠보기.
  //w2m 등록 성공하면 true, 실패하면 false
  Future<bool> postW2m({
    required int tripId,
    required List<String> availableDates,
  }) async {
    try {
      await dio.post(
        '$baseUrl/api/v1/trip/$tripId/calendars',
        options: Options(headers: {"accessToken": 'true'}),
        data: {"availableDates": availableDates},
      );

      return true;
    } on DioException catch (e) {
      return false;
    }
  }
}
