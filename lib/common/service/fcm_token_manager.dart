import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/user/repository/fcm_token_repository.dart';

const _apnsPollInterval = Duration(milliseconds: 200);
const _apnsMaxWait = Duration(seconds: 3);

/// APNs 토큰이 준비될 때까지 대기한 뒤 FCM 토큰을 반환한다.
Future<String?> fetchFcmTokenWithApnsWait() async {
  final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  if (isIos) {
    final maxAttempts =
        (_apnsMaxWait.inMilliseconds / _apnsPollInterval.inMilliseconds).ceil();
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) {
        print('[FCM] APNs token: $apnsToken');
        break;
      }
      await Future.delayed(_apnsPollInterval);
    }
  }
  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken != null && fcmToken.isNotEmpty) {
    print('[FCM] FCM token: $fcmToken');
  } else {
    print('[FCM] Failed to obtain FCM token');
  }
  return fcmToken;
}

/// 앱 시작/켜질 때 FCM 토큰 발급 및 서버 등록 (firebase_messaging 15.x 대응)
/// onTokenRefresh StreamSubscription은 필요시 dispose에서 해제 권장
Future<void> registerFcmToken(Ref ref) async {
  try {
    // FCM 권한 요청 (iOS/Android 모두 안전)
    await FirebaseMessaging.instance.requestPermission();

    // 공식 권장 패턴: getToken()을 바로 호출하지 않고, onTokenRefresh에서 최초 토큰을 받아 서버에 저장

    // 이미 토큰이 존재하는 경우(앱 재설치가 아닌 경우 등)만 예외적으로 저장
    final existingToken = await fetchFcmTokenWithApnsWait();
    if (existingToken != null && existingToken.isNotEmpty) {
      final repo = ref.read(fcmTokenRepositoryProvider);
      await repo.saveFcmToken(fcmToken: existingToken);
    }

    // 최초 토큰 발급 및 갱신 모두 listen
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        final repo = ref.read(fcmTokenRepositoryProvider);
        await repo.saveFcmToken(fcmToken: newToken);
      } catch (e, s) {
        print('FCM 토큰 갱신 저장 실패: $e $s');
      }
    });
  } catch (e, s) {
    // 에러 로깅 (예: print/Crashlytics)
    print('FCM 토큰 발급 실패: $e $s');
  }
}
