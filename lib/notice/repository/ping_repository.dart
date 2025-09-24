import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/notice/model/ping_model.dart';

final pingRepositoryProvider = Provider<PingRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return PingRepository(baseUrl: 'https://$ip', dio: dio);
});

class PingRepository {
  final String baseUrl;
  final Dio dio;

  PingRepository({required this.baseUrl, required this.dio});

  // 집결지 조회
  Future<Map<String, dynamic>> fetchPing({required int tripId}) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/trip/$tripId/pin',
        options: Options(headers: {"accessToken": 'true'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        
        if (data != null) {
          // 집결지가 존재하는 경우
          return {
            'success': true,
            'ping': {
              'place': data['place'],
              'latitude': data['latitude'],
              'longitude': data['longitude'],
              'time': data['time'],
            },
          };
        } else {
          // 집결지가 없는 경우
          return {
            'success': true,
            'ping': null,
          };
        }
      }

      return {
        'success': false,
        'message': '집결지를 불러오는데 실패했습니다.',
        'ping': null,
      };
    } catch (e) {
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        
        return {
          'success': false,
          'message': responseData['message']?.toString() ?? '집결지를 불러오는데 실패했습니다.',
          'ping': null,
        };
      }

      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다.',
        'ping': null,
      };
    }
  }

  // 집결지 생성
  Future<Map<String, dynamic>> createPing({
    required int tripId,
    required String place,
    required double latitude,
    required double longitude,
    required DateTime time,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/v1/trip/$tripId/pin',
        data: {
          'place': place,
          'latitude': latitude,
          'longitude': longitude,
          'time': time.toIso8601String(),
        },
        options: Options(headers: {"accessToken": 'true'}),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'message': '집결지가 성공적으로 생성되었습니다.'};
      }

      return {'success': false, 'message': '집결지 생성에 실패했습니다.'};
    } catch (e) {
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        final code = responseData['code']?.toString() ?? '';

        switch (code) {
          case 'G002':
            final errors = responseData['errors'] as Map<String, dynamic>?;
            List<String> errorMessages = [];
            if (errors != null) {
              if (errors['latitude'] != null) errorMessages.add(errors['latitude']);
              if (errors['longitude'] != null) errorMessages.add(errors['longitude']);
              if (errors['place'] != null) errorMessages.add(errors['place']);
              if (errors['time'] != null) errorMessages.add(errors['time']);
            }
            return {
              'success': false,
              'message':
                  errorMessages.isNotEmpty
                      ? errorMessages.join('\n')
                      : '입력값을 확인해주세요.',
            };
          case 'G004':
            return {'success': false, 'message': '요청 시각은 현재 시각 이전이 될 수 없습니다.'};
          case 'T006':
            return {'success': false, 'message': '해당 여행이 존재하지 않습니다.'};
          default:
            return {
              'success': false,
              'message':
                  responseData['message']?.toString() ?? '집결지 생성에 실패했습니다.',
            };
        }
      }

      return {'success': false, 'message': '네트워크 오류가 발생했습니다.'};
    }
  }

  // 집결지 삭제
  Future<Map<String, dynamic>> deletePing({required int tripId}) async {
    try {
      final response = await dio.delete(
        '$baseUrl/api/v1/trip/$tripId/pin',
        options: Options(headers: {"accessToken": 'true'}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': '집결지가 성공적으로 삭제되었습니다.'};
      }

      return {'success': false, 'message': '집결지 삭제에 실패했습니다.'};
    } catch (e) {
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        
        return {
          'success': false,
          'message': responseData['message']?.toString() ?? '집결지 삭제에 실패했습니다.',
        };
      }

      return {'success': false, 'message': '네트워크 오류가 발생했습니다.'};
    }
  }
}
