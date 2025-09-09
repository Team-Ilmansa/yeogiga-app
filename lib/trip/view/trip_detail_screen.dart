import 'package:flutter/material.dart' hide ExpansionPanel;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:yeogiga/common/provider/selection_mode_provider.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/pending_schedule_provider.dart';
import 'package:yeogiga/trip/component/detail_screen/top_panel.dart';
import 'package:yeogiga/trip/component/detail_screen/bottom_button_states.dart';
import 'package:yeogiga/trip/component/detail_screen/notice_panel.dart';
import 'package:yeogiga/trip/component/detail_screen/gallery/gallery_tab.dart';
import 'package:yeogiga/trip/component/detail_screen/schedule_dashboard/schedule_dashboard_tab.dart';
import 'package:yeogiga/trip/component/trip_more_menu_sheet.dart';
import 'package:yeogiga/trip_image/provider/matched_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/pending_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/unmatched_trip_image_provider.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'tripDetailScreen';
  const TripDetailScreen({super.key});

  @override
  ConsumerState<TripDetailScreen> createState() => TripDetailScreenState();
}

class TripDetailScreenState extends ConsumerState<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  // static 메서드로 분리
  // TODO: 존나 중요

  int _selectedDayIndex = 0;

  int bottomAppBarState = 1;
  late TabController _tabController;

  Map<String, List<String>> matchedOrUnmatchedPayload = {};
  Map<String, List<String>> pendingPayload = {};

  void onSelectionPayloadChanged({
    required Map<String, List<String>> matchedOrUnmatched,
    required Map<String, List<String>> pending,
  }) {
    setState(() {
      matchedOrUnmatchedPayload = matchedOrUnmatched;
      pendingPayload = pending;
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 탭 컨트롤러 리스너
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabController.index != 1 && _tabController.index != 2) {
        ref.read(selectionModeProvider.notifier).state = false;
      }
      setState(() {
        if (_tabController.index == 0) {
          bottomAppBarState = 1; // 일정 대시보드
        } else if (_tabController.index == 1) {
          bottomAppBarState = ref.watch(selectionModeProvider) ? 3 : 2; // 갤러리
        } else if (_tabController.index == 2) {
          bottomAppBarState = 4; // 즐겨찾는 사진 (새로운 상태)
        }
      });
    });
  }

  bool _initialized = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;

      //앱을 시작할때도 호출
      WidgetsBinding.instance.addPostFrameCallback((_) {
        refreshAll();
      });
    }
  }

  // 날짜 개수 뽑기
  List<String> getDaysForTrip(TripBaseModel? trip) {
    if (trip is TripModel && trip.startedAt != null && trip.endedAt != null) {
      final start = DateTime.parse(trip.startedAt!.substring(0, 10));
      final end = DateTime.parse(trip.endedAt!.substring(0, 10));
      final dayCount = end.difference(start).inDays + 1;
      return List.generate(dayCount, (index) => 'Day ${index + 1}');
    }
    return [];
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool isRefreshing = false;

  // 갤러리탭 리프레쉬
  Future<void> refreshAll() async {
    setState(() {
      isRefreshing = true;
    });
    final trip = ref.read(tripProvider).valueOrNull;
    final isCompleted = trip is CompletedTripModel;
    int tripId = (trip is TripModel) ? trip.tripId : 0;
    // invalidate 일정/이미지 provider
    ref.invalidate(pendingDayTripImagesProvider);
    ref.invalidate(unmatchedTripImagesProvider);
    ref.invalidate(matchedTripImagesProvider);
    // 일정 fetchAll
    if (isCompleted) {
      await ref.read(completedScheduleProvider.notifier).fetch(tripId);
      final completed = ref.read(completedScheduleProvider).valueOrNull;
      if (completed != null && completed.data.isNotEmpty) {
        final pendingDayPlaceInfos =
            completed.data
                .map(
                  (dayPlace) => PendingTripDayPlaceInfo(
                    day: dayPlace.day,
                    tripDayPlaceId: dayPlace.id,
                  ),
                )
                .toList();
        final unmatchedDayPlaceInfos =
            completed.data
                .map(
                  (dayPlace) => UnMatchedTripDayPlaceInfo(
                    day: dayPlace.day,
                    tripDayPlaceId: dayPlace.id,
                  ),
                )
                .toList();
        final matchedDayPlaceInfos =
            completed.data
                .map(
                  (dayPlace) => MatchedDayPlaceInfo(
                    day: dayPlace.day,
                    tripDayPlaceId: dayPlace.id,
                    placeIds: dayPlace.places.map((e) => e.id).toList(),
                  ),
                )
                .toList();
        await ref
            .read(pendingDayTripImagesProvider.notifier)
            .fetchAll(tripId, pendingDayPlaceInfos);
        await ref
            .read(unmatchedTripImagesProvider.notifier)
            .fetchAll(tripId, unmatchedDayPlaceInfos);
        await ref
            .read(matchedTripImagesProvider.notifier)
            .fetchAll(tripId, matchedDayPlaceInfos);
      }
    } else {
      await ref.read(confirmScheduleProvider.notifier).fetchAll(tripId);
      final confirmed = ref.read(confirmScheduleProvider).valueOrNull;
      if (confirmed != null && confirmed.schedules.isNotEmpty) {
        final matchedDayPlaceInfos =
            confirmed.schedules
                .map(
                  (schedule) => MatchedDayPlaceInfo(
                    day: schedule.day,
                    tripDayPlaceId: schedule.id,
                    placeIds: schedule.places.map((e) => e.id).toList(),
                  ),
                )
                .toList();
        final unmatchedDayPlaceInfos =
            confirmed.schedules
                .map(
                  (schedule) => UnMatchedTripDayPlaceInfo(
                    day: schedule.day,
                    tripDayPlaceId: schedule.id,
                  ),
                )
                .toList();
        final pendingDayPlaceInfos =
            confirmed.schedules
                .map(
                  (schedule) => PendingTripDayPlaceInfo(
                    day: schedule.day,
                    tripDayPlaceId: schedule.id,
                  ),
                )
                .toList();
        await ref
            .read(matchedTripImagesProvider.notifier)
            .fetchAll(tripId, matchedDayPlaceInfos);
        await ref
            .read(unmatchedTripImagesProvider.notifier)
            .fetchAll(tripId, unmatchedDayPlaceInfos);
        await ref
            .read(pendingDayTripImagesProvider.notifier)
            .fetchAll(tripId, pendingDayPlaceInfos);
      }
    }
    setState(() {
      isRefreshing = false;
      ref.read(selectionModeProvider.notifier).state = false;
    });
  }

  //대쉬보드탭 리프레쉬
  Future<void> refreshSchedule() async {
    final tripState = ref.read(tripProvider).valueOrNull;
    if (tripState is SettingTripModel &&
        tripState.startedAt != null &&
        tripState.endedAt != null) {
      // Pending
      final dynamicDays = getDaysForTrip(tripState);
      final tripId = tripState.tripId;
      final days = List.generate(dynamicDays.length, (i) => i + 1);
      await ref
          .read(pendingScheduleProvider.notifier)
          .fetchAll(tripId.toString(), days);
    }
    if (tripState is TripModel) {
      // Confirmed
      await ref
          .read(confirmScheduleProvider.notifier)
          .fetchAll(tripState.tripId);
      // Completed
      await ref
          .read(completedScheduleProvider.notifier)
          .fetch(tripState.tripId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectionMode = ref.watch(selectionModeProvider);
    final tripState = ref.watch(tripProvider).valueOrNull;
    final userMe = ref.watch(userMeProvider);

    if (_tabController.index == 0) {
      bottomAppBarState = 1; // 일정 대시보드
    } else if (_tabController.index == 1) {
      bottomAppBarState = selectionMode ? 3 : 2; // 갤러리
    } else if (_tabController.index == 2) {
      bottomAppBarState = 4; // 즐겨찾는 사진
    }

    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 36.h,
        backgroundColor: Color(0xfffafafa),
        shadowColor: Colors.transparent, // 그림자도 제거
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 17.sp),
              onPressed: () => Navigator.pop(context),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                //TODO: IN_PROGRESS 일때만 보여주기
                if (tripState is InProgressTripModel)
                  IconButton(
                    icon: Icon(Icons.map_outlined, color: Colors.black),
                    onPressed: () async {
                      ref.invalidate(
                        pendingScheduleProvider,
                      ); // ← TODO: 진입 전 초기화 (앱 박살나는거 방지)
                      ref.invalidate(
                        confirmScheduleProvider,
                      ); // ← TODO: 진입 전 초기화 (앱 박살나는거 방지)
                      ref.invalidate(
                        completedScheduleProvider,
                      ); // ← TODO: 진입 전 초기화 (앱 박살나는거 방지)
                      await ref
                          .read(confirmScheduleProvider.notifier)
                          .fetchAll(tripState.tripId);
                      //TODO: 지도로 이동
                      // 수정: async gap 이후 context 사용 시 mounted 체크 추가
                      if (!mounted) return;
                      GoRouter.of(context).push('/ingTripMap');
                    },
                  ),
                // TODO: 메뉴 보여주기
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {
                    bool isLeader = false;
                    String? myNickname;
                    dynamic leader;
                    if (tripState is TripModel) {
                      final leaderId = tripState.leaderId;
                      final leaderList = tripState.members.where(
                        (m) => m.userId == leaderId,
                      );
                      leader = leaderList.isNotEmpty ? leaderList.first : null;
                    }
                    if (userMe is UserResponseModel) {
                      myNickname = userMe.data?.nickname;
                    }
                    if (leader != null &&
                        myNickname != null &&
                        leader.nickname == myNickname) {
                      isLeader = true;
                    }
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: false,
                      backgroundColor: Colors.transparent,
                      barrierColor: Colors.black.withOpacity(0.7),
                      builder: (context) {
                        return isLeader
                            ? const TripMoreMenuSheetLeader()
                            : const TripMoreMenuSheetMember();
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _getBottomNavigationBar(
        /// TODO: 하단바 버튼으로
        /// TODO: 상태, 선택한 날짜, 삭제할 리스트들 전부 넘겨야함.
        ref,
        bottomAppBarState,
        _selectedDayIndex,
        matchedOrUnmatchedPayload,
        pendingPayload,
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                // 탑 패널
                SliverToBoxAdapter(child: TopPanel()),
                // TODO: 알림이 있으면!
                // if (true) SliverToBoxAdapter(child: NoticePanel()),
                // 탭바
                SliverPersistentHeader(
                  pinned: true,
                  delegate: TabBarHeaderDelegate(
                    child: SizedBox(
                      height: 32.h,
                      child: Container(
                        color: Color(0xfffafafa),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFF8287FF),
                                width: 2.w,
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
                                  fontSize: 14.sp,
                                  letterSpacing: -0.1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                '갤러리',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  letterSpacing: -0.1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                '즐겨찾는 사진',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  letterSpacing: -0.1,
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
            physics: const NeverScrollableScrollPhysics(), // 가로 스와이프(스크롤) 전환 막기
            children: [
              LiquidPullToRefresh(
                onRefresh: refreshSchedule,
                animSpeedFactor: 7.0,
                color: Color(0xff8287ff), // 물방울 색상 (원하는 색상으로)
                backgroundColor: Color(0xfff0f0f0), // 배경색
                showChildOpacityTransition: false, // child 투명도 트랜지션 사용 여부
                child: ScheduleDashboardTab(),
              ),
              LiquidPullToRefresh(
                onRefresh: refreshAll,
                animSpeedFactor: 7.0,
                color: Color(0xff8287ff), // 물방울 색상 (원하는 색상으로)
                backgroundColor: Color(0xfff0f0f0), // 배경색
                showChildOpacityTransition: false, // child 투명도 트랜지션 사용 여부
                child: GalleryTab(
                  sliverMode: true,
                  selectedDayIndex: _selectedDayIndex,
                  onDayIndexChanged: (index) {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                  onSelectionPayloadChanged: onSelectionPayloadChanged,
                ),
              ),
              // 즐겨찾는 사진 탭
              Center(
                child: Text(
                  '즐겨찾는 사진 탭\n구현 예정',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
class BottomAppBarLayout extends ConsumerWidget {
  final Widget child;
  const BottomAppBarLayout({required this.child, super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(21.r),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, -2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(11.w, 11.h, 11.w, 22.h),
        child: child,
      ),
    );
  }
}

Widget? _getBottomNavigationBar(
  WidgetRef ref,
  int bottomAppBarState,
  int selectedDayIndex,
  Map<String, List<String>> matchedOrUnmatchedPayload,
  Map<String, List<String>> pendingPayload,
) {
  final tripState = ref.watch(tripProvider).valueOrNull;
  final userMe = ref.watch(userMeProvider);
  // 여행 상태가 SETTING이고 날짜 미지정이면 '여행 날짜 확정하기' 버튼
  if (tripState is SettingTripModel) {
    final settingTrip = tripState;
    final startedAt = settingTrip.startedAt;
    final endedAt = settingTrip.endedAt;
    String? myNickname;
    if (userMe is UserResponseModel) {
      myNickname = userMe.data?.nickname;
    }
    final leaderId = settingTrip.leaderId;
    final leaderList = settingTrip.members.where((m) => m.userId == leaderId);
    final leader = leaderList.isNotEmpty ? leaderList.first : null;
    // 리더만 버튼 노출
    if (leader != null && myNickname != null && leader.nickname == myNickname) {
      if (startedAt == null || endedAt == null) {
        // 날짜 미지정: 여행 날짜 확정하기
        return const BottomAppBarLayout(child: ConfirmCalendarState());
      } else {
        // 날짜 지정: 여행 일정 확정하기
        final tripId = settingTrip.tripId;
        int lastDay = 1;
        if (startedAt != null && endedAt != null) {
          try {
            final start = DateTime.parse(startedAt.toString().substring(0, 10));
            final end = DateTime.parse(endedAt.toString().substring(0, 10));
            lastDay = end.difference(start).inDays + 1;
            if (lastDay < 1) lastDay = 1;
          } catch (e) {
            lastDay = 1;
          }
        }
        return BottomAppBarLayout(
          child: ConfirmScheduleState(tripId: tripId, lastDay: lastDay),
        );
      }
    } else {
      return null;
    }
  } else if (bottomAppBarState == 1) {
    return const BottomAppBarLayout(child: AddNoticeState());
  } else if (bottomAppBarState == 2 || bottomAppBarState == 3) {
    // 갤러리 탭 하단바는 inprogress/completed 상태에서만 노출
    if (tripState is InProgressTripModel || tripState is CompletedTripModel) {
      if (bottomAppBarState == 2) {
        return BottomAppBarLayout(
          child: AddPictureState(selectedDayIndex: selectedDayIndex),
        );
      } else {
        return BottomAppBarLayout(
          child: PictureOptionState(
            selectedDayIndex: selectedDayIndex,
            matchedOrUnmatchedPayload: matchedOrUnmatchedPayload,
            pendingPayload: pendingPayload,
          ),
        );
      }
    } else {
      // 그 외 상태에서는 하단바 숨김
      return null;
    }
  } else if (bottomAppBarState == 4) {
    // 즐겨찾는 사진 탭 - 일단 하단바 숨김 (추후 구현)
    return null;
  }
  return null;
}

// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

// SliverPersistentHeaderDelegate for the pinned TabBar
class TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  TabBarHeaderDelegate({required this.child});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(color: Colors.white, child: child);
  }

  @override
  double get maxExtent => 32.h; // TabBar의 실제 높이와 동일하게!
  @override
  double get minExtent => 32.h;
  @override
  bool shouldRebuild(covariant TabBarHeaderDelegate oldDelegate) => false;
}
