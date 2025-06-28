import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yeogiga/trip/repository/trip_member_location_repository.dart';
import 'package:yeogiga/trip/repository/trip_host_route_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // 알림 예시용

/// FCM Silent(데이터-only) 메시지 및 위치 전송 핸들러
/// firebase_messaging 15.x, firebase_core 3.x, flutter_local_notifications 19.x 대응 예시
@pragma('vm:entry-point')
Future<void> fcmBackgroundHandler(
  RemoteMessage message,
  ProviderContainer container,
) async {
  // 1. tripId 필수 체크
  final tripId = message.data['tripId'] ?? '';
  if (tripId.isEmpty) {
    print('[FCM] tripId 누락 - 위치 업데이트 중단');
    return;
  }

  // 2. 위치 정보 획득 (권한 없거나 실패 시 0,0 처리)
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

  // 3. 오늘이 몇일차인지 계산 (tripProvider에서 startedAt 기준)
  int day = 1;
  try {
    final tripIdInt = int.tryParse(tripId);
    if (tripIdInt != null) {
      final tripState = await container
          .read(tripProvider.notifier)
          .getTrip(tripId: tripIdInt);
      if (tripState is TripModel && tripState.startedAt != null) {
        final start = DateTime.parse(tripState.startedAt!.substring(0, 10));
        final now = DateTime.now();
        day = now.difference(start).inDays + 1;
        if (day < 1) day = 1;
      }
    }
  } catch (e) {
    print('[FCM] day 계산 실패: $e');
  }

  // 4. 위치 서버 전송 (멤버/호스트)
  try {
    final memberRepo = container.read(tripMemberLocationRepository);
    final ok = await memberRepo.saveMemberLocation(
      tripId: tripId,
      latitude: latitude,
      longitude: longitude,
    );
    print('[FCM] 멤버 위치 저장 결과: $ok');
  } catch (e) {
    print('[FCM] 멤버 위치 저장 실패: $e');
  }

  try {
    final hostRepo = container.read(tripHostRouteRepositoryProvider);
    final ok = await hostRepo.saveHostLocation(
      tripId: tripId,
      day: day,
      latitude: latitude,
      longitude: longitude,
    );
    print('[FCM] 호스트 위치 저장 결과: $ok');
  } catch (e) {
    print('[FCM] 호스트 위치 저장 실패: $e');
  }

  // 5. (선택) 디버깅/테스트용 local notification 예시
  // flutter_local_notifications 19.x 기준 예시 (background에서 직접 사용하려면 별도 초기화 필요)
  // final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  // const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // await flutterLocalNotificationsPlugin.show(
  //   0,
  //   'FCM 위치 업데이트',
  //   'tripId: $tripId, 위도: $latitude, 경도: $longitude',
  //   const NotificationDetails(android: AndroidNotificationDetails('fcm_channel', 'FCM 알림')),
  // );
}
