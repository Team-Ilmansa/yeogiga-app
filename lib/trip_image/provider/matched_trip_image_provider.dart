import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/trip_image/model/trip_image_model.dart';
import 'package:yeogiga/trip_image/repository/matched_trip_image_repository.dart';

final matchedTripImagesProvider = StateNotifierProvider<
  MatchedDayTripImageNotifier,
  List<MatchedDayTripPlaceImage>
>((ref) {
  final repo = ref.watch(matchedTripImageRepository);
  return MatchedDayTripImageNotifier(repo);
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

  MatchedDayTripImageNotifier(this.repo) : super([]);

  /// 모든 일차-장소별 매칭 이미지 fetch
  Future<void> fetchAll(
    int tripId,
    List<MatchedDayPlaceInfo> dayPlaceInfos,
  ) async {
    state = await Future.wait(
      dayPlaceInfos.map((e) async {
        // 각 dayPlaceInfo의 placeIds 별로 fetchMatchedPlaceImages 실행
        final placeImagesList = await Future.wait(
          e.placeIds.map((placeId) async {
            final result = await repo.fetchMatchedPlaceImages(
              tripId: tripId,
              tripDayPlaceId: e.tripDayPlaceId,
              placeId: placeId,
            );
            return result;
          }),
        );
        // null 필터링 (repo가 null 반환 가능성 대비)
        final filteredPlaceImagesList =
            placeImagesList.where((img) => img != null).toList();
        return MatchedDayTripPlaceImage(
          tripDayPlaceId: e.tripDayPlaceId,
          day: e.day,
          placeImagesList: filteredPlaceImagesList,
        );
      }),
    );
  }

  /// 리매핑 (re-assign)
  Future<bool> reassignImagesToPlaces({
    required int tripId,
    required List<String> tripDayPlaceIds,
  }) async {
    try {
      bool allSuccess = true;
      for (final dayPlaceId in tripDayPlaceIds) {
        final result = await repo.reassignImagesToPlaces(
          tripId: tripId,
          tripDayPlaceId: dayPlaceId,
        );
        if (!result) {
          allSuccess = false;
          break;
        }
      }
      return allSuccess;
    } catch (e, st) {
      print('reassignImagesToPlaces 예외 발생: $e\n$st');
      rethrow;
    }
  }

  /// 여러 이미지 삭제
  Future<bool> deleteImages({
    required int tripId,
    required List<String> imageIds,
    required List<String> urls,
  }) async {
    final result = await repo.deleteImages(
      tripId: tripId,
      imageIds: imageIds,
      urls: urls,
    );
    return result;
  }
}
