import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/trip_image/model/trip_image_model.dart';
import 'package:yeogiga/trip_image/repository/matched_trip_image_repository.dart';

final matchedTripImagesProvider = StateNotifierProvider<
  MatchedDayTripImageNotifier,
  List<MatchedDayTripPlaceImage>
>((ref) {
  final repo = ref.watch(matchedTripImageRepository);
  // tripId, dayPlaceInfos는 외부에서 주입 (예: constructor나 다른 provider에서)
  throw UnimplementedError('tripId와 dayPlaceInfos를 주입하세요');
  // return MatchedDayTripImageNotifier(repo, tripId, dayPlaceInfos);
});

/// 각 일차의 day, tripDayPlaceId, placeId를 담는 구조체
class MatchedDayPlaceInfo {
  final int day;
  final String tripDayPlaceId;
  final List<String> placeIds; // 각 일차 장소별 placeId 목록
  MatchedDayPlaceInfo({
    required this.day,
    required this.tripDayPlaceId,
    required this.placeIds,
  });
}

class MatchedDayTripImageNotifier
    extends StateNotifier<List<MatchedDayTripPlaceImage>> {
  final MatchedTripImageRepository repo;
  final int tripId;
  final List<MatchedDayPlaceInfo> dayPlaceInfos;

  MatchedDayTripImageNotifier(this.repo, this.tripId, this.dayPlaceInfos)
    : super([]) {
    fetchAll();
  }

  /// TODO: 모든 일차-장소별 매칭 이미지 fetch
  Future<void> fetchAll() async {
    final List<MatchedDayTripPlaceImage> result = [];
    for (final dayPlace in dayPlaceInfos) {
      // 각 장소별 fetch를 병렬로
      final placeImagesList = await Future.wait(
        dayPlace.placeIds.map(
          (placeId) => repo.fetchMatchedPlaceImages(
            tripId: tripId,
            tripDayPlaceId: dayPlace.tripDayPlaceId,
            placeId: placeId,
          ),
        ),
      );
      result.add(
        MatchedDayTripPlaceImage(
          tripDayPlaceId: dayPlace.tripDayPlaceId,
          day: dayPlace.day,
          placeImagesList: placeImagesList,
        ),
      );
    }
    state = result;
  }

  // TODO: 하루의 이미지만 새로 fetch해서 state에 반영
  Future<void> fetchDay(int day, String tripDayPlaceId) async {
    final index = dayPlaceInfos.indexWhere(
      (e) => e.day == day && e.tripDayPlaceId == tripDayPlaceId,
    );
    if (index == -1) return;
    final places = dayPlaceInfos[index].placeIds;
    final placeImagesList = await Future.wait(
      places.map(
        (placeId) => repo.fetchMatchedPlaceImages(
          tripId: tripId,
          tripDayPlaceId: tripDayPlaceId,
          placeId: placeId,
        ),
      ),
    );
    final newItem = MatchedDayTripPlaceImage(
      tripDayPlaceId: tripDayPlaceId,
      day: day,
      placeImagesList: placeImagesList,
    );
    final newState = [...state];
    newState[index] = newItem;
    state = newState;
  }

  /// TODO: 리매핑 (re-assign)
  Future<bool> reassignImagesToPlaces({required String tripDayPlaceId}) async {
    final result = await repo.reassignImagesToPlaces(
      tripId: tripId,
      tripDayPlaceId: tripDayPlaceId,
    );
    if (result) await fetchAll();
    return result;
  }

  /// TODO: 여러 이미지 삭제
  Future<bool> deleteImages({
    required List<String> imageIds,
    required List<String> urls,
  }) async {
    final result = await repo.deleteImages(
      tripId: tripId,
      imageIds: imageIds,
      urls: urls,
    );
    if (result) await fetchAll();
    return result;
  }
}
