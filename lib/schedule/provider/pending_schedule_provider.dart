import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/schedule/repository/pending_schedule_repository.dart';

final pendingScheduleProvider = StateNotifierProvider.autoDispose<
  PendingScheduleNotifier,
  PendingScheduleModel?
>((ref) {
  final repo = ref.watch(pendingScheduleRepositoryProvider);
  return PendingScheduleNotifier(repo);
});

class PendingScheduleNotifier extends StateNotifier<PendingScheduleModel?> {
  final PendingScheduleRepository repo;
  PendingScheduleNotifier(this.repo) : super(null);

  /// 전체 pending 일정 조회 (여행별)
  /// days: 여행 시작~끝 일차 리스트 (예: [1,2,3,4,5])
  Future<void> fetchAll(String tripId, List<int> days) async {
    // 각 day마다 fetchDay를 병렬로 실행
    final futures = days.map((day) => fetchDay(tripId: tripId, day: day));
    final daySchedules = await Future.wait(futures);
    // null인 day는 제외
    final validSchedules =
        daySchedules.whereType<PendingDayScheduleModel>().toList();
    // PendingScheduleModel로 만들어 상태에 저장
    state = PendingScheduleModel(
      tripId: int.parse(tripId),
      schedules: validSchedules,
    );
  }

  /// 특정 일차(day)의 일정만 조회
  Future<PendingDayScheduleModel?> fetchDay({
    required String tripId,
    required int day,
  }) async {
    return await repo.getPendingDaySchedule(tripId: tripId, day: day);
  }

  /// 특정 일차에 목적지 추가
  Future<bool> addPlace({
    required String tripId,
    required int day,
    required PendingPlaceModel place,
  }) async {
    final success = await repo.postPendingPlace(
      tripId: tripId,
      day: day,
      place: place,
    );
    if (success) {
      // 동기화: 해당 일차만 다시 불러와서 state 갱신
      final updatedDay = await fetchDay(tripId: tripId, day: day);
      if (updatedDay != null) {
        _updateDayInState(tripId, updatedDay);
      }
    }
    return success;
  }

  /// 특정 일차에서 목적지 삭제
  Future<void> deletePlace({
    required String tripId,
    required int day,
    required String placeId,
  }) async {
    final success = await repo.deletePendingPlace(
      tripId: tripId,
      day: day,
      placeId: placeId,
    );
    if (success) {
      final updatedDay = await fetchDay(tripId: tripId, day: day);
      if (updatedDay != null) {
        _updateDayInState(tripId, updatedDay);
      }
    }
  }

  /// 특정 일차에서 목적지 순서 변경
  /// TODO: Optimistic UI: 순서 변경 시 임시로 UI 반영, 실패 시 롤백
  Future<void> reorderPlaces({
    required String tripId,
    required int day,
    required List<String> orderedPlaceIds,
  }) async {
    // 1. 기존 daySchedule 백업
    final prevState = state;
    final dayIndex = state?.schedules.indexWhere((d) => d.day == day) ?? -1;
    if (dayIndex == -1 || state == null) return;
    final originalPlaces = List.of(state!.schedules[dayIndex].places);

    // 2. state를 optimistic하게 바로 변경
    state = state!.copyWith(
      schedules: [
        ...state!.schedules.sublist(0, dayIndex),
        state!.schedules[dayIndex].copyWith(
          places:
              orderedPlaceIds
                  .map((id) => originalPlaces.firstWhere((p) => p.id == id))
                  .toList(),
        ),
        ...state!.schedules.sublist(dayIndex + 1),
      ],
    );

    // 3. 서버 요청
    final success = await repo.reorderPendingPlaces(
      tripId: tripId,
      day: day,
      orderedPlaceIds: orderedPlaceIds,
    );

    if (!success) {
      // 4. 실패 시 원래 state로 롤백
      state = prevState;
    } else {
      // 성공 시 서버 데이터로 fetch하여 동기화
      final updatedDay = await fetchDay(tripId: tripId, day: day);
      if (updatedDay != null) {
        _updateDayInState(tripId, updatedDay);
      }
    }
  }

  /// 내부: 특정 day만 state에 반영 (전체 schedules 중 해당 day만 교체)
  void _updateDayInState(String tripId, PendingDayScheduleModel updatedDay) {
    final current = state;
    if (current == null) return;
    final newSchedules =
        current.schedules
            .map((d) => d.day == updatedDay.day ? updatedDay : d)
            .toList();
    state = PendingScheduleModel(
      tripId: current.tripId,
      schedules: newSchedules,
    );
  }

  /// 상태 초기화 (clear)
  void clear() => state = null;
}
