import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/trip_image/model/trip_image_model.dart';
import 'package:yeogiga/trip_image/repository/matched_trip_image_repository.dart';

final matchedTripImagesProvider = StateNotifierProvider<
  MatchedDayTripImageNotifier,
  AsyncValue<List<MatchedDayTripPlaceImage>>
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
    extends StateNotifier<AsyncValue<List<MatchedDayTripPlaceImage>>> {
  final MatchedTripImageRepository repo;

  MatchedDayTripImageNotifier(this.repo) : super(const AsyncValue.data([]));

  /// 모든 일차-장소별 매칭 이미지 fetch
  Future<void> fetchAll(
    int tripId,
    List<MatchedDayPlaceInfo> dayPlaceInfos,
  ) async {
    state = const AsyncValue.loading();
    
    try {
      final result = await Future.wait(
        dayPlaceInfos.map((e) async {
          // 각 dayPlaceInfo의 placeIds 별로 fetchMatchedPlaceImages 실행
          final placeImagesList = await Future.wait(
            e.placeIds.map((placeId) async {
              final result = await repo.fetchMatchedPlaceImages(
                tripId: tripId,
                tripDayPlaceId: e.tripDayPlaceId,
                placeId: placeId,
              );
              print('=============$result');
              return result;
            }),
          );
          // null 필터링 (repo가 null 반환 가능성 대비)
          return MatchedDayTripPlaceImage(
            tripDayPlaceId: e.tripDayPlaceId,
            day: e.day,
            placeImagesList: placeImagesList,
          );
        }),
      );
      state = AsyncValue.data(result);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
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

  /// Optimistic UI: 이미지 ID 리스트로 즉시 state에서 제거
  void optimisticRemove(List<String> imageIds) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedState = currentState.map((dayPlace) {
      final updatedPlaceImagesList = dayPlace.placeImagesList.map((placeImages) {
        if (placeImages == null) return null;

        // placeImages에서 imageIds에 해당하는 이미지 제거
        final filteredImages = placeImages.placeImages
            .where((img) => !imageIds.contains(img.id))
            .toList();

        return MatchedPlaceImage(
          id: placeImages.id,
          name: placeImages.name,
          latitude: placeImages.latitude,
          longitude: placeImages.longitude,
          type: placeImages.type,
          placeImages: filteredImages,
        );
      }).toList();

      return MatchedDayTripPlaceImage(
        tripDayPlaceId: dayPlace.tripDayPlaceId,
        day: dayPlace.day,
        placeImagesList: updatedPlaceImagesList,
      );
    }).toList();

    state = AsyncValue.data(updatedState);
  }

  void updateFavorite(String imageId, bool favorite) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;

    final updatedState = currentState.map((dayPlace) {
      final updatedPlaceImagesList = dayPlace.placeImagesList.map((placeImages) {
        if (placeImages == null) return null;

        final updatedImages =
            placeImages.placeImages.map((img) {
              if (img.id == imageId) {
                return MatchedImage(
                  id: img.id,
                  url: img.url,
                  latitude: img.latitude,
                  longitude: img.longitude,
                  date: img.date,
                  favorite: favorite,
                );
              }
              return img;
            }).toList();

        return MatchedPlaceImage(
          id: placeImages.id,
          name: placeImages.name,
          latitude: placeImages.latitude,
          longitude: placeImages.longitude,
          type: placeImages.type,
          placeImages: updatedImages,
        );
      }).toList();

      return MatchedDayTripPlaceImage(
        tripDayPlaceId: dayPlace.tripDayPlaceId,
        day: dayPlace.day,
        placeImagesList: updatedPlaceImagesList,
      );
    }).toList();

    state = AsyncValue.data(updatedState);
  }
}
