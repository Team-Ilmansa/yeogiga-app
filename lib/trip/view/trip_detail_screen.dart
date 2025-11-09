import 'dart:async';
import 'package:flutter/material.dart' hide ExpansionPanel;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:yeogiga/common/provider/util_state_provider.dart';
import 'package:yeogiga/common/utils/system_ui_helper.dart';
import 'package:yeogiga/notice/provider/notice_provider.dart';
import 'package:yeogiga/notice/provider/ping_provider.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/pending_schedule_provider.dart';
import 'package:yeogiga/trip/component/detail_screen/top_panel.dart';
import 'package:yeogiga/trip/component/detail_screen/bottom_button_states.dart';
import 'package:yeogiga/notice/component/notice_panel.dart';
import 'package:yeogiga/trip/component/detail_screen/gallery/gallery_tab.dart';
import 'package:yeogiga/trip/component/detail_screen/favorite_gallery/favorite_gallery_tab.dart';
import 'package:yeogiga/trip/component/detail_screen/schedule_dashboard/schedule_dashboard_tab.dart';
import 'package:yeogiga/trip/component/trip_more_menu_sheet.dart';
import 'package:yeogiga/trip_image/provider/matched_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/pending_trip_image_provider.dart';
import 'package:yeogiga/trip_image/provider/unmatched_trip_image_provider.dart';
import 'package:yeogiga/trip/utils/gallery_refresh_helper.dart';
import 'package:yeogiga/trip/provider/gallery_selection_provider.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/common/route_observer.dart';
import 'package:yeogiga/common/component/tab_bar_header_delegate.dart';
import 'package:yeogiga/common/component/bottom_app_bar_layout.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  final int tripId;
  static String get routeName => 'tripDetailScreen';
  const TripDetailScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailScreen> createState() => TripDetailScreenState();
}

