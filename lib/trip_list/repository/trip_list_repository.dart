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

  Future<List<TripModel?>> fetchPastTripList() async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip',
        options: Options(headers: {"accessToken": 'true'}),
      );
      final data = response.data['data'];
      if (data == null) return <TripModel?>[];
      final content = data['content'];
      if (content == null || content is! List) return <TripModel?>[];
      final now = DateTime.now();
      return content
          .map<TripModel?>((e) {
            try {
              final trip = TripModel.fromJson(e);
              // endedAt이 현재보다 이전인 여행만 포함
              if (trip.endedAt != null) {
                final endDate = DateTime.parse(trip.endedAt!);
                if (endDate.isBefore(now)) {
                  return trip;
                }
              }
              return null;
            } catch (_) {
              return null;
            }
          })
          .where((trip) => trip != null)
          .toList();
    } catch (e) {
      // TODO: 필요시 에러 로깅
      return <TripModel?>[];
    }
  }

  Future<List<TripModel?>> fetchUpcomingTripList() async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip',
        options: Options(headers: {"accessToken": 'true'}),
      );
      final data = response.data['data'];
      if (data == null) return <TripModel?>[];
      final content = data['content'];
      if (content == null || content is! List) return <TripModel?>[];
      final now = DateTime.now();
      return content
          .map<TripModel?>((e) {
            try {
              final trip = TripModel.fromJson(e);
              // startedAt이 null이거나 현재보다 이후인 여행만 포함
              if (trip.startedAt == null) {
                return trip;
              } else {
                final startDate = DateTime.parse(trip.startedAt!);
                if (startDate.isAfter(now)) {
                  return trip;
                }
              }
              return null;
            } catch (_) {
              return null;
            }
          })
          .where((trip) => trip != null)
          .toList();
    } catch (e) {
      // TODO: 필요시 에러 로깅
      return <TripModel?>[];
    }
  }

  Future<List<TripModel?>> fetchAllTripList() async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip',
        options: Options(headers: {"accessToken": 'true'}),
      );
      final data = response.data['data'];
      print(data);
      if (data == null) return <TripModel?>[];
      final content = data['content'];
      if (content == null || content is! List) return <TripModel?>[];
      return content.map<TripModel?>((e) {
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

  Future<List<TripModel?>> fetchSettingTripList() async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip',
        options: Options(headers: {"accessToken": 'true'}),
      );
      final data = response.data['data'];
      if (data == null) return <TripModel?>[];
      final content = data['content'];
      if (content == null || content is! List) return <TripModel?>[];
      return content
          .map<TripModel?>((e) {
            try {
              final trip = TripModel.fromJson(e);
              // SETTING 상태인 여행만 포함
              if (trip.status == TripStatus.SETTING) {
                return trip;
              }
              return null;
            } catch (_) {
              return null;
            }
          })
          .where((trip) => trip != null)
          .toList();
    } catch (e) {
      // TODO: 필요시 에러 로깅
      return <TripModel?>[];
    }
  }
}
