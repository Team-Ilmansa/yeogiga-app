import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/component/setting_trip_card.dart';
import 'package:yeogiga/schedule/component/hot_schedule_card.dart';
import 'package:yeogiga/schedule/component/schedule_item.dart';
import 'package:yeogiga/common/component/past_trip_card.dart';
import 'package:yeogiga/schedule/component/recommend_card.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/pending_schedule_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip_list/provider/trip_list_provider.dart';
import 'package:yeogiga/common/provider/weather_provider.dart';
import 'package:yeogiga/common/utils/weather_image_util.dart';
import 'package:yeogiga/common/utils/weather_icon_util.dart';
import 'package:yeogiga/main_trip/provider/main_trip_provider.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/common/route_observer.dart';
import 'package:yeogiga/w2m/model/user_w2m_model.dart';
import 'package:yeogiga/w2m/provider/user_w2m_provider.dart';

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
    // 홈 화면 복귀 시 데이터 새로고침
    ref.read(mainTripFutureProvider);
    ref.read(pastTripListProvider.notifier).fetchAndSetPastTrips();
    ref.read(settingTripListProvider.notifier).fetchAndSetSettingTrips();
    super.didPopNext();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(mainTripFutureProvider);
      ref.read(pastTripListProvider.notifier).fetchAndSetPastTrips();
      ref.read(settingTripListProvider.notifier).fetchAndSetSettingTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfffafafa),
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
                      if (trip == null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _HomeAppBar(trip: trip),
                            SizedBox(height: 62.h),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _HomeAppBar(trip: trip),
                          Transform.translate(
                            offset: Offset(0, -40.h),
                            child: ScheduleItemList(),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              Transform.translate(
                offset: Offset(0, -62.h), // 40 + 22 해서 62임.
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer(
                      builder: (context, ref, _) {
                        final settingTrips = ref.watch(settingTripListProvider);
                        if (settingTrips.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.fromLTRB(14.w, 0, 0, 12.h),
                              child: Text(
                                '${settingTrips.length}개의 준비중인 여행',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20.sp,
                                  height: 1.4,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            SettingTripCardList(
                              trips: settingTrips,
                              onTap: (tripId) async {
                                ref.invalidate(
                                  tripProvider,
                                ); // ← TODO: 진입 전 초기화 (앱 박살나는거 방지)
                                await ref
                                    .read(tripProvider.notifier)
                                    .getTrip(tripId: tripId);
                                final tripState =
                                    ref.read(tripProvider).valueOrNull;
                                final userW2mState = ref.read(userW2mProvider);
                                if (context.mounted) {
                                  if (tripState is SettingTripModel &&
                                      userW2mState is NoUserW2mModel) {
                                    GoRouter.of(
                                      context,
                                    ).push('/dateRangePicker');
                                  } else {
                                    GoRouter.of(
                                      context,
                                    ).push('/tripDetailScreen');
                                  }
                                }
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 27.h),
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
                    SizedBox(height: 27.h),
                    SectionTitle("인기급상승 여행스팟"),
                    HotScheduleCardGridList(),
                    SizedBox(height: 27.h),

                    //TODO: 이거 끝난 여행 리스트 불러오기 상태로 변경해야함.
                    SectionTitle("지난여행 돌아보기"),
                    Consumer(
                      builder:
                          (context, ref, _) => PastTripCardList(
                            trips: ref.watch(pastTripListProvider),
                          ),
                    ),
                  ],
                ),
              ),
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
    final userMe = ref.read(userMeProvider);
    return SizedBox(
      height: 238.h,
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
                      Color.fromARGB(1, 248, 248, 248), // 거의 투명한 흰색
                      Color.fromARGB(255, 248, 248, 248), // 55% 흰색
                    ],
                    stops: [0.7, 1],
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
                    SizedBox(height: 15.h),
                    AppBarTop(
                      trip: trip,
                      weatherMain: weatherMain,
                      temp: temp,
                      isWhiteTheme:
                          weatherMain.toLowerCase() == 'rain' ||
                          weatherMain.toLowerCase() == 'thunderstorm',
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        top: 14.h,
                        left: 14.w,
                        right: 14.w,
                      ),
                      child: Builder(
                        builder: (context) {
                          if (trip != null) {
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
                                  fontSize: 25.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.1,
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
                                  fontSize: 25.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.1,
                                  height: 1.4,
                                ),
                              );
                            }
                          } else {
                            if (userMe is UserResponseModel) {
                              return Text(
                                '${userMe.data!.nickname}님,\n여행 계획 있으신가요?',
                                style: TextStyle(
                                  color: Color(0xff313131),
                                  fontSize: 25.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.1,
                                  height: 1.4,
                                ),
                              );
                            }
                            return Container();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Positioned(child: SizedBox(height: 6)),
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
    required this.trip,
  });

  final dynamic trip;
  final String weatherMain;
  final dynamic temp;
  final bool isWhiteTheme;

  @override
  Widget build(BuildContext context) {
    final iconColor = isWhiteTheme ? Colors.white : const Color(0xff313131);
    final tempColor = isWhiteTheme ? Colors.white : Colors.black.withAlpha(204);
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h, left: 14.w, right: 14.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(getWeatherIcon(weatherMain), size: 24.sp, color: iconColor),
              SizedBox(width: 3.w),
              Text(
                '$temp°',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: tempColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Consumer(
                builder: (context, ref, _) {
                  if (trip != null) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(7.r),
                      onTap: () async {
                        final mainTripAsync = ref.read(mainTripFutureProvider);
                        final mainTrip =
                            mainTripAsync is AsyncData
                                ? mainTripAsync.value
                                : null;
                        final tripId = mainTrip?.tripId;
                        if (tripId != null) {
                          ref.invalidate(
                            tripProvider,
                          ); // ← TODO: 진입 전 초기화 (앱 박살나는거 방지)
                          ref.invalidate(
                            confirmScheduleProvider,
                          ); // ← TODO: 진입 전 초기화 (앱 박살나는거 방지)
                          await ref
                              .read(tripProvider.notifier)
                              .getTrip(tripId: tripId);
                          await ref
                              .read(confirmScheduleProvider.notifier)
                              .fetchAll(tripId);
                          if (context.mounted) {
                            GoRouter.of(context).push('/ingTripMap');
                          }
                        }
                      },
                      child: Icon(
                        Icons.map_outlined,
                        color: iconColor,
                        size: 24.sp,
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              SizedBox(width: 11.w),
              Icon(Icons.notifications_none, color: iconColor, size: 24.sp),
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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}
