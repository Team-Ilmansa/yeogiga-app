import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TagCard extends StatelessWidget {
  final String label;

  const TagCard({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44.w,
      height: 25.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: Color(0xff7d7d7d), fontSize: 12.sp),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
