import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/trip/model/trip_model.dart';

final tripListRepositoryProvider = Provider<TripListRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return TripListRepository(baseUrl: 'https://$ip', dio: dio);
});

class TripListRepository {
  final String baseUrl;
  final Dio dio;

  TripListRepository({required this.baseUrl, required this.dio});

  Future<List<TripModel?>> fetchTripList() async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip',
        options: Options(headers: {"accessToken": 'true'}),
      );
      final data = response.data['data'];
      if (data == null || data is! List) return <TripModel?>[];
      return data.map<TripModel?>((e) {
        try {
          return TripModel.fromJson(e);
        } catch (_) {
          return null;
        }
      }).toList();
    } catch (e) {
      // TODO: 필요시 에러 로깅
      return <TripModel?>[];
    }
  }
}
