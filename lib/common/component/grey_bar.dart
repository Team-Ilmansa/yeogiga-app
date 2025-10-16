import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GreyBar extends StatelessWidget {
  const GreyBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 111.w,
      height: 6.h,
      margin: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFf0f0f0),
        borderRadius: BorderRadius.circular(10.r),
      ),
    );
  }
}
