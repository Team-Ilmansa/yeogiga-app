import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/schedule/repository/confirm_schedule_repository.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

final confirmScheduleProvider = StateNotifierProvider.autoDispose<
  ConfirmScheduleNotifier,
  ConfirmedScheduleModel?
>((ref) {
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
