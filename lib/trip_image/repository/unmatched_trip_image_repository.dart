import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/trip_image/model/trip_image_model.dart';

final unmatchedTripImageRepository = Provider<UnmatchedTripImageRepository>((
  ref,
) {
  final dio = ref.watch(dioProvider);

  return UnmatchedTripImageRepository(baseUrl: 'https://$ip', dio: dio);
});

class UnmatchedTripImageRepository {
  final String baseUrl;
  final Dio dio;

  UnmatchedTripImageRepository({required this.baseUrl, required this.dio});

  /// TODO: 일차별 매칭되지 않은 이미지 조회
  Future<UnMatchedDayTripImage> fetchUnmatchedDayTripImages({
    required int tripId,
    required String tripDayPlaceId,
    required int day,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip/$tripId/day-place/$tripDayPlaceId/unmatched-images',
        options: Options(headers: {'accessToken': 'true'}),
      );
      final data = response.data;
      if (data['code'] == 200 && data['data'] != null) {
        final imagesJson = data['data']['images'] as List<dynamic>? ?? [];
        final images =
            imagesJson
                .map((e) => UnMatchedImage.fromJson(e as Map<String, dynamic>))
                .toList();
        return UnMatchedDayTripImage(
          tripDayPlaceId: tripDayPlaceId,
          day: day,
          pendingImages: images,
        );
      } else {
        throw data['message'] ?? '알 수 없는 오류';
      }
    } on DioError catch (e) {
      final msg = e.response?.data['message'] ?? e.message;
      throw msg;
    } catch (e) {
      throw e.toString();
    }
  }
}
