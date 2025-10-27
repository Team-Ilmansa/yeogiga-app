import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/component/past_trip_card.dart';
import 'package:yeogiga/schedule/component/hot_schedule_card.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/pending_schedule_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip_list/provider/trip_list_provider.dart';
import 'package:yeogiga/user/component/profile_card.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/user/repository/register_repository.dart';
import 'package:yeogiga/w2m/model/user_w2m_model.dart';
import 'package:yeogiga/w2m/provider/user_w2m_provider.dart';
import 'package:yeogiga/common/route_observer.dart';
import 'package:yeogiga/common/component/confirmation_dialog.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyPageScreen> with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    myPageRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    myPageRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // 마이페이지 복귀 시 데이터 새로고침
    ref.read(allTripListProvider.notifier).fetchAndSetAllTrips();
    super.didPopNext();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(allTripListProvider.notifier).fetchAndSetAllTrips();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userMeProvider);

    return Container(
      color: Color(0xfffafafa),
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 116.h),
                  Text(
                    '${userState is UserResponseModel && userState.data != null ? userState.data!.nickname : '사용자'}님의\n마이페이지',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ProfileCard(), //프로필 카드 부분
                  ///TODO: 아래 즐겨찾기한 사진 리스트 주석은 지우지 말 것
                  // SizedBox(height: 60.h),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   crossAxisAlignment: CrossAxisAlignment.baseline,
                  //   textBaseline: TextBaseline.alphabetic,
                  //   children: [
                  //     Text(
                  //       '즐겨찾기한 사진',
                  //       style: TextStyle(
                  //         fontWeight: FontWeight.w700,
                  //         fontSize: 20.sp,
                  //         height: 1.4,
                  //         letterSpacing: -0.3,
                  //         color: Color(0xff313131),
                  //       ),
                  //     ),
                  //     GestureDetector(
                  //       onTap: () {
                  //         //TODO: 어디로?
                  //       },
                  //       child: Text(
                  //         '더보기',
                  //         style: TextStyle(
                  //           fontSize: 12.sp,
                  //           height: 1.5,
                  //           letterSpacing: -0.3,
                  //           color: Color(0xffc6c6c6),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),

            // SizedBox(height: 12.h),
            // //TODO: 즐겨찾기한 사진 그리드 뷰
            // HotScheduleCardGridList(),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  SizedBox(height: 60.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '전체 여행 보기',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          height: 1.4,
                          letterSpacing: -0.3,
                          color: Color(0xff313131),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          //TODO: 어디로?
                        },
                        child: Text(
                          '더보기',
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.5,
                            letterSpacing: -0.3,
                            color: Color(0xffc6c6c6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),
            //TODO: 지간 여행 전체보기 슬라이드 뷰
            Consumer(
              builder: (context, ref, _) {
                final tripsAsync = ref.watch(allTripListProvider);
                return tripsAsync.when(
                  loading:
                      () => SizedBox(
                        height: 321.h,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                  error:
                      (e, _) => SizedBox(
                        height: 321.h,
                        child: Center(
                          child: Text(
                            '여행 목록을 불러올 수 없습니다.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                  data:
                      (trips) => TripCardList(
                        trips: trips,
                        onTap: (tripId) {
                          GoRouter.of(
                            context,
                          ).push('/tripDetailScreen/$tripId');
                        },
                      ),
                );
              },
            ),
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              height: 12.h,
              color: Color(0xfff0f0f0),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 66.h,
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 13.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '문의하기',
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.4,
                      letterSpacing: -0.3,
                      color: Color(0xff313131),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => ConfirmationDialog(
                    title: '로그아웃',
                    content: '정말 로그아웃 하시겠어요?',
                    cancelText: '취소',
                    confirmText: '로그아웃',
                    confirmColor: const Color(0xFF8287FF),
                  ),
                );

                if (confirmed == true) {
                  ref.read(userMeProvider.notifier).logout();
                }
              },
              child: SizedBox(
                width: double.infinity,
                height: 66.h,
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 13.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 16.sp,
                        height: 1.4,
                        letterSpacing: -0.3,
                        color: Color(0xff313131),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => ConfirmationDialog(
                    title: '회원 탈퇴',
                    content: '정말 탈퇴하시겠어요?\n모든 데이터가 삭제됩니다.',
                    cancelText: '취소',
                    confirmText: '탈퇴하기',
                    confirmColor: const Color(0xFFFF6B6B),
                  ),
                );

                if (confirmed == true) {
                  ref.read(registerRepositoryProvider).deleteUser();
                  ref.read(userMeProvider.notifier).logout();
                }
              },
              child: SizedBox(
                width: double.infinity,
                height: 66.h,
                child: Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 13.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '탈퇴하기',
                      style: TextStyle(
                        fontSize: 16.sp,
                        height: 1.4,
                        letterSpacing: -0.3,
                        color: Color(0xff313131),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}