class TripDetailScreenState extends ConsumerState<TripDetailScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  // static 메서드로 분리
  // TODO: 존나 중요

  int _selectedDayIndex = 0;

  int bottomAppBarState = 1;
  late TabController _tabController;

  Timer? _noticeFetchDebounce;
  // Trip 정보가 완전히 로드된 뒤에만 일정 데이터를 다시 불러오기 위해 TripProvider를 구독한다.
  ProviderSubscription<AsyncValue<TripBaseModel?>>? _tripSubscription;
  int? _lastRefreshedTripId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 탭 컨트롤러 리스너
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      if (_tabController.index != 1 && _tabController.index != 2) {
        // 갤러리/즐겨찾는 사진 탭이 아닐 때 selection 모드 해제
        ref.read(selectionModeProvider.notifier).state = false;
        // ✅ selection provider도 clear
        ref.read(gallerySelectionProvider.notifier).clear();
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

      // RouteObserver 등록
      tripDetailRouteObserver.subscribe(this, ModalRoute.of(context)!);

      //앱을 시작할때도 호출
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // Deeplink 진입 대비: TripProvider 체크 후 필요시에만 fetch
        final current = ref.read(tripProvider).valueOrNull;
        if (current == null ||
            (current is TripModel && current.tripId != widget.tripId)) {
          _lastRefreshedTripId = null;
          ref.read(tripProvider.notifier).getTrip(tripId: widget.tripId);
        }

        // 공지 및 핑 fetch
        ref
            .read(noticeListProvider.notifier)
            .fetchNoticeList(tripId: widget.tripId);
        ref.read(pingProvider.notifier).fetchPing(tripId: widget.tripId);

        _tripSubscription ??= ref.listenManual<AsyncValue<TripBaseModel?>>(
          tripProvider,
          (previous, next) {
            if (next.isLoading) {
              // Trip이 갱신되는 동안에는 이후 완료 시점에 다시 새로고침할 수 있도록 초기화한다.
              _lastRefreshedTripId = null;
              return;
            }

            final tripValue = next.valueOrNull;
            if (tripValue is TripModel && tripValue.tripId == widget.tripId) {
              if (_lastRefreshedTripId != tripValue.tripId) {
                _lastRefreshedTripId = tripValue.tripId;
                // Trip 데이터가 준비된 뒤 다음 프레임에서 일정들을 불러온다.
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  refreshAll();
                });
              }
            }
          },
          fireImmediately: true,
        );
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _noticeFetchDebounce?.cancel();
    tripDetailRouteObserver.unsubscribe(this);
    // TripProvider 구독 해제
    _tripSubscription?.close();
    super.dispose();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    // 다른 화면에서 돌아올 때 pingSelectionMode 초기화
    ref.read(pingSelectionModeProvider.notifier).state = false;

    // Debounce를 사용한 공지 및 핑 fetch
    _noticeFetchDebounce?.cancel();
    _noticeFetchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      ref
          .read(noticeListProvider.notifier)
          .fetchNoticeList(tripId: widget.tripId);
      ref.read(pingProvider.notifier).fetchPing(tripId: widget.tripId);
    });
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

  bool isRefreshing = false;

  // 갤러리탭 리프레쉬
  Future<void> refreshAll() async {
    print('[TripDetailScreen refreshAll] 시작');
    if (!mounted) {
      return;
    }

    setState(() {
      isRefreshing = true;
    });
    await GalleryRefreshHelper.refreshAll(ref);
    if (mounted) {
      setState(() {
        isRefreshing = false;
        ref.read(selectionModeProvider.notifier).state = false;
      });
    }
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

    // 리더 권한 확인 로직 (통합)
    bool isLeader = false;
    if (tripState is TripModel &&
        userMe is UserResponseModel &&
        userMe.data != null) {
      final leaderId = tripState.leaderId;
      final myMember = tripState.members.firstWhere(
        (member) => member.nickname == userMe.data!.nickname,
        orElse: () => TripMember(userId: -1, nickname: '', imageUrl: null),
      );
      isLeader = myMember.userId == leaderId;
    }

    if (_tabController.index == 0) {
      bottomAppBarState = 1; // 일정 대시보드
    } else if (_tabController.index == 1) {
      bottomAppBarState = selectionMode ? 3 : 2; // 갤러리
    } else if (_tabController.index == 2) {
      bottomAppBarState = 4; // 즐겨찾는 사진
    }

    return SafeArea(
      top: false,
      bottom: shouldUseSafeAreaBottom(context),
      child: Scaffold(
        backgroundColor: Color(0xfffafafa),
        appBar: AppBar(
          scrolledUnderElevation: 0,
          toolbarHeight: 48.h,
          backgroundColor: Color(0xfffafafa),
          shadowColor: Colors.transparent, // 그림자도 제거
          foregroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: GestureDetector(
              onTap: () {
                final navigator = Navigator.of(context);
                if (navigator.canPop()) {
                  navigator.pop();
                } else {
                  GoRouter.of(context).go('/');
                }
              },
              child: Icon(Icons.arrow_back_ios_new, size: 16.sp),
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (tripState is TripModel &&
                    tripState.startedAt != null &&
                    tripState.endedAt != null)
                  Row(
                    children: [
                      GestureDetector(
                        child: SvgPicture.asset('asset/icon/settlement.svg'),
                        onTap: () async {
                          // TODO: 이떄 settlement 초기화 한번 해야할 듯?
                          if (!mounted) return;
                          GoRouter.of(context).push('/settlementListScreen');
                        },
                      ),
                      SizedBox(width: 16.w),
                    ],
                  ),
                //TODO: IN_PROGRESS 일때만 보여주기
                if (tripState is InProgressTripModel)
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
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
                        child: Icon(Icons.map_outlined, color: Colors.black),
                      ),
                      SizedBox(width: 14.w),
                    ],
                  ),
                // TODO: 메뉴 보여주기
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: false,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      barrierColor: Colors.black.withOpacity(0.5),
                      builder: (context) {
                        return isLeader
                            ? const TripMoreMenuSheetLeader()
                            : const TripMoreMenuSheetMember();
                      },
                    );
                  },
                  child: Icon(Icons.more_vert, color: Colors.black),
                ),
                SizedBox(width: 14.w),
              ],
            ),
          ],
        ),
        bottomNavigationBar: _getBottomNavigationBar(
          ref,
          bottomAppBarState,
          _selectedDayIndex,
          isLeader,
        ),
        body: NestedScrollView(
          headerSliverBuilder:
              (context, innerBoxIsScrolled) => [
                // 탑 패널
                SliverToBoxAdapter(child: TopPanel()),
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                SliverToBoxAdapter(child: NoticePanel(isLeader: isLeader)),
                // 탭바
                SliverPersistentHeader(
                  pinned: true,
                  delegate: TabBarHeaderDelegate(
                    child: SizedBox(
                      height: 36.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
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
                                  fontSize: 15.sp,
                                  height: 1.40,
                                  letterSpacing: -0.48,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                '갤러리',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  height: 1.40,
                                  letterSpacing: -0.48,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Tab(
                              child: Text(
                                '즐겨찾는 사진',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  height: 1.40,
                                  letterSpacing: -0.48,
                                  fontWeight: FontWeight.w500,
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
                color: const Color(0xfffafafa),
                backgroundColor: const Color(0xff8287ff),
                showChildOpacityTransition: true, // child 투명도 트랜지션 사용 여부
                child: ScheduleDashboardTab(),
              ),
              LiquidPullToRefresh(
                onRefresh: refreshAll,
                animSpeedFactor: 7.0,
                color: const Color(0xfffafafa),
                backgroundColor: const Color(0xff8287ff),
                showChildOpacityTransition: true, // child 투명도 트랜지션 사용 여부
                child: GalleryTab(
                  sliverMode: true,
                  selectedDayIndex: _selectedDayIndex,
                  onDayIndexChanged: (index) {
                    setState(() {
                      _selectedDayIndex = index;
                    });
                  },
                ),
              ),
              FavoriteGalleryTab(),
            ],
          ),
        ),
      ),
    );
  }
}

