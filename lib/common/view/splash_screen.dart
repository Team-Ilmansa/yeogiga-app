import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/common/utils/system_ui_helper.dart';
import 'package:yeogiga/common/provider/uprising_place_provider.dart';
import 'package:yeogiga/common/provider/weather_provider.dart';
import 'package:yeogiga/main_trip/provider/main_trip_provider.dart';
import 'package:yeogiga/trip_list/provider/trip_list_provider.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/user/model/user_model.dart';

class SplashScreen extends ConsumerStatefulWidget {
  static String get routeName => 'splash';

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;

    // 1. 먼저 인증 상태 확인 (userMeProvider의 getMe() 완료 대기)
    await _waitForAuth();

    if (!mounted) return;

    // 2. 인증된 사용자인지 확인
    final user = ref.read(userMeProvider);
    final isAuthenticated =
        user is UserResponseModel && user.code == 200 && user.data != null;

    // 3. 인증된 사용자만 데이터 로딩
    if (isAuthenticated) {
      try {
        // 모든 필수 데이터를 병렬로 로딩
        await Future.wait([
          // 메인 여행 데이터 (FutureProvider는 ref.read로 강제 실행)
          Future(() => ref.read(mainTripFutureProvider.future)),

          // 지난 여행 목록
          ref.read(pastTripListProvider.notifier).fetchAndSetPastTrips(),

          // 설정 중인 여행 목록
          ref.read(settingTripListProvider.notifier).fetchAndSetSettingTrips(),

          // 급상승 여행지
          ref.read(uprisingPlaceProvider.notifier).fetchUprisingPlaces(),

          // 날씨 정보
          ref.read(weatherProvider.notifier).fetchWeather(),
        ]);
      } catch (e) {
        // 에러 발생 시에도 홈 화면으로 이동 (각 섹션에서 에러 처리)
        debugPrint('SplashScreen data loading error: $e');
      }
    }

    // 4. redirectLogic이 홈 화면으로 이동시킴 (인증 여부에 따라 /login 또는 /)
    // context.go 호출 불필요 - GoRouter의 redirect가 자동 처리
  }

  /// 인증 상태가 확정될 때까지 대기
  Future<void> _waitForAuth() async {
    const maxWaitTime = Duration(seconds: 5);
    const checkInterval = Duration(milliseconds: 100);
    final startTime = DateTime.now();

    while (mounted) {
      final user = ref.read(userMeProvider);

      // UserModelLoading이 아니면 인증 완료 (성공/실패 확정)
      if (user is! UserModelLoading) {
        return;
      }

      // 최대 대기 시간 초과
      if (DateTime.now().difference(startTime) > maxWaitTime) {
        debugPrint('Auth check timeout');
        return;
      }

      await Future.delayed(checkInterval);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: shouldUseSafeAreaBottom(context),
      child: Scaffold(
        backgroundColor: Color(0xfffafafa),
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('asset/img/logo/logo.png', width: 70.w, height: 70.w),
            ],
          ),
        ),
      ),
    );
  }
}
