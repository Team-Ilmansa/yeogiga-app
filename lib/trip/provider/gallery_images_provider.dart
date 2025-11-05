import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/trip_image/provider/matched_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/pending_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/unmatched_trip_image_provider.dart';

/// 갤러리 이미지 타입
enum GalleryImageType { matched, unmatched, pending }

/// 갤러리 이미지 모델
class GalleryImage {
  final String id;
  final String url;
  final int day;
  final GalleryImageType type;
  final String? placeName;
  final String? tripDayPlaceId; // pending 이미지 삭제 시 필요

  GalleryImage({
    required this.id,
    required this.url,
    required this.day,
    required this.type,
    this.placeName,
    this.tripDayPlaceId,
  });
}

/// 필터링된 갤러리 이미지 (matched + unmatched)
/// selectedDay가 0이면 전체, 그 외에는 해당 day만
final filteredGalleryImagesProvider =
    Provider.family<List<GalleryImage>, int>((ref, selectedDay) {
  // AsyncValue에서 데이터 추출, 로딩/에러 시 빈 리스트 반환
  final matchedImages = ref.watch(matchedTripImagesProvider).valueOrNull ?? [];
  final unmatchedImages = ref.watch(unmatchedTripImagesProvider).valueOrNull ?? [];

  final List<GalleryImage> allImages = [];

  if (selectedDay == 0) {
    // 전체 날짜 이미지 합치기
    // matched
    for (final dayPlace in matchedImages) {
      for (final place in dayPlace.placeImagesList) {
        if (place != null) {
          for (final img in place.placeImages) {
            allImages.add(
              GalleryImage(
                id: img.id,
                url: img.url,
                day: dayPlace.day,
                type: GalleryImageType.matched,
                placeName: place.name,
              ),
            );
          }
        }
      }
    }
    // unmatched
    for (final dayPlace in unmatchedImages) {
      for (final img in dayPlace.unmatchedImages) {
        allImages.add(
          GalleryImage(
            id: img.id,
            url: img.url,
            day: dayPlace.day,
            type: GalleryImageType.unmatched,
          ),
        );
      }
    }
  } else {
    // 선택된 날짜만 필터링
    // matched
    for (final dayPlace in matchedImages) {
      if (dayPlace.day == selectedDay) {
        for (final place in dayPlace.placeImagesList) {
          if (place != null) {
            for (final img in place.placeImages) {
              allImages.add(
                GalleryImage(
                  id: img.id,
                  url: img.url,
                  day: dayPlace.day,
                  type: GalleryImageType.matched,
                  placeName: place.name,
                ),
              );
            }
          }
        }
      }
    }
    // unmatched
    for (final dayPlace in unmatchedImages) {
      if (dayPlace.day == selectedDay) {
        for (final img in dayPlace.unmatchedImages) {
          allImages.add(
            GalleryImage(
              id: img.id,
              url: img.url,
              day: dayPlace.day,
              type: GalleryImageType.unmatched,
            ),
          );
        }
      }
    }
  }

  return allImages;
});

/// 필터링된 pending 이미지
/// selectedDay가 0이면 전체, 그 외에는 해당 day만
final filteredPendingImagesProvider =
    Provider.family<List<GalleryImage>, int>((ref, selectedDay) {
  // AsyncValue에서 데이터 추출, 로딩/에러 시 빈 리스트 반환
  final pendingImages = ref.watch(pendingDayTripImagesProvider).valueOrNull ?? [];

  final List<GalleryImage> allPendingImages = [];

  if (selectedDay == 0) {
    // 전체 날짜 pending 이미지
    for (final dayPlace in pendingImages) {
      for (final img in dayPlace.pendingImages) {
        allPendingImages.add(
          GalleryImage(
            id: img.id,
            url: img.url,
            day: dayPlace.day,
            type: GalleryImageType.pending,
            tripDayPlaceId: dayPlace.tripDayPlaceId,
          ),
        );
      }
    }
  } else {
    // 선택된 날짜만 필터링
    for (final dayPlace in pendingImages) {
      if (dayPlace.day == selectedDay) {
        for (final img in dayPlace.pendingImages) {
          allPendingImages.add(
            GalleryImage(
              id: img.id,
              url: img.url,
              day: dayPlace.day,
              type: GalleryImageType.pending,
            ),
          );
        }
      }
    }
  }

  return allPendingImages;
});
