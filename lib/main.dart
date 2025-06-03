import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/provider/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
