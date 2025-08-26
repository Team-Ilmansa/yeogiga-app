import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/main_trip/view/home_screen.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/user/view/my_page.dart';
import 'package:yeogiga/trip/component/create_trip/trip_name_dialog.dart';
import 'package:yeogiga/trip_list/provider/trip_list_provider.dart';
import 'package:yeogiga/main_trip/provider/main_trip_provider.dart';
import 'package:yeogiga/w2m/provider/user_w2m_provider.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/pending_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';

class ScreenWrapper extends ConsumerStatefulWidget {
  static String get routeName => 'screenWrapper';

  const ScreenWrapper({super.key});

  @override
  ConsumerState<ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends ConsumerState<ScreenWrapper> {
  int _selectedIndex = 0;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // ScreenWrapper 진입 시, 로그인/유저정보(mainTripFutureProvider, userMeProvider) 제외 모든 provider refresh
    Future.microtask(() {
      ref.refresh(tripProvider);
      ref.refresh(tripListProvider);
      ref.refresh(userW2mProvider);
      ref.refresh(confirmScheduleProvider);
      ref.refresh(pendingScheduleProvider);
      ref.refresh(completedScheduleProvider);
      ref.refresh(mainTripFutureProvider);
      // 필요시 추가 provider도 여기에!
    });

    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,

      // 중앙 FAB
      floatingActionButton: Transform.translate(
        offset: Offset(0, 16.h), // 아래로 18px 이동
        child: SizedBox(
          width: 71.w,
          height: 71.h,
          child: FloatingActionButton(
            onPressed: () async {
              final nameController = TextEditingController();
              await showDialog(
                context: context,
                barrierDismissible: true,
                builder:
                    (context) => TripNameDialog(
                      nameController: nameController,
                      onConfirm: () async {
                        TripBaseModel trip = await ref
                            .read(tripProvider.notifier)
                            .postTrip(title: nameController.text);
                        //혹시나 해서 실패했을 경우 만듬
                        if (trip is! SettingTripModel) {
                          // 수정: async gap 이후 context 사용 시 mounted 체크 추가
                          if (!mounted) return;
                          GoRouter.of(context).pop(); // 기존 다이얼로그 닫기
                          await showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder:
                                (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: SizedBox(
                                    height: 134.h,
                                    child: Center(
                                      child: Text(
                                        '여행 생성에 실패했어요! ㅠㅠ',
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                          );
                        } else {
                          // 수정: async gap 이후 context 사용 시 mounted 체크 추가
                          if (!mounted) return;
                          Navigator.of(context).pop();
                          GoRouter.of(context).push('/dateRangePicker');
                        }
                      },
                    ),
              );
            },
            backgroundColor: const Color(0xFF8287FF),
            shape: const CircleBorder(),
            elevation: 0,
            child: Icon(Icons.add, size: 36.sp, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 곡선 하단 바
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 1.r)],
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18.r),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(21.r),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: Offset(0, -2.h),
                  blurRadius: 1.r,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: SizedBox(
              height: 77.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabButton(
                    0,
                    'asset/icon/home.svg',
                    '홈',
                    refresh: () => ref.refresh(mainTripFutureProvider),
                  ),
                  SizedBox(width: 60.w), // FAB 공간을 줄임
                  _buildTabButton(
                    1,
                    'asset/icon/user-02.svg',
                    '마이페이지',
                    refresh:
                        () =>
                            ref
                                .read(tripListProvider.notifier)
                                .fetchAndSetTrips(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [HomeScreen(), MyPage()],
      ),
    );
  }

  // 하단 바 버튼 UI
  Widget _buildTabButton(
    int index,
    String assetPath,
    String title, {
    VoidCallback? refresh,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _selectedIndex = index);
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
        );
        if (refresh != null) refresh();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2.h, bottom: 0.0),
            child: SvgPicture.asset(
              assetPath,
              width: 29.w,
              height: 29.h,
              color: isSelected ? const Color(0xFF8287FF) : Colors.grey,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              letterSpacing: -0.1,
              color:
                  isSelected
                      ? const Color(0xFF8287FF)
                      : const Color(0xffc6c6c6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
