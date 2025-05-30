import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/schedule/repository/confirm_schedule_repository.dart';

final completedScheduleProvider = StateNotifierProvider.autoDispose<CompletedScheduleNotifier, CompletedTripDayPlaceListModel?>((ref) {
  final repo = ref.watch(confirmScheduleRepositoryProvider);
  return CompletedScheduleNotifier(repo);
});

class CompletedScheduleNotifier extends StateNotifier<CompletedTripDayPlaceListModel?> {
  final ConfirmScheduleRepository repo;
  CompletedScheduleNotifier(this.repo) : super(null);

  Future<void> fetch(int tripId) async {
    final result = await repo.fetchCompletedTripDayPlaces(tripId: tripId);
    state = result;
  }
}
