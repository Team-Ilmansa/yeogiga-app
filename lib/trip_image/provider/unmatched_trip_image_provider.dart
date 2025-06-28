import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/trip_image/model/trip_image_model.dart';
import 'package:yeogiga/trip_image/repository/unmatched_trip_image_repository.dart';

final unmatchedTripImagesProvider = StateNotifierProvider<
  UnmatchedDayTripImageNotifier,
  List<UnMatchedDayTripImage>
>((ref) {
  final repo = ref.watch(unmatchedTripImageRepository);
  return UnmatchedDayTripImageNotifier(repo);
});

/// 각 일차의 day, tripDayPlaceId를 담는 구조체
class UnMatchedTripDayPlaceInfo {
  final int day;
  final String tripDayPlaceId;
  UnMatchedTripDayPlaceInfo({required this.day, required this.tripDayPlaceId});
}

class UnmatchedDayTripImageNotifier
    extends StateNotifier<List<UnMatchedDayTripImage>> {
  final UnmatchedTripImageRepository repo;

  UnmatchedDayTripImageNotifier(this.repo) : super([]);

  /// TODO: 모든 일차별 매칭되지 않은 이미지 fetch
  Future<void> fetchAll(
    int tripId,
    List<UnMatchedTripDayPlaceInfo> dayPlaceIds,
  ) async {
    state = await Future.wait(
      dayPlaceIds.map(
        (e) => repo.fetchUnmatchedDayTripImages(
          tripId: tripId,
          tripDayPlaceId: e.tripDayPlaceId,
          day: e.day,
        ),
      ),
    );
  }

  // TODO: 하루의 이미지만 새로 fetch해서 state에 반영
  // 하루의 이미지만 새로 fetch해서 state에 반영 (state의 index와 day, tripDayPlaceId가 일치해야 함)
  Future<void> fetchDay(int tripId, int day, String tripDayPlaceId) async {
    final index = state.indexWhere(
      (e) => e.day == day && e.tripDayPlaceId == tripDayPlaceId,
    );
    if (index == -1) return;
    final newItem = await repo.fetchUnmatchedDayTripImages(
      tripId: tripId,
      tripDayPlaceId: tripDayPlaceId,
      day: day,
    );
    final newState = [...state];
    newState[index] = newItem;
    state = newState;
  }
}
