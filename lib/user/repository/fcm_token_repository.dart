import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';

final fcmTokenRepositoryProvider = Provider((ref) {
  final dio = ref.watch(dioProvider);
  return FcmTokenRepository(dio: dio, baseUrl: 'https://$ip');
});

class FcmTokenRepository {
  final Dio dio;
  final String baseUrl;

  FcmTokenRepository({required this.dio, required this.baseUrl});

  /// FCM 토큰 저장
  Future<bool> saveFcmToken({required String fcmToken}) async {
    try {
      final url = '$baseUrl/api/v1/users/fcm-token';
      await dio.post(
        url,
        data: {'fcmToken': fcmToken},
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

  /// FCM 토큰 삭제
  Future<bool> deleteFcmToken() async {
    try {
      final url = '$baseUrl/api/v1/users/fcm-token';
      await dio.delete(
        url,
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
}
