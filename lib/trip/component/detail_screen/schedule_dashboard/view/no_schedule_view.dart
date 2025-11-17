import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class NoScheduleView extends StatelessWidget {
  const NoScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: 50.h),
        SvgPicture.asset(
          'asset/icon/add_schedule.svg',
          height: 50.h,
          width: 50.w,
          color: const Color(0xffc6c6c6),
        ),
        SizedBox(height: 7.h),
        Center(
          child: Text(
            '날짜 확정 후 일정을 추가할 수 있어요',
            style: TextStyle(
              fontSize: 12.sp,
              color: const Color(0xffc6c6c6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
