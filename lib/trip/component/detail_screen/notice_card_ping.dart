import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NoticeCardPing extends ConsumerWidget {
  final String title;
  final String time;

  const NoticeCardPing({super.key, required this.title, required this.time});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.only(top: 7.h),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffe6e7ff),
          borderRadius: BorderRadius.circular(12.r),
        ),
        height: 53.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w),
          child: Row(
            children: [
              SvgPicture.asset(
                'asset/icon/ping.svg',
                width: 22.w,
                height: 22.h,
              ),
              SizedBox(width: 7.w),
              Text(
                'Text',
                style: TextStyle(
                  fontSize: 15.sp,
                  letterSpacing: -0.1,
                  color: Color(0xff7d7d7d),
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                'Time',
                style: TextStyle(
                  fontSize: 12.sp,
                  letterSpacing: -0.1,
                  color: Color(0xff8287ff),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
