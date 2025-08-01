import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
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
  final container = ProviderContainer();
  await fcmBackgroundHandler(message, container);
  container.dispose(); // 메모리 누수 방지
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

  // FCM 백그라운드 핸들러 등록 (background isolate 안전 패턴)
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // foreground 용 ProviderContainer (포그라운드에서만 사용)
  final container = ProviderContainer();

  // FCM 포그라운드 메시지 처리
  FirebaseMessaging.onMessage.listen((message) async {
    // 사일런트(데이터-only) 메시지일 때만 print 및 처리
    if (message.notification == null) {
      print('[FCM][Foreground][Silent] 받은 메시지: ${message.data}');
      await fcmBackgroundHandler(message, container);
    }
  });

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
      designSize: const Size(1320, 2868),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          routerConfig: router,
        );
      },
    );
  }
}
