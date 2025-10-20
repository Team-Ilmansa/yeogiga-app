import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DatePickerUtil {
  /// 시간 선택 피커를 보여줍니다 (0-23시)
  static void showTimePicker({
    required BuildContext context,
    required DateTime selectedDateTime,
    required Function(DateTime) onDateChanged,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
          ),
        ),
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
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '확인',
                      style: TextStyle(color: CupertinoColors.black),
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
                  final newDateTime = DateTime(
                    selectedDateTime.year,
                    selectedDateTime.month,
                    selectedDateTime.day,
                    index,
                    selectedDateTime.minute,
                  );
                  onDateChanged(newDateTime);
                },
                children: List.generate(24, (index) {
                  return Center(
                    child: Text(
                      '${index.toString().padLeft(2, '0')}시',
                      style: TextStyle(
                        fontSize: 16.sp,
                        decoration: TextDecoration.none,
                        color: CupertinoColors.black,
                      ),
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

  /// 분 선택 피커를 보여줍니다 (0-59분)
  static void showMinutePicker({
    required BuildContext context,
    required DateTime selectedDateTime,
    required Function(DateTime) onDateChanged,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
          ),
        ),
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
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '확인',
                      style: TextStyle(color: CupertinoColors.black),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 40.h,
                scrollController: FixedExtentScrollController(
                  initialItem: selectedDateTime.minute,
                ),
                onSelectedItemChanged: (index) {
                  final newDateTime = DateTime(
                    selectedDateTime.year,
                    selectedDateTime.month,
                    selectedDateTime.day,
                    selectedDateTime.hour,
                    index,
                  );
                  onDateChanged(newDateTime);
                },
                children: List.generate(60, (index) {
                  return Center(
                    child: Text(
                      '${index.toString().padLeft(2, '0')}분',
                      style: TextStyle(
                        fontSize: 16.sp,
                        decoration: TextDecoration.none,
                        color: CupertinoColors.black,
                      ),
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

  /// 날짜 선택 피커를 보여줍니다 (특정 날짜 범위)
  static void showDateListPicker({
    required BuildContext context,
    required DateTime selectedDateTime,
    required List<DateTime> availableDates,
    required Function(DateTime) onDateChanged,
  }) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
          ),
        ),
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
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.black,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      '확인',
                      style: TextStyle(color: CupertinoColors.black),
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
                  final newDateTime = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                    selectedDateTime.hour,
                    selectedDateTime.minute,
                  );
                  onDateChanged(newDateTime);
                },
                children: availableDates.map((date) {
                  return Center(
                    child: Text(
                      '${date.year}년 ${date.month}월 ${date.day}일',
                      style: TextStyle(
                        fontSize: 16.sp,
                        decoration: TextDecoration.none,
                        color: CupertinoColors.black,
                      ),
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
}
