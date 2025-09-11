import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class NoticeCard extends StatelessWidget {
  final String title;

  const NoticeCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey('notice_$title'),
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
                    print('일반 공지 삭제: $title');
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
                    print('일반 공지 완료: $title');
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
          // TODO: 공지사항 자세히보기 모달 펼치기
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
                  'asset/icon/notice.svg',
                  width: 24.w,
                  height: 24.h,
                ),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    height: 1.4,
                    letterSpacing: -0.3,
                    color: Color(0xff7d7d7d),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
