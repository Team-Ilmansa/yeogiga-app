import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:yeogiga/schedule/component/uprising_place_card.dart';
import 'package:yeogiga/w2m/view/trip_date_range_picker_screen.dart';
import 'package:yeogiga/trip/view/trip_detail_screen.dart';
import 'package:yeogiga/user/view/login_screen.dart';
import 'package:yeogiga/user/view/register_flow_screen.dart';

void main() async {
  //한국 날짜 적용
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko_KR', null);
  runApp(const ProviderScope(child: ComponentPlayground()));
}

class ComponentPlayground extends ConsumerWidget {
  const ComponentPlayground({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(1320, 2868),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(backgroundColor: Colors.grey[200], body: Container()),
        );
      },
    );
  }
}
