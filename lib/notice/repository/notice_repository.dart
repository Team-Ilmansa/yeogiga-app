import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/notice/model/notice_model.dart';

final noticeRepositoryProvider = Provider<NoticeRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return NoticeRepository(baseUrl: baseUrl, dio: dio);
});

class NoticeRepository {
  final String baseUrl;
  final Dio dio;

  NoticeRepository({required this.baseUrl, required this.dio});

  // 공지사항 생성
  Future<Map<String, dynamic>> createNotice({
    required int tripId,
    required String title,
    required String description,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/trip/$tripId/notices',
        data: {'title': title, 'description': description},
        options: Options(headers: {"accessToken": 'true'}),
      );

      if (response.statusCode == 201) {
        return {'success': true, 'message': '공지사항이 성공적으로 생성되었습니다.'};
      }

      return {'success': false, 'message': '공지사항 생성에 실패했습니다.'};
    } catch (e) {
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        final code = responseData['code']?.toString() ?? '';

        switch (code) {
          case 'G002':
            final errors = responseData['errors'] as Map<String, dynamic>?;
            List<String> errorMessages = [];
            if (errors != null) {
              if (errors['title'] != null) errorMessages.add(errors['title']);
              if (errors['description'] != null)
                errorMessages.add(errors['description']);
            }
            return {
              'success': false,
              'message':
                  errorMessages.isNotEmpty
                      ? errorMessages.join('\n')
                      : '입력값을 확인해주세요.',
            };
          case 'T007':
            return {'success': false, 'message': '여행 방장만 공지사항을 생성할 수 있습니다.'};
          case 'T006':
            return {'success': false, 'message': '해당 여행이 존재하지 않습니다.'};
          default:
            return {
              'success': false,
              'message':
                  responseData['message']?.toString() ?? '공지사항 생성에 실패했습니다.',
            };
        }
      }

      return {'success': false, 'message': '네트워크 오류가 발생했습니다.'};
    }
  }

  // 공지사항 목록 조회
  Future<Map<String, dynamic>> fetchNoticeList({
    required int tripId,
    // int page = 0,
    // int size = 10,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/trip/$tripId/notices',
        // queryParameters: {
        //   'page': page,
        //   'size': size,
        // },
        options: Options(headers: {"accessToken": 'true'}),
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final content = data['content'] as List?;

        if (content != null) {
          final notices =
              content
                  .map<NoticeModel?>((e) {
                    try {
                      return NoticeModel.fromJson(e);
                    } catch (_) {
                      return null;
                    }
                  })
                  .where((notice) => notice != null)
                  .cast<NoticeModel>()
                  .toList();

          return {
            'success': true,
            'notices': notices,
            'totalElements': data['page']?['totalElements'] ?? 0,
            'totalPages': data['page']?['totalPages'] ?? 0,
          };
        }
      }

      return {
        'success': false,
        'message': '공지사항을 불러오는데 실패했습니다.',
        'notices': <NoticeModel>[],
      };
    } catch (e) {
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        final code = responseData['code']?.toString() ?? '';

        switch (code) {
          case 'N000':
            return {
              'success': false,
              'message': '존재하지 않는 공지사항입니다.',
              'notices': <NoticeModel>[],
            };
          default:
            return {
              'success': false,
              'message':
                  responseData['message']?.toString() ?? '공지사항을 불러오는데 실패했습니다.',
              'notices': <NoticeModel>[],
            };
        }
      }

      return {
        'success': false,
        'message': '네트워크 오류가 발생했습니다.',
        'notices': <NoticeModel>[],
      };
    }
  }

  // 공지사항 수정
  Future<Map<String, dynamic>> updateNotice({
    required int tripId,
    required int noticeId,
    required String title,
    required String description,
  }) async {
    try {
      final response = await dio.put(
        '$baseUrl/trip/$tripId/notices/$noticeId',
        data: {
          'title': title,
          'description': description,
        },
        options: Options(headers: {"accessToken": 'true'}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': '공지사항이 성공적으로 수정되었습니다.'};
      }

      return {'success': false, 'message': '공지사항 수정에 실패했습니다.'};
    } catch (e) {
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        final code = responseData['code']?.toString() ?? '';

        switch (code) {
          case 'G002':
            final errors = responseData['errors'] as Map<String, dynamic>?;
            List<String> errorMessages = [];
            if (errors != null) {
              if (errors['title'] != null) errorMessages.add(errors['title']);
              if (errors['description'] != null) errorMessages.add(errors['description']);
            }
            return {
              'success': false,
              'message': errorMessages.isNotEmpty
                  ? errorMessages.join('\n')
                  : '입력값을 확인해주세요.',
            };
          case 'N001':
            return {'success': false, 'message': '공지사항의 작성자가 아닙니다.'};
          case 'N000':
            return {'success': false, 'message': '존재하지 않는 공지사항입니다.'};
          default:
            return {
              'success': false,
              'message': responseData['message']?.toString() ?? '공지사항 수정에 실패했습니다.',
            };
        }
      }

      return {'success': false, 'message': '네트워크 오류가 발생했습니다.'};
    }
  }

  // 공지사항 삭제
  Future<Map<String, dynamic>> deleteNotice({
    required int tripId,
    required int noticeId,
  }) async {
    try {
      final response = await dio.delete(
        '$baseUrl/trip/$tripId/notices/$noticeId',
        options: Options(headers: {"accessToken": 'true'}),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': '공지사항이 성공적으로 삭제되었습니다.'};
      }

      return {'success': false, 'message': '공지사항 삭제에 실패했습니다.'};
    } catch (e) {
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        final code = responseData['code']?.toString() ?? '';

        switch (code) {
          case 'N001':
            return {'success': false, 'message': '공지사항의 작성자가 아닙니다.'};
          case 'N000':
            return {'success': false, 'message': '존재하지 않는 공지사항입니다.'};
          default:
            return {
              'success': false,
              'message': responseData['message']?.toString() ?? '공지사항 삭제에 실패했습니다.',
            };
        }
      }

      return {'success': false, 'message': '네트워크 오류가 발생했습니다.'};
    }
  }

  // 공지사항 완료 상태 변경
  Future<Map<String, dynamic>> toggleNoticeComplete({
    required int tripId,
    required int noticeId,
    required bool completed,
  }) async {
    try {
      final response = await dio.patch(
        '$baseUrl/trip/$tripId/notices/$noticeId/completed',
        data: {
          'completed': completed,
        },
        options: Options(headers: {"accessToken": 'true'}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': completed ? '공지사항이 완료로 변경되었습니다.' : '공지사항이 미완료로 변경되었습니다.'
        };
      }

      return {'success': false, 'message': '공지사항 상태 변경에 실패했습니다.'};
    } catch (e) {
      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        final code = responseData['code']?.toString() ?? '';

        switch (code) {
          case 'N001':
            return {'success': false, 'message': '공지사항의 작성자가 아닙니다.'};
          case 'N000':
            return {'success': false, 'message': '존재하지 않는 공지사항입니다.'};
          default:
            return {
              'success': false,
              'message': responseData['message']?.toString() ?? '공지사항 상태 변경에 실패했습니다.',
            };
        }
      }

      return {'success': false, 'message': '네트워크 오류가 발생했습니다.'};
    }
  }
}
