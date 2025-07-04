import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoticeCard extends StatelessWidget {
  final String title;

  const NoticeCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 24.h),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffe6e7ff),
          borderRadius: BorderRadius.circular(42.r),
        ),
        height: 180.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 48.w),
          child: Row(
            children: [
              SvgPicture.asset('asset/icon/notice.svg', width: 75.w, height: 75.h),
              SizedBox(width: 24.w),
              Text(
                'Text',
                style: TextStyle(
                  fontSize: 51.sp,
                  letterSpacing: -0.3,
                  color: Color(0xff7d7d7d),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
