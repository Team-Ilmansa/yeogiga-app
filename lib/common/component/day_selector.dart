import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DaySelector extends StatelessWidget {
  final int itemCount;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const DaySelector({
    super.key,
    required this.itemCount,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 27.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: 4.w),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final label = index == 0 ? '여행 전체' : 'DAY $index';

          return GestureDetector(
            onTap: () {
              onChanged(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(horizontal: 9.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27.r),
                border: Border.all(color: const Color(0xffd9d9d9)),
                color: isSelected ? const Color(0xff8287ff) : Colors.white,
              ),
              alignment: Alignment.center,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xff7d7d7d),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
                child: Padding(
                  padding: EdgeInsets.only(top: 1.h),
                  child: Text(label),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
