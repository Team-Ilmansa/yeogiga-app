import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yeogiga/trip_image/model/trip_image_model.dart';
import 'package:yeogiga/trip_image/repository/pending_trip_image_repository.dart';

/// 여행의 일차별로 임시 저장 이미지 리스트를 모두 불러오는 provider

final pendingDayTripImagesProvider = StateNotifierProvider<
  PendingDayTripImageNotifier,
  List<PendingDayTripImage>
>((ref) {
  final repo = ref.watch(pendingTripImageRepository);
  // tripId, dayPlaceIds는 외부에서 주입 (예: constructor나 다른 provider에서)
  throw UnimplementedError('tripId와 dayPlaceIds를 주입하세요');
  // return PendingDayTripImageNotifier(repo, tripId, dayPlaceIds);
});

/// 각 일차의 day, tripDayPlaceId를 담는 구조체
class TripDayPlaceInfo {
  final int day;
  final String tripDayPlaceId;
  TripDayPlaceInfo({required this.day, required this.tripDayPlaceId});
}

class PendingDayTripImageNotifier
    extends StateNotifier<List<PendingDayTripImage>> {
  final PendingTripImageRepository repo;
  final int tripId;
  final List<TripDayPlaceInfo> dayPlaceIds;

  PendingDayTripImageNotifier(this.repo, this.tripId, this.dayPlaceIds)
    : super([]) {
    fetchAll();
  }

  // TODO: 임지 저장 이미지 전부 불러오기
  Future<void> fetchAll() async {
    state = await Future.wait(
      dayPlaceIds.map(
        (e) => repo.fetchPendingDayTripImages(
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
    final newItem = await repo.fetchPendingDayTripImages(
      tripId: tripId,
      tripDayPlaceId: tripDayPlaceId,
      day: day,
    );
    final newState = [...state];
    newState[index] = newItem;
    state = newState;
  }

  // TODO: 이미지 여러 장 업로드
  Future<bool> uploadImages({
    required String tripDayPlaceId,
    required int day,
    required List<XFile> images,
  }) async {
    bool allSuccess = true;
    // TODO: 2장씩 잘라서 업로드
    for (var i = 0; i < images.length; i += 2) {
      final chunk = images.sublist(
        i,
        i + 2 > images.length ? images.length : i + 2,
      );
      final result = await repo.uploadTripDayPlaceImages(
        tripId: tripId,
        tripDayPlaceId: tripDayPlaceId,
        images: chunk,
      );
      if (!result) {
        allSuccess = false;
        break;
      }
    }
    await fetchAll();
    return allSuccess;
  }

  // TODO: 이미지 삭제
  Future<bool> deleteImages({
    required String tempPlaceImageId,
    required List<String> imageIds,
    required List<String> urls,
  }) async {
    final result = await repo.deletePendingDayTripImages(
      tripId: tripId,
      tempPlaceImageId: tempPlaceImageId,
      imageIds: imageIds,
      urls: urls,
    );
    if (result) {
      await fetchAll();
    }
    return result;
  }

  // TODO: 이미지 목적지 매칭
  Future<bool> assignImages({required String tripDayPlaceId}) async {
    final result = await repo.assignPendingImagesToDayPlace(
      tripId: tripId,
      tripDayPlaceId: tripDayPlaceId,
    );
    if (result) {
      await fetchAll();
    }
    return result;
  }
}
