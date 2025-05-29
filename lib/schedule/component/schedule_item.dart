import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ScheduleItem extends StatelessWidget {
  final String title;
  final String time;
  final bool done;

  const ScheduleItem({
    super.key,
    required this.title,
    required this.time,
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
                    time,
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
                      padding: EdgeInsets.symmetric(horizontal: 39.w),
                      height: 93.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC6C6C6),
                        borderRadius: BorderRadius.circular(48.r),
                      ),
                      child: Center(
                        child: Text(
                          '완료',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42.sp,
                            fontWeight: FontWeight.w600,
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
    );
  }
}

class ScheduleItemList extends StatefulWidget {
  const ScheduleItemList({super.key});

  @override
  State<ScheduleItemList> createState() => _ScheduleItemListState();
}

class _ScheduleItemListState extends State<ScheduleItemList>
    with TickerProviderStateMixin {
  bool isExpanded = false;

  final List<Map<String, dynamic>> scheduleData = List.generate(
    30,
    (index) => {
      'title': 'Text',
      'time': '11:00',
      'done': index == 0 || index == 3,
    },
  );

  void _toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemHeight = 204.h;
    final totalItemCount = scheduleData.length;
    final minListHeight = itemHeight * 3.4;
    final listBottomPadding = 72.h;
    final maxExpandedHeight = 1500.h;
    final totalListHeight = itemHeight * totalItemCount;
    final expandedHeight =
        totalListHeight + listBottomPadding < maxExpandedHeight
            ? totalListHeight + listBottomPadding
            : maxExpandedHeight;
    final calculatedHeight =
        isExpanded ? expandedHeight : minListHeight + listBottomPadding;

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
                  spreadRadius: 0.3,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(36.w, 48.h, 36.w, 24.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        "3월 25일 오늘의 일정",
                        style: TextStyle(
                          fontSize: 51.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xff7d7d7d),
                          letterSpacing: -0.4,
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
                          itemCount: totalItemCount,
                          itemBuilder: (context, index) {
                            final item = scheduleData[index];
                            return ScheduleItem(
                              title: item['title'],
                              time: item['time'],
                              done: item['done'],
                            );
                          },
                        ),
                        if (!isExpanded && totalItemCount > 4)
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
            offset: Offset(0, -75.h),
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
                      fontWeight: FontWeight.w500,
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
  }
}
