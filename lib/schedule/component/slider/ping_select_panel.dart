import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yeogiga/naver/model/naver_place_search_response.dart';
import 'package:yeogiga/trip/model/trip_model.dart';

class PingSelectPanel extends StatefulWidget {
  final NaverPlaceItem? place;
  final String? imageUrl;
  final Function(DateTime) onAddPressed;
  final TripModel? trip;

  const PingSelectPanel({
    Key? key,
    required this.place,
    this.imageUrl,
    required this.onAddPressed,
    this.trip,
  }) : super(key: key);

  @override
  State<PingSelectPanel> createState() => _PingSelectPanelState();
}

class _PingSelectPanelState extends State<PingSelectPanel> {
  DateTime selectedDateTime = DateTime.now().add(Duration(hours: 1));

  List<DateTime> get availableDates {
    if (widget.trip?.startedAt == null || widget.trip?.endedAt == null) {
      return [DateTime.now()];
    }

    final start = DateTime.parse(widget.trip!.startedAt!.substring(0, 10));
    final end = DateTime.parse(widget.trip!.endedAt!.substring(0, 10));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = <DateTime>[];

    for (var i = 0; i <= end.difference(start).inDays; i++) {
      final date = start.add(Duration(days: i));
      // 오늘 이후의 날짜만 포함
      if (date.isAfter(today.subtract(Duration(days: 1)))) {
        dates.add(date);
      }
    }

    return dates.isNotEmpty ? dates : [today];
  }

  @override
  void initState() {
    super.initState();
    // 초기 날짜를 여행 기간 내로 설정
    if (availableDates.isNotEmpty) {
      final now = DateTime.now();
      final validDate =
          availableDates
              .where((date) => date.isAfter(now.subtract(Duration(days: 1))))
              .firstOrNull ??
          availableDates.first;

      selectedDateTime = DateTime(
        validDate.year,
        validDate.month,
        validDate.day,
        selectedDateTime.hour,
        selectedDateTime.minute,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 2.r,
            spreadRadius: 1.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: Container(
                width: 111.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFf0f0f0),
                  borderRadius: BorderRadius.circular(11.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 100.h,
            child: ListView.separated(
              primary: false,
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              separatorBuilder: (context, index) => SizedBox(width: 8.w),
              itemCount: 5,
              itemBuilder: (context, index) {
                return Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child:
                      widget.imageUrl != null && widget.imageUrl!.isNotEmpty
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(11.r),
                            child: Image.network(
                              widget.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                          )
                          : const Icon(Icons.image, color: Colors.grey),
                );
              },
            ),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.only(right: 16.w, left: 16.w, bottom: 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.place?.title ?? '',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF313131),
                    letterSpacing: -0.3,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  widget.place?.roadAddress ?? widget.place?.address ?? '',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: const Color(0xFF7d7d7d),
                    letterSpacing: -0.3,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 28.h),
                // 집결 일시 설정 부분
                Text(
                  '집결 일시',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    // 날짜 선택
                    Expanded(flex: 2, child: _buildDateSelector()),
                    SizedBox(width: 8.w),
                    // 시간 선택
                    Expanded(child: _buildTimeSelector()),
                    SizedBox(width: 8.w),
                    // 분 선택
                    Expanded(child: _buildMinuteSelector()),
                  ],
                ),
                SizedBox(height: 20.h),
                // 집결지 추가 버튼
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () => widget.onAddPressed(selectedDateTime),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C8AFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.h),
                          child: SvgPicture.asset(
                            'asset/icon/ping_white.svg',
                            width: 24.w,
                            height: 24.h,
                          ),
                        ),
                        Text(
                          '집결지로 설정하기',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: -0.1,
                          ),
                        ),
                        SizedBox(width: 5.w),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () => _showDatePicker(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(11.r),
        ),
        child: Column(
          children: [
            Text(
              '날짜',
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9E9E9E)),
            ),
            SizedBox(height: 4.h),
            Text(
              '${selectedDateTime.month}월 ${selectedDateTime.day}일',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: () => _showTimePicker(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(11.r),
        ),
        child: Column(
          children: [
            Text(
              '시간',
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9E9E9E)),
            ),
            SizedBox(height: 4.h),
            Text(
              '${selectedDateTime.hour.toString().padLeft(2, '0')}시',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMinuteSelector() {
    return GestureDetector(
      onTap: () => _showMinutePicker(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(11.r),
        ),
        child: Column(
          children: [
            Text(
              '분',
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9E9E9E)),
            ),
            SizedBox(height: 4.h),
            Text(
              '${selectedDateTime.minute.toString().padLeft(2, '0')}분',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => Container(
            height: 300.h,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  height: 50.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 40.w),
                      Text(
                        '날짜 선택',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '확인',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40.h,
                    scrollController: FixedExtentScrollController(
                      initialItem: availableDates
                          .indexWhere(
                            (date) =>
                                date.day == selectedDateTime.day &&
                                date.month == selectedDateTime.month,
                          )
                          .clamp(0, availableDates.length - 1),
                    ),
                    onSelectedItemChanged: (index) {
                      final selectedDate = availableDates[index];
                      setState(() {
                        selectedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedDateTime.hour,
                          selectedDateTime.minute,
                        );
                      });
                    },
                    children:
                        availableDates.map((date) {
                          return Center(
                            child: Text(
                              '${date.month}월 ${date.day}일',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showTimePicker() {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => Container(
            height: 300.h,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  height: 50.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 40.w),
                      Text(
                        '시간 선택',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '확인',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40.h,
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedDateTime.hour,
                    ),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedDateTime = DateTime(
                          selectedDateTime.year,
                          selectedDateTime.month,
                          selectedDateTime.day,
                          index,
                          selectedDateTime.minute,
                        );
                      });
                    },
                    children: List.generate(24, (index) {
                      return Center(
                        child: Text(
                          '${index.toString().padLeft(2, '0')}시',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showMinutePicker() {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => Container(
            height: 300.h,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  height: 50.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 40.w),
                      Text(
                        '분 선택',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          '확인',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 40.h,
                    scrollController: FixedExtentScrollController(
                      initialItem: selectedDateTime.minute ~/ 1,
                    ),
                    onSelectedItemChanged: (index) {
                      setState(() {
                        selectedDateTime = DateTime(
                          selectedDateTime.year,
                          selectedDateTime.month,
                          selectedDateTime.day,
                          selectedDateTime.hour,
                          index * 1,
                        );
                      });
                    },
                    children: List.generate(60, (index) {
                      final minute = index * 1;
                      return Center(
                        child: Text(
                          '${minute.toString().padLeft(2, '0')}분',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
