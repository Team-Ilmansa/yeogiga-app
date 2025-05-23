import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/view/splash_screen.dart';
import 'package:yeogiga/trip/view/trip_date_range_picker_screen.dart';
import 'package:yeogiga/user/view/login_screen.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/user/view/register_flow_screen.dart';
import 'package:yeogiga/common/view/screen_wrapper.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider(ref: ref);
});

class AuthProvider extends ChangeNotifier {
  final Ref ref;

  AuthProvider({required this.ref}) {
    ref.listen<UserModelBase?>(userMeProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }

  List<GoRoute> get routes => [
    GoRoute(
      path: '/',
      name: ScreenWrapper.routeName,
      builder: (_, __) => ScreenWrapper(),
      routes: [],
    ),
    GoRoute(
      path: '/splash',
      name: SplashScreen.routeName,
      builder: (_, __) => SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: LoginScreen.routeName,
      builder: (_, __) => LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: RegisterFlowScreen.routeName,
      builder: (_, __) => RegisterFlowScreen(),
    ),
    GoRoute(
      path: '/dateRangePicker',
      name: TripDateRangePickerScreen.routeName,
      builder: (_, __) => TripDateRangePickerScreen(),
    ),
  ];

  // SplashScreen
  // 앱을 처음 시작했을때
  // 토큰이 존재하는지 확인하고
  // 로그인 스크린으로 보내줄지
  // 홈 스크린으로 보내줄지 확인하는 과정이 필요하다.
  String? redirectLogic(BuildContext context, GoRouterState state) {
    final UserModelBase? user = ref.read(userMeProvider);

    final loggingInOrRegister =
        state.location == '/login' || state.location == '/register';

    // 유저 정보가 없는데
    // 로그인/회원가입 중이면 그대로 두고
    // 그 외에는 로그인 페이지로 이동
    if (user is! UserResponseModel) {
      return loggingInOrRegister ? null : '/login';
    }

    // UserResponseModel이지만 정상 유저 정보(code==200, data!=null)만 홈으로 이동
    if (user.code == 200 && user.data != null) {
      return loggingInOrRegister || state.location == '/splash' ? '/' : null;
    }

    // 실패 응답(UserResponseModel이지만 code!=200 또는 data==null)
    return loggingInOrRegister ? null : '/login';
  }
}
