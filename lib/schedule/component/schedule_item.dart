import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/main_trip/provider/main_trip_provider.dart';
import 'package:intl/intl.dart';

class ScheduleItem extends StatelessWidget {
  final String title;
  final String? time;
  final bool done;

  const ScheduleItem({
    super.key,
    required this.title,
    this.time,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFFF0F0F0); // 모든 항목 동일 배경
    final textColor = const Color(0xFF7D7D7D);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 30.w),
      child: Row(
        children: [
          SizedBox(
            width: 120.w,
            height: 180.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                  'asset/icon/category icon.svg',
                  width: 78.w,
                  height: 78.h,
                ),
                Positioned(
                  bottom: 0,
                  child: Text(
                    time ?? '',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 33.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 18.w),
          Expanded(
            child: Container(
              height: 195.h,
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(54.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                  if (done)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 39.w,
                        vertical: 20.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC6C6C6),
                        borderRadius: BorderRadius.circular(48.r),
                      ),
                      child: Text(
                        '완료',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42.sp,
                          fontWeight: FontWeight.w600,
                        ),
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

class ScheduleItemList extends ConsumerStatefulWidget {
  const ScheduleItemList({super.key});

  @override
  ConsumerState<ScheduleItemList> createState() => _ScheduleItemListState();
}

class _ScheduleItemListState extends ConsumerState<ScheduleItemList>
    with TickerProviderStateMixin {
  bool isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mainTripAsync = ref.watch(mainTripFutureProvider);
    return mainTripAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('일정 정보를 불러올 수 없습니다.')),
      data: (mainTrip) {
        if (mainTrip == null) {
          return const SizedBox.shrink();
        }
        final places = mainTrip.places;
        final itemHeight = 204.h;
        final totalItemCount = places.length;
        final listBottomPadding = 72.h;
        // collapsed 상태: 최소 1개, 최대 3.3개
        final collapsedMinHeight = itemHeight * 1 + listBottomPadding;
        final collapsedMaxHeight = itemHeight * 3.3 + listBottomPadding;
        // 펼침 상태: 기존과 동일
        final maxExpandedHeight = 1500.h;
        final totalListHeight = itemHeight * totalItemCount;
        final expandedHeight =
            totalListHeight + listBottomPadding < maxExpandedHeight
                ? totalListHeight + listBottomPadding
                : maxExpandedHeight;
        double calculatedHeight;
        if (isExpanded) {
          calculatedHeight = expandedHeight;
        } else {
          // 1개만 있을 때는 1개만, 2~3개면 그 개수만큼, 4개 이상이면 3.3개만
          if (totalItemCount <= 1) {
            calculatedHeight = collapsedMinHeight;
          } else if (totalItemCount < 4) {
            calculatedHeight = itemHeight * totalItemCount + listBottomPadding;
          } else {
            calculatedHeight = collapsedMaxHeight;
          }
        }

        // 날짜 타이틀 로직
        final now = DateTime.now();
        final start = mainTrip.staredAt;
        String titleText;
        if (now.isBefore(start)) {
          final formatter = DateFormat('M월 d일');
          final startText = formatter.format(start);
          titleText = '$startText 여행 첫날의 일정';
        } else {
          final formatter = DateFormat('M월 d일');
          titleText = '${formatter.format(now)} 오늘의 일정';
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 48.h),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(bottom: 72.h),
                decoration: BoxDecoration(
                  color: const Color(0xffffffff),
                  borderRadius: BorderRadius.circular(48.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12.r,
                      spreadRadius: 0.9.r,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 12.h, 36.w, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(45.sp),
                          child: Text(
                            titleText,
                            style: TextStyle(
                              fontSize: 48.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff7d7d7d),
                              letterSpacing: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        height: calculatedHeight,
                        child: Stack(
                          children: [
                            ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: places.isEmpty ? 2 : places.length + 1,
                              itemBuilder: (context, index) {
                                if (places.isEmpty && index == 0) {
                                  // 안내문구 + 일정 담으러 가기 버튼 (둘 다 보여줌)
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Center(
                                        child: Text(
                                          '아직 예정된 일정이 없어요.',
                                          style: TextStyle(
                                            fontSize: 48.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFB0B0B0),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 32.h),
                                      // Center(
                                      //   child: TextButton(
                                      //     onPressed: () {},
                                      //     child: Text(
                                      //       '+ 일정 담으러 가기',
                                      //       style: TextStyle(
                                      //         fontSize: 48.sp,
                                      //         fontWeight: FontWeight.bold,
                                      //         color: Color(0xFF8287ff),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  );
                                } else if (index < places.length &&
                                    places.isNotEmpty) {
                                  final place = places[index];
                                  if (index == places.length - 1) {
                                    return Column(
                                      children: [
                                        ScheduleItem(
                                          title: place.name,
                                          time: null,
                                          done: place.isVisited,
                                        ),
                                        SizedBox(height: 70.h),
                                      ],
                                    );
                                  } else {
                                    return ScheduleItem(
                                      title: place.name,
                                      time: null,
                                      done: place.isVisited,
                                    );
                                  }
                                } else {
                                  return const SizedBox.shrink();
                                }
                              },
                            ),
                            if (true)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                height: 120.h,
                                child: IgnorePointer(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white.withOpacity(0.0),
                                          Colors.white.withOpacity(0.6),
                                          Colors.white,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Transform.translate(
                offset: Offset(0, -80.h),
                child: ElevatedButton(
                  onPressed: _toggleExpanded,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8287ff),
                    shape: const StadiumBorder(),
                    fixedSize: Size(420.w, 135.h), // 고정 크기
                    padding: EdgeInsets.symmetric(horizontal: 48.w),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isExpanded ? "일정 접기" : "일정 펼치기",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 45.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 18.w),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 54.sp,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
