import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/main_trip/provider/main_trip_provider.dart';
import 'package:intl/intl.dart';
import 'package:yeogiga/common/utils/category_icon_util.dart';

class ScheduleItem extends StatelessWidget {
  final String title;
  final String category;
  final String? time;
  final bool done;

  const ScheduleItem({
    super.key,
    required this.title,
    required this.category,
    this.time,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFFF0F0F0); // 모든 항목 동일 배경
    final textColor = const Color(0xFF7D7D7D);

    // 카테고리에 따라 아이콘 경로 결정
    final categoryIcon = CategoryIconUtil.getCategoryIconByKorean(category);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 9.w),
      child: Row(
        children: [
          SizedBox(
            width: 36.w,
            height: 53.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(categoryIcon, width: 24.w, height: 24.h),
                Positioned(
                  bottom: 0,
                  child: Text(
                    time ?? '',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 5.w),
          Expanded(
            child: Container(
              height: 58.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
                  ),
                  if (done)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC6C6C6),
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      child: Text(
                        '완료',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
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

class ScheduleItemListMain extends ConsumerStatefulWidget {
  const ScheduleItemListMain({super.key});

  @override
  ConsumerState<ScheduleItemListMain> createState() =>
      _ScheduleItemListMainState();
}

class _ScheduleItemListMainState extends ConsumerState<ScheduleItemListMain>
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
      loading:
          () => const Center(
            child: CircularProgressIndicator(color: Color(0xff8287ff)),
          ),
      error: (e, _) => Center(child: Text('일정 정보를 불러올 수 없습니다.')),
      data: (mainTrip) {
        if (mainTrip == null) {
          return const SizedBox.shrink();
        }
        final places = mainTrip.places;
        final itemHeight = 61.h;
        final totalItemCount = places.length;
        final listBottomPadding = 21.h;

        // 아이템이 없는 경우의 높이 설정
        final emptyCollapsedHeight = 50.h; // "아직 예정된 일정이 없어요" 텍스트만 보이는 높이
        final emptyExpandedHeight = 100.h; // 텍스트 아래 빈공간이 더 보이는 높이

        // 높이 계산 로직
        double calculatedHeight;

        if (totalItemCount == 0) {
          // 아이템이 없는 경우
          calculatedHeight =
              isExpanded ? emptyExpandedHeight : emptyCollapsedHeight;
        } else {
          // 아이템이 있는 경우
          if (isExpanded) {
            // 펼친 상태: 모든 아이템을 보여줄 수 있는 높이
            calculatedHeight =
                itemHeight * totalItemCount + listBottomPadding + 10.h;
          } else {
            // 접은 상태: 최대 3.5개까지만 보이는 높이
            final visibleItemCount =
                totalItemCount > 3.3 ? 3.3 : totalItemCount.toDouble();
            calculatedHeight =
                itemHeight * visibleItemCount + listBottomPadding;
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

        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(bottom: 21.h),
                    decoration: BoxDecoration(
                      color: const Color(0xffffffff),
                      borderRadius: BorderRadius.circular(14.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 1.r,
                          spreadRadius: 1.r,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.fromLTRB(0, 4.h, 11.w, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(13.sp),
                              child: Text(
                                titleText,
                                style: TextStyle(
                                  fontSize: 14.sp,
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
                                  itemCount:
                                      places.isEmpty ? 2 : places.length + 1,
                                  itemBuilder: (context, index) {
                                    if (places.isEmpty && index == 0) {
                                      // 안내문구 + 일정 담으러 가기 버튼 (둘 다 보여줌)
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Center(
                                            child: Text(
                                              '아직 예정된 일정이 없어요.',
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFB0B0B0),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10.h),
                                          // Center(
                                          //   child: TextButton(
                                          //     onPressed: () {},
                                          //     child: Text(
                                          //       '+ 일정 담으러 가기',
                                          //       style: TextStyle(
                                          //         fontSize: 14.sp,
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
                                              category:
                                                  place
                                                      .placeType, // TODO: place에서 카테고리 가져오기
                                              time: null,
                                              done: place.isVisited,
                                            ),
                                            SizedBox(height: 21.h),
                                          ],
                                        );
                                      } else {
                                        return ScheduleItem(
                                          title: place.name,
                                          category:
                                              place
                                                  .placeType, // TODO: place에서 카테고리 가져오기
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
                                    height: 36.h,
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
                    offset: Offset(0, -22.h),
                    child: ElevatedButton(
                      onPressed: _toggleExpanded,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8287ff),
                        shape: const StadiumBorder(),
                        fixedSize: Size(125.w, 40.h), // 고정 크기
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
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
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: Offset(0, -18.h),
              child: Container(height: 11.h, color: Color(0xfff0f0f0)),
            ),
            SizedBox(height: 40.h),
          ],
        );
      },
    );
  }
}
