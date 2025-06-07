import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yeogiga/trip/repository/trip_member_location_repository.dart';
import 'package:yeogiga/trip/repository/trip_host_route_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';

/// FCM 백그라운드 메시지 및 위치 전송 핸들러
Future<void> fcmBackgroundHandler(RemoteMessage message, ProviderContainer container) async {
  // 위치 정보 획득 (geolocator 사용)
  Position? position;
  try {
    position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  } catch (e) {
    // 위치 획득 실패 시 null 처리
  }
  final latitude = position?.latitude ?? 0.0;
  final longitude = position?.longitude ?? 0.0;
  final tripId = message.data['tripId'] ?? '';

  // tripProvider에서 현재 trip의 startedAt 기준으로 오늘이 몇일차인지 계산
  int day = 1;
  try {
    TripModel? tripModel;
    if (tripId.isNotEmpty) {
      final tripIdInt = int.tryParse(tripId);
      if (tripIdInt != null) {
        final tripState = await container.read(tripProvider.notifier).getTrip(tripId: tripIdInt);
        if (tripState is TripModel && tripState.startedAt != null) {
          tripModel = tripState;
        }
      }
    }
    if (tripModel != null && tripModel.startedAt != null) {
      final start = DateTime.parse(tripModel.startedAt!.substring(0, 10));
      final now = DateTime.now();
      day = now.difference(start).inDays + 1;
      if (day < 1) day = 1;
    }
  } catch (e) {
    // tripProvider 접근 실패 시 day=1 유지
  }

  // 일반 멤버 위치 저장
  try {
    final memberRepo = container.read(tripMemberLocationRepository);
    await memberRepo.saveMemberLocation(
      tripId: tripId,
      latitude: latitude,
      longitude: longitude,
    );
  } catch (e) {
    // 에러 로깅
  }

  // 방장 위치 저장
  try {
    final hostRepo = container.read(tripHostRouteRepositoryProvider);
    await hostRepo.saveHostLocation(
      tripId: tripId,
      day: day,
      latitude: latitude,
      longitude: longitude,
    );
  } catch (e) {
    // 에러 로깅
  }
}
