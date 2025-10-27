import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/schedule/repository/confirm_schedule_repository.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

final confirmScheduleProvider =
    StateNotifierProvider<ConfirmScheduleNotifier, AsyncValue<ConfirmedScheduleModel?>>((
      ref,
    ) {
      final repo = ref.watch(confirmScheduleRepositoryProvider);
      return ConfirmScheduleNotifier(repo);
    });

class ConfirmScheduleNotifier extends StateNotifier<AsyncValue<ConfirmedScheduleModel?>> {
  final ConfirmScheduleRepository repo;
  ConfirmScheduleNotifier(this.repo) : super(const AsyncValue.data(null));

  /// 전체 확정 일정 조회 (여행별)
  Future<void> fetchAll(int tripId) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await repo.fetchConfirmedSchedule(tripId: tripId);
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
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
    final current = state.valueOrNull;
    if (current == null) return;
    final newSchedules =
        current.schedules
            .map((d) => d.day == updatedDay.day ? updatedDay : d)
            .toList();
    state = AsyncValue.data(ConfirmedScheduleModel(
      tripId: current.tripId,
      schedules: newSchedules,
    ));
  }

  /// 특정 일차에 목적지 추가
  Future<bool> addPlace({
    required int tripId,
    required String tripDayPlaceId,
    required String name,
    required double latitude,
    required double longitude,
    required String placeType,
    String? address,
  }) async {
    final success = await repo.addConfirmedPlace(
      tripId: tripId,
      tripDayPlaceId: tripDayPlaceId,
      name: name,
      latitude: latitude,
      longitude: longitude,
      placeType: placeType,
      address: address,
    );
    if (success) {
      await fetchAll(tripId);
    }
    return success;
  }

  /// 특정 일차에서 목적지 삭제 (Optimistic UI)
  Future<void> deletePlace({
    required int tripId,
    required String tripDayPlaceId,
    required String placeId,
  }) async {
    // 1. 먼저 UI에서 아이템 제거 (Optimistic Update)
    final currentState = state.valueOrNull;
    if (currentState != null) {
      final updatedSchedules = currentState.schedules.map((daySchedule) {
        if (daySchedule.id == tripDayPlaceId) {
          final updatedPlaces = daySchedule.places
              .where((place) => place.id != placeId)
              .toList();
          return daySchedule.copyWith(places: updatedPlaces);
        }
        return daySchedule;
      }).toList();
      
      state = AsyncValue.data(currentState.copyWith(schedules: updatedSchedules));
    }
    
    // 2. 서버에 삭제 요청
    try {
      await repo.deleteConfirmedPlace(
        tripId: tripId,
        tripDayPlaceId: tripDayPlaceId,
        placeId: placeId,
      );
    } catch (e) {
      // 3. 실패 시 전체 데이터 다시 로드 (rollback)
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
    final currentState = state.valueOrNull;
    final dayIndex =
        currentState?.schedules.indexWhere((d) => d.id == tripDayPlaceId) ?? -1;
    if (dayIndex == -1 || currentState == null) return false;
    final originalPlaces = List.of(currentState.schedules[dayIndex].places);

    // 2. state를 optimistic하게 바로 변경
    state = AsyncValue.data(currentState.copyWith(
      schedules: [
        ...currentState.schedules.sublist(0, dayIndex),
        currentState.schedules[dayIndex].copyWith(
          places:
              orderedPlaceIds
                  .map((id) => originalPlaces.firstWhere((p) => p.id == id))
                  .toList(),
        ),
        ...currentState.schedules.sublist(dayIndex + 1),
      ],
    ));

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
  void clear() => state = const AsyncValue.data(null);
}
