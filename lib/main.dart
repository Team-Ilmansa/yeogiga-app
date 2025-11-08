import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:yeogiga/common/provider/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:yeogiga/common/service/fcm_background_handler.dart';
import 'package:yeogiga/firebase_options.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:yeogiga/common/service/fcm_background_handler.dart';

// 백그라운드 핸들러는 반드시 background isolate에서 ProviderContainer를 새로 생성해야 함
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드 isolate에서도 플러터/플러그인들이 동작하도록 필수 초기화
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  // Firebase 서비스 초기화 (foreground와 동일한 설정)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('========================================');
  print('[FCM] Background 알림 수신됨!');
  print('[FCM] messageId: ${message.messageId}');
  print('[FCM] sentTime: ${message.sentTime}');
  print('[FCM] data: ${message.data}');
  print('[FCM] notification: ${message.notification}');
  if (message.notification != null) {
    print('[FCM] notification.title: ${message.notification!.title}');
    print('[FCM] notification.body: ${message.notification!.body}');
  }
  print('========================================');

  final container = ProviderContainer();
  await fcmBackgroundHandler(message, container);
  container.dispose(); // 메모리 누수 방지

  print('[FCM] Background 메시지 처리 완료');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 방향을 세로 모드로 고정
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // FCM 백그라운드 핸들러 등록 (background isolate 안전 패턴)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // foreground 용 ProviderContainer (포그라운드에서만 사용)
  final container = ProviderContainer();

  // FCM 포그라운드 메시지 처리
  FirebaseMessaging.onMessage.listen((message) async {
    print('========================================');
    print('[FCM] 🔔 Foreground 알림 수신됨!');
    print('[FCM] messageId: ${message.messageId}');
    print('[FCM] sentTime: ${message.sentTime}');
    print('[FCM] data: ${message.data}');
    print('[FCM] notification: ${message.notification}');
    if (message.notification != null) {
      print('[FCM] notification.title: ${message.notification!.title}');
      print('[FCM] notification.body: ${message.notification!.body}');
    }
    print('========================================');

    // 사일런트(데이터-only) 메시지일 때만 처리
    if (message.notification == null) {
      print('[FCM][Foreground][Silent] 사일런트 메시지 처리 시작');
      await fcmBackgroundHandler(message, container);
      print('[FCM][Foreground][Silent] 사일런트 메시지 처리 완료');
    }
  });

  // env 파일 적용
  await dotenv.load(fileName: ".env");

  //한국 날짜 형식 적용
  await initializeDateFormatting('ko_KR', null);

  //네이버 지도 api 연결!!
  await FlutterNaverMap().init(
    clientId: dotenv.get('NAVER_MAP_API_CLIENT_ID'),
    onAuthFailed:
        (ex) => switch (ex) {
          NQuotaExceededException(:final message) => print(
            "사용량 초과 (message: $message)",
          ),
          NUnauthorizedClientException() ||
          NClientUnspecifiedException() ||
          NAnotherAuthFailedException() => print("인증 실패: $ex"),
        },
  );

  // 카카오 소셜로그인 설정
  KakaoSdk.init(nativeAppKey: dotenv.get('KAKAO_NATIVE_APP_KEY'));

  runApp(ProviderScope(child: MyApp()));
}

//리버팟(provider) 적용
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    //고 라우터 적용
    return ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          theme: ThemeData(fontFamily: 'Pretendard'),
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        );
      },
    );
  }
}
