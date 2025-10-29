import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/trip_image/model/trip_image_model.dart';

final pendingTripImageRepository = Provider<PendingTripImageRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return PendingTripImageRepository(baseUrl: baseUrl, dio: dio);
});

class PendingTripImageRepository {
  final String baseUrl;
  final Dio dio;

  PendingTripImageRepository({required this.baseUrl, required this.dio});

  /// TODO: 이미지 여러 장을 multipart로 업로드
  Future<bool> uploadTripDayPlaceImages({
    required int tripId,
    required String tripDayPlaceId,
    required File image,
  }) async {
    final url = '$baseUrl/trip/$tripId/day-place/$tripDayPlaceId/images';
    final formData = FormData();

    print('image.path ======= ${image.path}');
    final fileName = image.path.split('/').last;

    formData.files.add(
      MapEntry(
        'images',
        await MultipartFile.fromFile(image.path, filename: fileName),
      ),
    );

    try {
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            'accessToken': 'true', // 토큰 인터셉터 사용
          },
        ),
      );
      return response.statusCode == 201;
    } on DioError catch (e) {
      // 서버에서 message 필드가 있으면 추출
      final message = e.response?.data['message'] ?? e.message;
      throw message;
    } catch (e) {
      return false;
    }
  }

  /// TODO: 임시 저장 이미지 목록 불러오기
  Future<PendingDayTripImage> fetchPendingDayTripImages({
    required int tripId,
    required String tripDayPlaceId,
    required int day,
  }) async {
    final url =
        '$baseUrl/trip/$tripId/day-place/$tripDayPlaceId/temp-images';

    try {
      final response = await dio.get(
        url,
        options: Options(headers: {'accessToken': 'true'}),
      );

      final data = response.data;
      if (data['code'] == 200 && data['data'] is List) {
        final List<PendingImage> images =
            (data['data'] as List)
                .map((e) => PendingImage.fromJson(e))
                .toList();
        return PendingDayTripImage(
          tripDayPlaceId: tripDayPlaceId,
          day: day,
          pendingImages: images,
        );
      } else {
        throw data['message'] ?? '알 수 없는 오류';
      }
    } on DioError catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw message;
    } catch (e) {
      throw e.toString();
    }
  }

  /// TODO: 임시 저장 이미지들 삭제
  Future<bool> deletePendingDayTripImages({
    required int tripId,
    required String tempPlaceImageId,
    required List<String> imageIds,
    required List<String> urls,
  }) async {
    final url =
        '$baseUrl/trip/$tripId/day-place/temp-images/$tempPlaceImageId';

    try {
      final response = await dio.delete(
        url,
        data: {"imageIds": imageIds, "urls": urls},
        options: Options(headers: {'accessToken': 'true'}),
      );

      // 성공 코드(200, 204 등)에 따라 true/false 반환
      return response.statusCode == 200 || response.statusCode == 204;
    } on DioError catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw message;
    } catch (e) {
      return false;
    }
  }

  /// TODO: 임시 저장 이미지를 목적지에 매칭
  Future<bool> assignPendingImagesToDayPlace({
    required int tripId,
    required String tripDayPlaceId,
  }) async {
    final url =
        '$baseUrl/trip/$tripId/day-place/$tripDayPlaceId/images/assign';
    try {
      final response = await dio.post(
        url,
        options: Options(headers: {'accessToken': 'true'}),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioError catch (e) {
      final message = e.response?.data['message'] ?? e.message;
      throw message;
    } catch (e) {
      return false;
    }
  }
}
