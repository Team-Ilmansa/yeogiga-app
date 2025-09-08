import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/schedule/repository/confirm_schedule_repository.dart';

final completedScheduleProvider = StateNotifierProvider<
  CompletedScheduleNotifier,
  AsyncValue<CompletedTripDayPlaceListModel?>
>((ref) {
  final repo = ref.watch(confirmScheduleRepositoryProvider);
  return CompletedScheduleNotifier(repo);
});

class CompletedScheduleNotifier
    extends StateNotifier<AsyncValue<CompletedTripDayPlaceListModel?>> {
  final ConfirmScheduleRepository repo;
  CompletedScheduleNotifier(this.repo) : super(const AsyncValue.data(null));

  Future<void> fetch(int tripId) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await repo.fetchCompletedTripDayPlaces(tripId: tripId);
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clear() => state = const AsyncValue.data(null);
}
