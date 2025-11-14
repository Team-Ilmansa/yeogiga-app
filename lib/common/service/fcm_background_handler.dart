import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yeogiga/trip/repository/trip_member_location_repository.dart';
import 'package:yeogiga/trip/repository/trip_host_route_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip_list/repository/trip_list_repository.dart';

List<TripModel> _extractInProgressTrips(List<TripModel?> trips) {
  return trips
      .whereType<TripModel>()
      .where((trip) => trip.status == TripStatus.IN_PROGRESS)
      .toList();
}

int _calculateTripDay(TripModel trip) {
  try {
    if (trip.startedAt == null) {
      return 1;
    }
    final start = DateTime.parse(trip.startedAt!.substring(0, 10));
    final now = DateTime.now();
    final day = now.difference(start).inDays + 1;
    return day < 1 ? 1 : day;
  } catch (_) {
    return 1;
  }
}

Future<void> syncTripLocations(
  ProviderContainer container, {
  String? fallbackTripId,
}) async {
  final rawTripId = fallbackTripId;

  // 1) 현재 위치 확보
  double latitude = 0.0;
  double longitude = 0.0;
  try {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    latitude = position.latitude;
    longitude = position.longitude;
  } catch (e) {
    print('[FCM] 위치 획득 실패: $e');
  }

  // 2) 위치를 전송해야 하는 여행 목록 (IN_PROGRESS)
  List<TripModel> targetTrips = [];
  try {
    final tripListRepo = container.read(tripListRepositoryProvider);
    final trips = await tripListRepo.fetchAllTripList();
    targetTrips = _extractInProgressTrips(trips);
  } catch (e) {
    print('[FCM] 여행 목록 조회 실패: $e');
  }

  // 2-1) 모든 목록이 비었고, fallback tripId가 있으면 해당 여행 조회
  if (targetTrips.isEmpty && rawTripId is String && rawTripId.isNotEmpty) {
    final tripIdInt = int.tryParse(rawTripId);
    if (tripIdInt != null) {
      try {
        final tripState = await container
            .read(tripProvider.notifier)
            .getTrip(tripId: tripIdInt);
        if (tripState is TripModel &&
            tripState.status == TripStatus.IN_PROGRESS) {
          targetTrips = [tripState];
        }
      } catch (e) {
        print('[FCM] 단일 trip fallback 실패: $e');
      }
    }
  }

  if (targetTrips.isEmpty) {
    print('[FCM] 위치 전송 대상 IN_PROGRESS 여행 없음');
    return;
  }

  // 3) 대상 여행들에 대해 위치 전송
  final memberRepo = container.read(tripMemberLocationRepository);
  final hostRepo = container.read(tripHostRouteRepositoryProvider);

  for (final trip in targetTrips) {
    final tripIdStr = trip.tripId.toString();
    final day = _calculateTripDay(trip);
    try {
      final ok = await memberRepo.saveMemberLocation(
        tripId: tripIdStr,
        latitude: latitude,
        longitude: longitude,
      );
      print('[FCM] 멤버 위치 저장 결과 (tripId=$tripIdStr): $ok');
    } catch (e) {
      print('[FCM] 멤버 위치 저장 실패 (tripId=$tripIdStr): $e');
    }
  }
}

/// FCM Silent(데이터-only) 메시지 및 위치 전송 핸들러
/// firebase_messaging 15.x, firebase_core 3.x 대응
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(
  RemoteMessage message,
  ProviderContainer container,
) async {
  final rawTripId = message.data['tripId'];
  await syncTripLocations(container, fallbackTripId: rawTripId);
}
