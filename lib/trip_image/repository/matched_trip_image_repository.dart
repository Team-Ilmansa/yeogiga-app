import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/trip_image/model/trip_image_model.dart';

final matchedTripImageRepository = Provider<MatchedTripImageRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return MatchedTripImageRepository(baseUrl: 'https://$ip', dio: dio);
});

class MatchedTripImageRepository {
  final String baseUrl;
  final Dio dio;

  MatchedTripImageRepository({required this.baseUrl, required this.dio});

  // TODO: 이미지들을 목적지에 다시 매칭 (re-assign)
  Future<bool> reassignImagesToPlaces({
    required int tripId,
    required String tripDayPlaceId,
  }) async {
    try {
      final response = await dio.patch(
        '$baseUrl/api/v1/trip/$tripId/day-place/$tripDayPlaceId/images/re-assign',
        options: Options(headers: {'accessToken': 'true'}),
      );
      final data = response.data;
      if (data['code'] == 200) {
        return true;
      } else {
        throw data['message'] ?? '알 수 없는 오류';
      }
    } on DioError catch (e) {
      final msg = e.response?.data['message'] ?? e.message;
      throw msg;
    } catch (e) {
      return false;
    }
  }

  // TODO: 목적지에 매칭된 이미지들을 불러옴
  Future<MatchedPlaceImage> fetchMatchedPlaceImages({
    required int tripId,
    required String tripDayPlaceId,
    required String placeId,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip/$tripId/day-place/$tripDayPlaceId/places/$placeId/images',
        options: Options(headers: {'accessToken': 'true'}),
      );
      final data = response.data;
      if (data['code'] == 200 && data['data'] != null) {
        return MatchedPlaceImage.fromJson(data['data'] as Map<String, dynamic>);
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

  // TODO: 여러 이미지를(매칭/미매칭 구분 없이) 한 번에 삭제
  Future<bool> deleteImages({
    required int tripId,
    required List<String> imageIds,
    required List<String> urls,
  }) async {
    try {
      final response = await dio.delete(
        '$baseUrl/api/v1/trip/$tripId/images',
        data: {'imageIds': imageIds, 'urls': urls},
        options: Options(headers: {'accessToken': 'true'}),
      );
      final data = response.data;
      if (data['code'] == 200) {
        return true;
      } else {
        throw data['message'] ?? '알 수 없는 오류';
      }
    } on DioError catch (e) {
      final msg = e.response?.data['message'] ?? e.message;
      throw msg;
    } catch (e) {
      return false;
    }
  }
}
