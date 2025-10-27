import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/view/splash_screen.dart';
import 'package:yeogiga/notice/view/notice_list_screen.dart';
import 'package:yeogiga/schedule/screen/naver_place_map_screen.dart';
import 'package:yeogiga/settlement/model/settlement_model.dart';
import 'package:yeogiga/settlement/view/settlement_create_screen.dart';
import 'package:yeogiga/settlement/view/settlement_detail_screen.dart';
import 'package:yeogiga/settlement/view/settlement_list_screen.dart';
import 'package:yeogiga/trip/trip_map/end/end_trip_map.dart';
import 'package:yeogiga/trip/trip_map/ing/ing_trip_map.dart';
import 'package:yeogiga/w2m/view/trip_date_range_picker_screen.dart';
import 'package:yeogiga/trip/view/trip_detail_screen.dart';
import 'package:yeogiga/user/view/login_screen.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/user/view/register_flow_screen.dart';
import 'package:yeogiga/user/view/user_recovery_screen.dart';
import 'package:yeogiga/user/view/nickname_setup_screen.dart';
import 'package:yeogiga/common/view/screen_wrapper.dart';
import 'package:yeogiga/w2m/view/w2m_overlap_calendar_screen.dart';
import 'package:yeogiga/trip/view/trip_invite_handler.dart';

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
      path: '/userRecovery',
      name: UserRecoveryScreen.routeName,
      builder: (_, __) => UserRecoveryScreen(),
    ),
    GoRoute(
      path: '/nickname',
      name: NicknameSetupScreen.routeName,
      builder: (_, __) => NicknameSetupScreen(),
    ),
    GoRoute(
      path: '/dateRangePicker',
      name: TripDateRangePickerScreen.routeName,
      builder: (_, __) => TripDateRangePickerScreen(),
    ),
    GoRoute(
      path: '/tripDetailScreen/:tripId',
      name: TripDetailScreen.routeName,
      builder: (context, state) {
        final tripId = int.parse(state.pathParameters['tripId']!);
        return TripDetailScreen(tripId: tripId);
      },
    ),
    // 딥링크용 화면
    GoRoute(
      path: '/trip/invite/:tripId',
      name: 'tripInvite',
      builder: (context, state) {
        final tripId = int.tryParse(state.pathParameters['tripId'] ?? '0');
        final tripTitle = state.queryParameters['title'];
        return TripInviteHandler(tripId: tripId, tripTitle: tripTitle);
      },
    ),
    GoRoute(
      path: '/invite/:tripId',
      name: 'tripInviteShortcut',
      builder: (context, state) {
        final tripId = int.tryParse(state.pathParameters['tripId'] ?? '0');
        final tripTitle = state.queryParameters['title'];
        return TripInviteHandler(tripId: tripId, tripTitle: tripTitle);
      },
    ),
    GoRoute(
      path: '/W2mConfirmScreen',
      name: W2MOverlapCalendarScreen.routeName,
      builder: (_, __) => W2MOverlapCalendarScreen(),
    ),
    GoRoute(
      path: '/naverPlaceMapScreen',
      name: NaverPlaceMapScreen.routeName,
      builder: (context, state) {
        // confirmedSchedule을 변경하려면 필요함.
        final dayStr = state.queryParameters['day'];
        final dayId = state.queryParameters['dayId'];
        final day = int.tryParse(dayStr ?? '') ?? 1;
        return NaverPlaceMapScreen(day: day, dayId: dayId);
      },
    ),
    GoRoute(
      path: '/ingTripMap',
      name: IngTripMapScreen.routeName,
      builder:
          (context, state) =>
              IngTripMapScreen(extra: state.extra as Map<String, dynamic>?),
    ),
    GoRoute(
      path: '/endTripMap',
      name: EndTripMapScreen.routeName,
      builder: (_, __) => EndTripMapScreen(),
    ),
    GoRoute(
      path: '/noticeListScreen',
      name: NoticeListScreen.routeName,
      builder: (_, __) => NoticeListScreen(),
    ),
    GoRoute(
      path: '/settlementListScreen',
      name: SettlementListScreen.routeName,
      builder: (_, __) => SettlementListScreen(),
    ),
    GoRoute(
      path: '/settlementCreateScreen',
      name: SettlementCreateScreen.routeName,
      builder: (_, state) {
        final extra = state.extra;
        final settlement = extra is SettlementModel ? extra : null;
        return SettlementCreateScreen(initialSettlement: settlement);
      },
    ),
    GoRoute(
      path: '/settlementDetailScreen/:settlementId',
      name: SettlementDetailScreen.routeName,
      builder: (context, state) {
        final settlementId = int.parse(state.pathParameters['settlementId']!);
        return SettlementDetailScreen(settlementId: settlementId);
      },
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
    final userRecoveryPage = state.location == '/userRecovery';

    // 탈퇴한 사용자 - 복구 페이지로 리다이렉트
    if (user is UserDeleteModel) {
      return userRecoveryPage ? null : '/userRecovery';
    }

    // 유저 정보가 없는데
    // 로그인/회원가입 중이면 그대로 두고
    // 그 외에는 로그인 페이지로 이동
    // 게스트(닉네임 없는 소셜로그인)일 경우 닉네임 페이지로 이동
    if (user is UserModelGuest) {
      return '/nickname';
    }

    if (user is! UserResponseModel) {
      // TODO: 딥링크로 여행 초대 진입한 경우 tripId를 보존하여 로그인 페이지로 리다이렉트
      if (state.matchedLocation.startsWith('/trip/invite/')) {
        final encodedRedirect = Uri.encodeComponent(state.matchedLocation);
        return '/login?redirect=$encodedRedirect';
      }
      return loggingInOrRegister ? null : '/login';
    }

    // UserResponseModel이지만 정상 유저 정보(code==200, data!=null)만 홈으로 이동
    if (user.code == 200 && user.data != null) {
      // 로그인 성공 후 딥링크 redirect 파라미터 확인
      final uri = Uri.parse(state.location);
      final redirect = uri.queryParameters['redirect'];

      if (redirect != null && redirect.isNotEmpty) {
        return Uri.decodeComponent(redirect);
      }

      return loggingInOrRegister || state.location == '/splash' ? '/' : null;
    }

    // 실패 응답(UserResponseModel이지만 code!=200 또는 data==null)
    return loggingInOrRegister ? null : '/login';
  }
}
