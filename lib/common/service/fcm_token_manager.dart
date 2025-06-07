import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yeogiga/user/repository/fcm_token_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 시작/켜질 때 FCM 토큰 발급 및 서버 등록
Future<void> registerFcmToken(WidgetRef ref) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    final repo = ref.read(fcmTokenRepositoryProvider);
    try {
      await repo.saveFcmToken(fcmToken: token);
    } catch (e) {
      // 에러 로깅
    }
  }
  // 토큰 갱신 시 서버 등록
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    final repo = ref.read(fcmTokenRepositoryProvider);
    try {
      await repo.saveFcmToken(fcmToken: newToken);
    } catch (e) {
      // 에러 로깅
    }
  });
}
