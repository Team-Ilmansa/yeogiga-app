import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/trip/model/get_trip_response.dart';
import 'package:yeogiga/trip/model/post_trip_response.dart';
import 'package:yeogiga/trip/model/trip_model.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return TripRepository(baseUrl: 'https://$ip', dio: dio);
});

class TripRepository {
  final String baseUrl;
  final Dio dio;

  TripRepository({required this.baseUrl, required this.dio});

  //여행 생성
  Future<PostTripResponse> postTrip({required String title}) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/v1/trip',
        options: Options(headers: {"accessToken": 'true'}),
        data: {"title": title},
      );

      final postTripResponse = PostTripResponse.fromJson(response.data);

      if (postTripResponse.code == 201) {
        return postTripResponse;
      }

      // TODO: 이거에 대한 화면처리도 해야함.
      throw Exception('알 수 없는 오류: ${response.data['message']}');
    } on DioException catch (e) {
      final postTripResponse = PostTripResponse.fromJson(e.response?.data);

      return postTripResponse;
    }
  }

  //특정 여행 불러오기
  Future<GetTripResponse> getTripByTripId({required int tripId}) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip/$tripId',
        options: Options(headers: {"accessToken": 'true'}),
      );

      final getTripResponse = GetTripResponse.fromJson(response.data);

      if (getTripResponse.code == 200) {
        return getTripResponse;
      }

      throw Exception('알 수 없는 오류: ${response.data['message']}');
    } on DioException catch (e) {
      final getTripResponse = GetTripResponse.fromJson(e.response?.data);

      return getTripResponse;
    }
  }
}
