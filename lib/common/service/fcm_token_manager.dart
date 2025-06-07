import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yeogiga/user/repository/fcm_token_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 시작/켜질 때 FCM 토큰 발급 및 서버 등록 (firebase_messaging 15.x 대응)
/// onTokenRefresh StreamSubscription은 필요시 dispose에서 해제 권장
Future<void> registerFcmToken(Ref ref) async {
  try {
    // FCM 권한 요청 (iOS/Android 모두 안전)
    await FirebaseMessaging.instance.requestPermission();

    // 공식 권장 패턴: getToken()을 바로 호출하지 않고, onTokenRefresh에서 최초 토큰을 받아 서버에 저장
    bool tokenSaved = false;

    // 이미 토큰이 존재하는 경우(앱 재설치가 아닌 경우 등)만 예외적으로 저장
    final existingToken = await FirebaseMessaging.instance.getToken();
    if (existingToken != null) {
      final repo = ref.read(fcmTokenRepositoryProvider);
      await repo.saveFcmToken(fcmToken: existingToken);
      tokenSaved = true;
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


