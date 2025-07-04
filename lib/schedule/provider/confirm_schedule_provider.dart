import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/schedule/repository/confirm_schedule_repository.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

final confirmScheduleProvider =
    StateNotifierProvider<ConfirmScheduleNotifier, ConfirmedScheduleModel?>((
      ref,
    ) {
      final repo = ref.watch(confirmScheduleRepositoryProvider);
      return ConfirmScheduleNotifier(repo);
    });

class ConfirmScheduleNotifier extends StateNotifier<ConfirmedScheduleModel?> {
  final ConfirmScheduleRepository repo;
  ConfirmScheduleNotifier(this.repo) : super(null);

  /// 전체 확정 일정 조회 (여행별)
  Future<void> fetchAll(int tripId) async {
    final result = await repo.fetchConfirmedSchedule(tripId: tripId);
    state = result;
  }

  /// 특정 일차(dayScheduleId)의 일정만 조회 및 상태 반영
  Future<ConfirmedDayScheduleModel?> fetchDaySchedule({
    required int tripId,
    required String dayScheduleId,
    required int day,
  }) async {
    print('실행됨');
    final result = await repo.fetchConfirmedDaySchedule(
      tripId: tripId,
      dayScheduleId: dayScheduleId,
      day: day,
    );
    if (result != null) {
      _updateDayInState(tripId, result);
    }
    return result;
  }

  /// 내부: 특정 day만 state에 반영 (전체 schedules 중 해당 day만 교체)
  void _updateDayInState(int tripId, ConfirmedDayScheduleModel updatedDay) {
    final current = state;
    if (current == null) return;
    final newSchedules =
        current.schedules
            .map((d) => d.day == updatedDay.day ? updatedDay : d)
            .toList();
    state = ConfirmedScheduleModel(
      tripId: current.tripId,
      schedules: newSchedules,
    );
  }

  /// 특정 일차에 목적지 추가
  Future<bool> addPlace({
    required int tripId,
    required String tripDayPlaceId,
    required String name,
    required double latitude,
    required double longitude,
    required String placeType,
  }) async {
    final success = await repo.addConfirmedPlace(
      tripId: tripId,
      tripDayPlaceId: tripDayPlaceId,
      name: name,
      latitude: latitude,
      longitude: longitude,
      placeType: placeType,
    );
    if (success) {
      await fetchAll(tripId);
    }
    return success;
  }

  /// 특정 일차에서 목적지 삭제
  Future<void> deletePlace({
    required int tripId,
    required String tripDayPlaceId,
    required String placeId,
  }) async {
    final success = await repo.deleteConfirmedPlace(
      tripId: tripId,
      tripDayPlaceId: tripDayPlaceId,
      placeId: placeId,
    );
    if (success) {
      await fetchAll(tripId);
    }
  }

  /// 확정 일정 순서 변경 + 최신화
  /// TODO: Optimistic UI: 순서 변경 시 임시로 UI 반영, 실패 시 롤백
  Future<bool> reorderAndRefreshDaySchedule({
    required int tripId,
    required String tripDayPlaceId,
    required int day,
    required List<String> orderedPlaceIds,
  }) async {
    // 1. 기존 daySchedule 백업
    final prevState = state;
    final dayIndex =
        state?.schedules.indexWhere((d) => d.id == tripDayPlaceId) ?? -1;
    if (dayIndex == -1 || state == null) return false;
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
    final success = await repo.reorderConfirmedPlaces(
      tripId: tripId,
      tripDayPlaceId: tripDayPlaceId,
      orderedPlaceIds: orderedPlaceIds,
    );

    if (!success) {
      // 4. 실패 시 원래 state로 롤백
      state = prevState;
      return false;
    } else {
      // 성공 시 서버 데이터로 fetch하여 동기화
      await fetchDaySchedule(
        tripId: tripId,
        dayScheduleId: tripDayPlaceId,
        day: day,
      );
      return true;
    }
  }

  /// 확정 목적지 방문여부 체크 후, 해당 일차 일정 새로고침
  Future<bool> markAndRefreshPlaceVisited({
    required int tripId,
    required String tripDayPlaceId,
    required String placeId,
    required int day,
    required bool isVisited,
  }) async {
    // 1. 방문여부 체크 API 호출
    final result = await repo.markPlaceVisited(
      tripId: tripId,
      tripDayPlaceId: tripDayPlaceId,
      placeId: placeId,
      isVisited: isVisited,
    );
    // 2. 성공 시 해당 일차 일정 새로고침
    if (result) {
      await fetchDaySchedule(tripId: tripId, dayScheduleId: tripDayPlaceId, day: day);
    }
    return result;
  }

  // TODO: 여행 일정 확정용
  Future<bool> confirmAndRefreshTrip({
    required int tripId,
    required int lastDay,
    required WidgetRef ref,
  }) async {
    final repo = ref.read(confirmScheduleRepositoryProvider);
    final result = await repo.confirmTripSchedule(
      tripId: tripId,
      lastDay: lastDay,
    );
    if (result) {
      // tripProvider의 getTrip 실행 (상태 최신화)
      await ref.read(tripProvider.notifier).getTrip(tripId: tripId);
    }
    return result;
  }

  /// 상태 초기화 (clear)
  void clear() => state = null;
}
