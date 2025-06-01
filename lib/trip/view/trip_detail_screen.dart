import 'package:flutter/material.dart' hide ExpansionPanel;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:yeogiga/trip/component/detail_screen/top_panel.dart';
import 'package:yeogiga/trip/component/detail_screen/bottom_button_states.dart';
import 'package:yeogiga/trip/component/detail_screen/notice_panel.dart';
import 'package:yeogiga/trip/component/detail_screen/gallery/gallery_tab.dart';
import 'package:yeogiga/trip/component/detail_screen/schedule_dashboard/schedule_dashboard_tab.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'tripDetailScreen';
  const TripDetailScreen({super.key});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  int bottomAppBarState = 1;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 탭 컨트롤러 리스너
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        if (_tabController.index == 0) {
          bottomAppBarState = 1;
        } else if (_tabController.index == 1) {
          // selectionMode는 onSelectionModeChanged 콜백에서만 관리
          bottomAppBarState = 2;
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripProvider);
    final userMe = ref.watch(userMeProvider);

    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 120.h,
        backgroundColor: Color(0xfffafafa),
        shadowColor: Colors.transparent, // 그림자도 제거
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                //TODO: IN_PROGRESS 일때만 보여주기
                if (tripState is InProgressTripModel)
                  IconButton(
                    icon: Icon(Icons.map_outlined, color: Colors.black),
                    onPressed: () {
                      //TODO: 지도로 이동
                    },
                  ),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {
                    //TODO: 메뉴 펼치기
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: getBottomNavigationBar(tripState, userMe, bottomAppBarState),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                // 탑 패널
                SliverToBoxAdapter(child: TopPanel()),
                // TODO: 알림이 있으면!
                if (true) SliverToBoxAdapter(child: NoticePanel()),
                // 탭바
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarHeaderDelegate(
                    child: SizedBox(
                      height: 108.h,
                      child: Container(
                        color: Color(0xfffafafa),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFF8287FF),
                                width: 6.w,
                              ),
                            ),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Color(0xFF8287FF),
                          unselectedLabelColor: Colors.grey,
                          tabs: [
                            Tab(
                              child: Text(
                                '일정 대시보드',
                                style: TextStyle(
                                  fontSize: 48.sp,
                                  letterSpacing: -0.3,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                '갤러리',
                                style: TextStyle(
                                  fontSize: 48.sp,
                                  letterSpacing: -0.3,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
          // 탭바 뷰
          body: TabBarView(
            controller: _tabController,
            children: [
              ScheduleDashboardTab(),
              GalleryTab(
                onSelectionModeChanged: (bool selectionMode) {
                  setState(() {
                    bottomAppBarState = selectionMode ? 3 : 2;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 하단 바 생성 함수
/// 공통 하단 바 레이아웃 컴포넌트
class BottomAppBarLayout extends StatelessWidget {
  final Widget child;
  const BottomAppBarLayout({required this.child, super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(72.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, -2),
            blurRadius: 1,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(36.w, 36.h, 36.w, 75.h),
        child: child,
      ),
    );
  }
}

Widget? getBottomNavigationBar(tripState, userMe, int bottomAppBarState) {
  // 여행 상태가 SETTING이고 날짜 미지정이면 '여행 날짜 확정하기' 버튼
  if (tripState is SettingTripModel &&
      ((tripState as SettingTripModel).startedAt == null ||
          (tripState as SettingTripModel).endedAt == null)) {
    String? myNickname;
    if (userMe is UserResponseModel) {
      myNickname = userMe.data?.nickname;
    }
    final leaderId = tripState.leaderId;
    final leaderList = tripState.members.where(
      (m) => m.userId == leaderId,
    );
    final leader = leaderList.isNotEmpty ? leaderList.first : null;
    if (leader != null &&
        myNickname != null &&
        leader.nickname == myNickname) {
      return const BottomAppBarLayout(child: ConfirmCalendarState());
    }
    return null;
  } else if (bottomAppBarState == 1) {
    return const BottomAppBarLayout(child: AddScheduleState());
  } else if (bottomAppBarState == 2) {
    return const BottomAppBarLayout(child: AddPictureState());
  } else if (bottomAppBarState == 3) {
    return const BottomAppBarLayout(child: PictureOptionState());
  } else {
    return null;
  }
}


// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

// SliverPersistentHeaderDelegate for the pinned TabBar
class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _TabBarHeaderDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(color: Colors.white, child: child);
  }

  @override
  double get maxExtent => 108.h; // TabBar의 실제 높이와 동일하게!
  @override
  double get minExtent => 108.h;
  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) => false;
}
