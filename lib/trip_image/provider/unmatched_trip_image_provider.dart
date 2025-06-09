import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/trip_image/model/trip_image_model.dart';
import 'package:yeogiga/trip_image/repository/unmatched_trip_image_repository.dart';

final unmatchedTripImagesProvider = StateNotifierProvider<
  UnmatchedDayTripImageNotifier,
  List<UnMatchedDayTripImage>
>((ref) {
  final repo = ref.watch(unmatchedTripImageRepository);
  // tripId, dayPlaceIds는 외부에서 주입 (예: constructor나 다른 provider에서)
  throw UnimplementedError('tripId와 dayPlaceIds를 주입하세요');
  // return UnmatchedDayTripImageNotifier(repo, tripId, dayPlaceIds);
});

/// 각 일차의 day, tripDayPlaceId를 담는 구조체
class TripDayPlaceInfo {
  final int day;
  final String tripDayPlaceId;
  TripDayPlaceInfo({required this.day, required this.tripDayPlaceId});
}

class UnmatchedDayTripImageNotifier
    extends StateNotifier<List<UnMatchedDayTripImage>> {
  final UnmatchedTripImageRepository repo;
  final int tripId;
  final List<TripDayPlaceInfo> dayPlaceIds;

  UnmatchedDayTripImageNotifier(this.repo, this.tripId, this.dayPlaceIds)
    : super([]) {
    fetchAll();
  }

  /// TODO: 모든 일차별 매칭되지 않은 이미지 fetch
  Future<void> fetchAll() async {
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
  Future<void> fetchDay(int day, String tripDayPlaceId) async {
    final index = dayPlaceIds.indexWhere(
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