Widget? _getBottomNavigationBar(
  WidgetRef ref,
  int bottomAppBarState,
  int selectedDayIndex,
  bool isLeader,
) {
  final tripState = ref.watch(tripProvider).valueOrNull;
  // 여행 상태가 SETTING이고 날짜 미지정이면 '여행 날짜 확정하기' 버튼
  if (tripState is SettingTripModel) {
    final settingTrip = tripState;
    final startedAt = settingTrip.startedAt;
    final endedAt = settingTrip.endedAt;
    // 리더만 버튼 노출
    if (isLeader) {
      if (startedAt == null || endedAt == null) {
        // 날짜 미지정: 여행 날짜 확정하기
        return const BottomAppBarLayout(child: ConfirmCalendarState());
      } else {
        // 날짜 지정: 여행 일정 확정하기
        final tripId = settingTrip.tripId;
        int lastDay = 1;
        try {
          final start = DateTime.parse(startedAt.toString().substring(0, 10));
          final end = DateTime.parse(endedAt.toString().substring(0, 10));
          lastDay = end.difference(start).inDays + 1;
          if (lastDay < 1) lastDay = 1;
        } catch (e) {
          lastDay = 1;
        }
        return BottomAppBarLayout(
          child: ConfirmScheduleState(tripId: tripId, lastDay: lastDay),
        );
      }
    } else {
      return null;
    }
  } else if (bottomAppBarState == 1) {
    return isLeader
        ? BottomAppBarLayout(
          child:
              tripState is InProgressTripModel
                  ? AddNoticeAndPingState()
                  : AddNoticeState(),
        )
        : null;
    // 방장아니면 공지, 집결지 아무것도 못함.
  } else if (bottomAppBarState == 2 || bottomAppBarState == 3) {
    // 갤러리 탭 하단바는 inprogress/completed 상태에서만 노출
    if (tripState is InProgressTripModel || tripState is CompletedTripModel) {
      if (bottomAppBarState == 2) {
        return BottomAppBarLayout(
          child: AddPictureState(selectedDayIndex: selectedDayIndex),
        );
      } else {
        return BottomAppBarLayout(
          child: PictureOptionState(selectedDayIndex: selectedDayIndex),
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
