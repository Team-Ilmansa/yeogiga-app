import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';

final tripImageRepositoryProvider = Provider<TripImageRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return TripImageRepository(baseUrl: baseUrl, dio: dio);
});

class TripImageRepository {
  TripImageRepository({required this.baseUrl, required this.dio});

  final String baseUrl;
  final Dio dio;

  Future<void> updateFavorite({
    required int tripId,
    required String tripDayPlaceId,
    required String imageId,
    String? placeId,
    required bool favorite,
  }) async {
    final body = <String, dynamic>{
      'favorite': favorite,
    };
    if (placeId != null && placeId.isNotEmpty) {
      body['placeId'] = placeId;
    }

    try {
      final response = await dio.patch(
        '$baseUrl/trip/$tripId/day-place/$tripDayPlaceId/images/$imageId/favorite',
        data: body,
        options: Options(headers: {'accessToken': 'true'}),
      );

      final data = response.data;
      if (data['code'] != 200) {
        throw data['message'] ?? '즐겨찾기 변경에 실패했습니다.';
      }
    } on DioError catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw message;
    }
  }
}
