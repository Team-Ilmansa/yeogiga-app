import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/schedule/component/hot_schedule_card.dart';
import 'package:yeogiga/schedule/component/schedule_item.dart';
import 'package:yeogiga/common/component/past_trip_card.dart';
import 'package:yeogiga/schedule/component/recommend_card.dart';
import 'package:yeogiga/trip_list/provider/trip_list_provider.dart';
import 'package:yeogiga/common/provider/weather_provider.dart';
import 'package:yeogiga/common/utils/weather_image_util.dart';
import 'package:yeogiga/common/utils/weather_icon_util.dart';
import 'package:yeogiga/main_trip/provider/main_trip_provider.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/common/route_observer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    homeRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    homeRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // 홈 화면 복귀 시 필요한 새로고침 로직 추가
    // 예시: ref.invalidate(mainTripFutureProvider);
    // print('HomeScreen didPopNext');
    super.didPopNext();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(mainTripFutureProvider));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 248, 248, 248),
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer(
                builder: (context, ref, _) {
                  final tripAsync = ref.watch(mainTripFutureProvider);
                  return tripAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (e, _) => const SizedBox.shrink(),
                    data: (trip) {
                      if (trip == null) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HomeAppBar(trip: trip),
                          Transform.translate(
                            offset: Offset(0, -84.h),
                            child: Column(
                              children: [
                                ScheduleItemList(),
                                Container(
                                  height: 36.h,
                                  color: Color(0xfff0f0f0),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 100.h),
              Consumer(
                builder: (context, ref, _) {
                  final userState = ref.watch(userMeProvider);
                  String nickname = '회원';
                  if (userState is UserModel) {
                    nickname = userState.nickname;
                  } else if (userState is UserResponseModel &&
                      userState.data != null) {
                    nickname = userState.data!.nickname;
                  }
                  return SectionTitle("$nickname님께 딱 맞을 것 같은 스팟");
                },
              ),
              RecommendScheduleCardList(),
              SizedBox(height: 90.h),
              SectionTitle("인기급상승 여행스팟"),
              HotScheduleCardGridList(),
              SizedBox(height: 90.h),

              //TODO: 이거 끝난 여행 리스트 불러오기 상태로 변경해야함.
              SectionTitle("지난여행 돌아보기"),
              Consumer(
                builder:
                    (context, ref, _) =>
                        PastTripCardList(trips: ref.watch(tripListProvider)),
              ),
              SizedBox(height: 100.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeAppBar extends ConsumerWidget {
  final dynamic trip;
  const _HomeAppBar({Key? key, required this.trip}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);
    return SizedBox(
      height: 738.h,
      child: weatherAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Stack(children: [Center(child: Text(e.toString()))]),
        data: (weather) {
          final weatherMain =
              (weather['weather']?[0]?['main'] ?? 'Clear').toString();
          final temp = weather['main']?['temp']?.toStringAsFixed(1) ?? '--';
          final weatherImage = getWeatherImageAsset(weatherMain);
          return Stack(
            children: [
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(1, 255, 255, 255), // 거의 투명한 흰색
                      Color.fromARGB(200, 255, 255, 255), // 55% 흰색
                    ],
                    stops: [0.8, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcOver,
                child: Image.asset(
                  weatherImage,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.topCenter,
                ),
              ),

              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 50.h),
                    AppBarTop(
                      weatherMain: weatherMain,
                      temp: temp,
                      isWhiteTheme:
                          weatherMain.toLowerCase() == 'rain' ||
                          weatherMain.toLowerCase() == 'thunderstorm',
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 48.h,
                        left: 48.w,
                        right: 48.w,
                      ),
                      child: Builder(
                        builder: (context) {
                          final now = DateTime.now();
                          final start = trip.staredAt;
                          final title = trip.title;
                          final diff = start.difference(now).inDays;
                          if (now.isBefore(start)) {
                            // 여행 시작 전
                            return Text(
                              '오늘은\n$title까지 ${diff.abs() + 1}일 남았어요~',
                              style: TextStyle(
                                color: Color(0xff313131),
                                fontSize: 84.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                height: 1.4,
                              ),
                            );
                          } else {
                            // 여행 진행 중 or 이후
                            final day = now.difference(start).inDays + 1;
                            return Text(
                              '오늘은\n$title ${day}일차에요!',
                              style: TextStyle(
                                color: Color(0xff313131),
                                fontSize: 84.sp,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                                height: 1.4,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Positioned(child: SizedBox(height: 20)),
            ],
          ); // End of Stack in data
        }, // End of data
      ), // End of weatherAsync.when
    ); // End of SizedBox
  }
}

class AppBarTop extends StatelessWidget {
  const AppBarTop({
    super.key,
    required this.weatherMain,
    required this.temp,
    required this.isWhiteTheme,
  });

  final String weatherMain;
  final dynamic temp;
  final bool isWhiteTheme;

  @override
  Widget build(BuildContext context) {
    final iconColor = isWhiteTheme ? Colors.white : const Color(0xff313131);
    final tempColor = isWhiteTheme ? Colors.white : Colors.black.withAlpha(204);
    return Padding(
      padding: EdgeInsets.only(bottom: 48.h, left: 48.w, right: 48.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(getWeatherIcon(weatherMain), size: 72.sp, color: iconColor),
              SizedBox(width: 10.w),
              Text(
                '$temp°',
                style: TextStyle(
                  fontSize: 54.sp,
                  color: tempColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(Icons.map_outlined, color: iconColor),
              SizedBox(width: 36.w),
              Icon(Icons.notifications_none, color: iconColor),
            ],
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 36.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}
