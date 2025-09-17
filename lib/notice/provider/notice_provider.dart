import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/notice/model/notice_model.dart';
import '../repository/notice_repository.dart';

final noticeListProvider =
    StateNotifierProvider<NoticeListNotifier, List<NoticeModel>>(
      (ref) => NoticeListNotifier(ref.read(noticeRepositoryProvider)),
    );

class NoticeListNotifier extends StateNotifier<List<NoticeModel>> {
  final NoticeRepository repository;

  NoticeListNotifier(this.repository) : super([]);

  // 공지사항 생성
  Future<Map<String, dynamic>> createNotice({
    required int tripId,
    required String title,
    required String description,
  }) async {
    final result = await repository.createNotice(
      tripId: tripId,
      title: title,
      description: description,
    );
    
    // 성공 시 최신 공지사항 목록을 가져와서 상태 업데이트
    if (result['success']) {
      await fetchNoticeList(tripId: tripId);
    }
    
    return result;
  }

  // 공지사항 목록 조회 및 상태 업데이트
  Future<Map<String, dynamic>> fetchNoticeList({required int tripId}) async {
    final result = await repository.fetchNoticeList(tripId: tripId);

    if (result['success']) {
      final notices = result['notices'] as List<NoticeModel>;
      state = notices;
    }

    return result;
  }

  // 공지사항 수정
  Future<Map<String, dynamic>> updateNotice({
    required int tripId,
    required int noticeId,
    required String title,
    required String description,
  }) async {
    return await repository.updateNotice(
      tripId: tripId,
      noticeId: noticeId,
      title: title,
      description: description,
    );
  }

  // 공지사항 삭제
  Future<Map<String, dynamic>> deleteNotice({
    required int tripId,
    required int noticeId,
  }) async {
    final result = await repository.deleteNotice(
      tripId: tripId,
      noticeId: noticeId,
    );

    // 성공적으로 삭제되었으면 로컬 상태에서도 제거
    if (result['success']) {
      state = state.where((notice) => notice.id != noticeId).toList();
    }

    return result;
  }

  // 공지사항 완료 상태 변경
  Future<Map<String, dynamic>> toggleNoticeComplete({
    required int tripId,
    required int noticeId,
    required bool completed,
  }) async {
    final result = await repository.toggleNoticeComplete(
      tripId: tripId,
      noticeId: noticeId,
      completed: completed,
    );

    // 성공적으로 상태가 변경되었으면 로컬 상태도 업데이트
    if (result['success']) {
      state = state.map((notice) {
        if (notice.id == noticeId) {
          return NoticeModel(
            id: notice.id,
            title: notice.title,
            description: notice.description,
            completed: completed,
            createdAt: notice.createdAt,
            authorId: notice.authorId,
            nickname: notice.nickname,
            imageUrl: notice.imageUrl,
          );
        }
        return notice;
      }).toList();
    }

    return result;
  }
}
