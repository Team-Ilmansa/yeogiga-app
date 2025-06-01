import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/provider/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  //한국 날짜 적용
  WidgetsFlutterBinding.ensureInitialized();
  // env 파일 적용
  await dotenv.load(fileName: ".env");
  //한국 날짜 형식 적용
  await initializeDateFormatting('ko_KR', null);
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
