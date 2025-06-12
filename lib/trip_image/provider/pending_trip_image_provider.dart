import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/trip_image/model/trip_image_model.dart';
import 'package:yeogiga/trip_image/repository/pending_trip_image_repository.dart';

/// 여행의 일차별로 임시 저장 이미지 리스트를 모두 불러오는 provider

final pendingDayTripImagesProvider = StateNotifierProvider<
  PendingDayTripImageNotifier,
  List<PendingDayTripImage>
>((ref) {
  final repo = ref.watch(pendingTripImageRepository);
  return PendingDayTripImageNotifier(repo);
});

/// 각 일차의 day, tripDayPlaceId를 담는 구조체
class PendingTripDayPlaceInfo {
  final int day;
  final String tripDayPlaceId;
  PendingTripDayPlaceInfo({required this.day, required this.tripDayPlaceId});
}

class PendingDayTripImageNotifier
    extends StateNotifier<List<PendingDayTripImage>> {
  final PendingTripImageRepository repo;

  PendingDayTripImageNotifier(this.repo) : super([]);

  // 임시 저장 이미지 전부 불러오기
  Future<void> fetchAll(
    int tripId,
    List<PendingTripDayPlaceInfo> dayPlaceIds,
  ) async {
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

  // 하루의 이미지만 새로 fetch해서 state에 반영 (state의 index와 day, tripDayPlaceId가 일치해야 함)
  Future<void> fetchDay(int tripId, int day, String tripDayPlaceId) async {
    final index = state.indexWhere(
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

  // 이미지 여러 장 업로드
  Future<bool> uploadImages({
    required int tripId,
    required String tripDayPlaceId,
    required List<File> images,
  }) async {
    bool allSuccess = true;
    try {
      for (var image in images) {
        final result = await repo.uploadTripDayPlaceImages(
          tripId: tripId,
          tripDayPlaceId: tripDayPlaceId,
          image: image, // 한 장씩 리스트로 감싸서 전달
        );
        if (!result) {
          allSuccess = false;
          break;
        }
      }
    } catch (e, st) {
      print('이미지 업로드 중 예외 발생: $e\n$st');
      allSuccess = false;
    }
    return allSuccess;
  }

  // 이미지 삭제
  Future<bool> deleteImages({
    required int tripId,
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
    return result;
  }

  // 이미지 목적지 매칭
  /// 여러 dayPlaceId에 대해 assignPendingImagesToDayPlace를 순차적으로 실행
  Future<bool> assignImages({
    required int tripId,
    required List<String> tripDayPlaceIds,
  }) async {
    bool allSuccess = true;
    for (final dayPlaceId in tripDayPlaceIds) {
      try {
        final result = await repo.assignPendingImagesToDayPlace(
          tripId: tripId,
          tripDayPlaceId: dayPlaceId,
        );
        if (!result) {
          allSuccess = false;
        }
      } catch (e, st) {
        print('assignImages 예외 발생 (dayPlaceId: $dayPlaceId): $e\n$st');
        allSuccess = false;
        // 반복은 계속
      }
    }
    //항상 맵핑 완료라고 보여줄거라서 true반환으로 수정
    // return allSuccess;
    return true;
  }
}
