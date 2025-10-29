import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/main_trip/model/main_trip_model.dart';

final mainTripRepositoryProvider = Provider<MainTripRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return MainTripRepository(baseUrl: baseUrl, dio: dio);
});

class MainTripRepository {
  final String baseUrl;
  final Dio dio;

  MainTripRepository({required this.baseUrl, required this.dio});

  /// 메인 트립 정보 조회
  Future<MainTripModel?> fetchMainTrip() async {
    try {
      final response = await dio.get(
        '$baseUrl/trip/main',
        options: Options(headers: {"accessToken": 'true'}),
      );
      if (response.statusCode == 200 && response.data['data'] != null) {
        return MainTripModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
