import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DaySelector extends StatelessWidget {
  final int itemCount;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final String Function(int)? labelBuilder; // TODO: 커스텀 라벨 함수 (선택사항)

  const DaySelector({
    super.key,
    required this.itemCount,
    required this.selectedIndex,
    required this.onChanged,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 1.5.h),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        separatorBuilder: (_, __) => SizedBox(width: 6.w),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;

          // labelBuilder가 있으면 사용, 없으면 기본 로직
          final label =
              labelBuilder?.call(index) ??
              (index == 0 ? '여행 전체' : 'DAY $index');

          return GestureDetector(
            onTap: () {
              onChanged(index);
            },
            child: AnimatedContainer(
              clipBehavior: Clip.antiAlias,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(horizontal: 9.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(27.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 3,
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                  ),
                ],
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
