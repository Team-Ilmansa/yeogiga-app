import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NoticeCardPing extends ConsumerWidget {
  final String title;
  final String time;

  const NoticeCardPing({super.key, required this.title, required this.time});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Slidable(
      key: ValueKey('notice_ping_$title'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.31,
        children: [
          // 삭제 버튼
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 12.w, top: 16.h, bottom: 16.h),
              decoration: BoxDecoration(
                color: Color(0xfff0f0f0),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18.r),
                  onTap: () {
                    // TODO: 삭제 처리 로직
                    print('공지 삭제: $title');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '삭제',
                      style: TextStyle(
                        color: const Color(0xffff0000),
                        fontSize: 14.sp,
                        height: 1.4,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 완료 버튼
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: 8.w,
                right: 4.w,
                top: 16.h,
                bottom: 16.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFffffFF),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18.r),
                  onTap: () {
                    // TODO: 완료 처리 로직
                    print('공지 완료: $title');
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '완료',
                      style: TextStyle(
                        color: const Color(0xff8287ff),
                        fontSize: 14.sp,
                        height: 1.4,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          // TODO: 가능하면 지도페이지로 보내기 + 핑찍은 곳으로 카메라 이동시켜주기.
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xffe6e7ff),
            borderRadius: BorderRadius.circular(14.r),
          ),
          height: 60.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                SvgPicture.asset(
                  'asset/icon/ping.svg',
                  width: 24.w,
                  height: 24.h,
                ),
                SizedBox(width: 8.w),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        height: 1.4,
                        letterSpacing: -0.3,
                        color: Color(0xff7d7d7d),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.5,
                        letterSpacing: -0.3,
                        color: Color(0xff8287ff),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
