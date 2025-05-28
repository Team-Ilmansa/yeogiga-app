import 'package:flutter/material.dart' hide ExpansionPanel;
import 'package:flutter_svg/svg.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/common/component/expansion_panel.dart';
import 'package:yeogiga/schedule/component/schedule_item.dart';
import 'package:yeogiga/trip/component/notice_card.dart';
import 'package:yeogiga/trip/component/notice_card_ping.dart';
import 'package:yeogiga/common/component/trip_name_card.dart';

class TripDetailScreen extends StatefulWidget {
  static String get routeName => 'tripDetailScreen';
  const TripDetailScreen({super.key});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen>
    with SingleTickerProviderStateMixin {
  int bottomAppBarState = 1;
  late TabController _tabController;

  // 자식 위젯의 상태를 들고오기 위해
  final GlobalKey<_GalleryTabState> _galleryTabKey =
      GlobalKey<_GalleryTabState>();

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
          final selectionMode =
              _galleryTabKey.currentState?.selectionMode ?? false;
          bottomAppBarState = selectionMode ? 3 : 2;
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
    return Scaffold(
      backgroundColor: const Color(0xfffafafa),
      appBar: AppBar(
        toolbarHeight: 40,
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent, // 그림자도 제거
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => Navigator.pop(context),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.map_outlined, color: Colors.black),
                  onPressed: () {
                    //TODO: 지도로 이동
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: () {
                    //TODO: 메뉴 펼치기
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 1)],
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 25),
            child: Builder(
              builder: (context) {
                if (bottomAppBarState == 1) {
                  return const AddScheduleState();
                } else if (bottomAppBarState == 2) {
                  return const AddPictureState();
                } else if (bottomAppBarState == 3) {
                  return const PictureOptionState();
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ),
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
                      height: 36,
                      child: TabBar(
                        controller: _tabController,
                        indicator: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFF8287FF),
                              width: 2,
                            ),
                          ),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: const Color(0xFF8287FF),
                        unselectedLabelColor: Colors.grey,
                        tabs: const [
                          Tab(
                            child: Text(
                              '일정 대시보드',
                              style: TextStyle(
                                fontSize: 16,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          Tab(
                            child: Text(
                              '갤러리',
                              style: TextStyle(
                                fontSize: 16,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                        ],
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
                key: _galleryTabKey,
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
  double get maxExtent => 36; // TabBar의 실제 높이와 동일하게!
  @override
  double get minExtent => 36;
  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) => false;
}

// 상단 여행 정보
class TopPanel extends StatelessWidget {
  const TopPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "진행중인 여행",
            style: TextStyle(
              color: Color(0xff8287ff),
              fontSize: 14,
              letterSpacing: -0.3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "여행이름",
            style: TextStyle(
              color: Color(0xff313131),
              fontWeight: FontWeight.w700,
              fontSize: 28,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          TripNameCardByAsset(
            assetUrl: 'asset/icon/marker-pin-01.svg',
            name: '경주시, 포항시',
            color: const Color(0xff7d7d7d),
          ),
          const SizedBox(height: 3),
          TripNameCardByAsset(
            assetUrl: 'asset/icon/calendar.svg',
            name: "2025.03.17 - 2025.03.20",
            color: const Color(0xff7d7d7d),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              SvgPicture.asset(
                'asset/icon/user-02.svg',
                width: 17,
                height: 17,
                color: const Color(0xff7d7d7d),
              ),
              const SizedBox(width: 5),
              ...List.generate(
                4,
                (_) => const Padding(
                  padding: EdgeInsets.only(right: 1),
                  child: Icon(
                    Icons.circle,
                    size: 18,
                    color: Color.fromARGB(255, 235, 235, 235),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 상단 알림창
class NoticePanel extends StatelessWidget {
  const NoticePanel({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> pingNotice = [
      {'title': '집결 1', 'time': '11:00'},
      {'title': '집결 2', 'time': '13:30'},
      {'title': '집결 3', 'time': '16:45'},
    ];

    List<String> notice = ['집결 시간 변경', '숙소 체크인 안내', '저녁 식사 장소 공지'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '현재 공지',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: Color(0xff313131),
                ),
              ),
              Text(
                '지난 공지 전체보기',
                style: const TextStyle(
                  fontSize: 13,
                  letterSpacing: -0.6,
                  color: Color.fromARGB(255, 193, 193, 193),
                ),
              ),
            ],
          ),
          // TODO: 핑 공지 있으면
          if (true) NoticeCardPing(title: 'Text', time: 'Time'),
          // ...pingNotice.map(
          //   (item) =>
          //       NoticeCardPing(title: item['title']!, time: item['time']!),
          // ),
          // TODO: 일반 공지 있으면
          if (true) NoticeCard(title: 'Text'),

          // ...notice.map((n) => NoticeCard(title: n)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

// 일정 대시보드 화면
class ScheduleDashboardTab extends StatefulWidget {
  const ScheduleDashboardTab({super.key});

  @override
  State<ScheduleDashboardTab> createState() => _ScheduleDashboardTabState();
}

class _ScheduleDashboardTabState extends State<ScheduleDashboardTab> {
  final List<String> days = List.generate(10, (index) => 'DAY ${index + 1}');
  int selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: DaySelector(
            itemCount: days.length + 1, // +1 for '여행 전체'
            selectedIndex: selectedDayIndex,
            onChanged: (index) {
              setState(() {
                selectedDayIndex = index;
              });
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (selectedDayIndex == 0) {
              // 전체 보기: 모든 Day
              return ExpansionPanel(dayName: 'Day ${index + 1}');
            } else {
              // 특정 Day만 보기
              return ExpansionPanel(dayName: 'Day $selectedDayIndex');
            }
          }, childCount: selectedDayIndex == 0 ? days.length : 1),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

// 갤러리 화면
class GalleryTab extends StatefulWidget {
  final ValueChanged<bool>? onSelectionModeChanged;
  const GalleryTab({super.key, this.onSelectionModeChanged});

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  final List<String> days = List.generate(10, (index) => 'DAY ${index + 1}');
  int selectedDayIndex = 0;
  int numberOfPicture = 57;
  bool selectionMode = false;
  Set<int> selectedPictures = {};

  void setSelectionMode(bool value) {
    if (selectionMode != value) {
      setState(() {
        selectionMode = value;
      });
      widget.onSelectionModeChanged?.call(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverToBoxAdapter(
          child: DaySelector(
            itemCount: days.length + 1, // +1 for '여행 전체'
            selectedIndex: selectedDayIndex,
            onChanged: (index) {
              setState(() {
                selectedDayIndex = index;
                selectedPictures.clear();
                selectionMode = false;
              });
              widget.onSelectionModeChanged?.call(false);
            },
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),

        //TODO: 그리드 뷰 부분 (사진 있으면)
        if (true)
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$numberOfPicture장',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: Color(0xff313131),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setSelectionMode(!selectionMode);
                            if (!selectionMode) {
                              setState(() {
                                selectedPictures.clear();
                              });
                            }
                          },
                          child: Row(
                            children: [
                              Text(
                                selectionMode
                                    ? '${selectedPictures.length}개 선택됨'
                                    : '선택하기',
                                style: TextStyle(
                                  fontSize: 13,
                                  letterSpacing: -0.6,
                                  color:
                                      selectionMode
                                          ? const Color(0xff8287ff)
                                          : const Color.fromARGB(
                                            255,
                                            193,
                                            193,
                                            193,
                                          ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              SvgPicture.asset(
                                'asset/icon/check.svg',
                                width: 16,
                                height: 16,
                                color:
                                    selectionMode
                                        ? const Color(0xff8287ff)
                                        : const Color.fromARGB(
                                          255,
                                          193,
                                          193,
                                          193,
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          childAspectRatio: 1,
                        ),
                    itemCount: numberOfPicture,
                    itemBuilder: (context, idx) {
                      final isSelected = selectedPictures.contains(idx);
                      return GestureDetector(
                        onTap:
                            selectionMode
                                ? () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedPictures.remove(idx);
                                    } else {
                                      selectedPictures.add(idx);
                                    }
                                  });
                                }
                                : null,
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'asset/img/home/sky.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (selectionMode && isSelected)
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xff8287ff,
                                    ).withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }, childCount: 1),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }
}

// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
// ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

// 바텀 앱바 일정추가
class AddScheduleState extends StatelessWidget {
  const AddScheduleState({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff8287ff),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        padding: EdgeInsets.zero,
      ),
      onPressed: () {
        // TODO: 일정 추가 액션
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'asset/icon/add_schedule.svg',
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 6),
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              '일정 추가하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AddPictureState extends StatelessWidget {
  const AddPictureState({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff8287ff),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        minimumSize: const Size.fromHeight(52),
        elevation: 0,
        padding: EdgeInsets.zero,
      ),
      onPressed: () {
        // TODO: 사진 업로드 액션
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('asset/icon/add_picture.svg', width: 24, height: 24),
          const SizedBox(width: 6),
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              '사진 업로드하기',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PictureOptionState extends StatelessWidget {
  const PictureOptionState({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffc6c6c6),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {}, // 삭제 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('asset/icon/delete.svg'),
                  const SizedBox(height: 3),
                  const Text(
                    '삭제',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 12,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffc6c6c6),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {}, // 공유 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('asset/icon/share.svg'),
                  const SizedBox(height: 3),
                  const Text(
                    '공유',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 12,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffc6c6c6),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {}, // 저장 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('asset/icon/download.svg'),
                  const SizedBox(height: 3),
                  const Text(
                    '내 갤러리에 저장',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 12,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
