import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return TripRepository(baseUrl: 'https://$ip', dio: dio);
});

class TripRepository {
  final String baseUrl;
  final Dio dio;

  TripRepository({required this.baseUrl, required this.dio});

  Future<bool> postTrip({required String title, required String city}) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/v1/trip',
        options: Options(headers: {"accessToken": 'true'}),
        data: {"title": title, "city": city},
      );

      if (response.data['code'] == 201) {
        return true;
      }
      throw Exception('알 수 없는 오류: ${response.data['message']}');
    } on DioException catch (_) {
      return false;
    }
  }
}
