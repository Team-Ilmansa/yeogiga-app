import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class AddScheduleState extends StatelessWidget {
  const AddScheduleState({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff8287ff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(42.r),
              ),
              minimumSize: Size.fromHeight(156.h),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              // TODO: 일정 추가 액션
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'asset/icon/add_schedule.svg',
                  width: 72.w,
                  height: 72.h,
                ),
                SizedBox(width: 30.w),
                Text(
                  '일정 추가하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 36.w),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff8287ff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(42.r),
              ),
              minimumSize: Size.fromHeight(156.h),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              // TODO: 공지 추가 액션
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'asset/icon/gong_ji.svg',
                  width: 72.w,
                  height: 72.h,
                ),
                SizedBox(width: 30.w),
                Text(
                  '공지 추가하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AddPictureState extends StatelessWidget {
  const AddPictureState({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff8287ff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(42.r),
              ),
              minimumSize: Size.fromHeight(156.h),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              // TODO: 사진 업로드 액션
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'asset/icon/add_picture.svg',
                  width: 72.w,
                  height: 72.h,
                ),
                SizedBox(width: 30.w),
                Text(
                  '사진 업로드하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 36.w),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff8287ff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(42.r),
              ),
              minimumSize: Size.fromHeight(156.h),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              // TODO: 사진 매핑 api 호출
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '사진 맵핑하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PictureOptionState extends StatelessWidget {
  const PictureOptionState({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffc6c6c6),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              onPressed: () {}, // 삭제 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('asset/icon/delete.svg'),
                  SizedBox(height: 6.h),
                  Text(
                    '삭제',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 36.sp,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffc6c6c6),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              onPressed: () {}, // 공유 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('asset/icon/share.svg'),
                  SizedBox(height: 6.h),
                  Text(
                    '공유',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 36.sp,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffc6c6c6),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              onPressed: () {}, // 저장 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('asset/icon/download.svg'),
                  SizedBox(height: 6.h),
                  Text(
                    '내 갤러리에 저장',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 36.sp,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmCalendarState extends StatelessWidget {
  const ConfirmCalendarState({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8287FF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(42.r),
        ),
        elevation: 0,
        minimumSize: Size.fromHeight(156.h),
        padding: EdgeInsets.zero,
      ),
      onPressed: () {
        // TODO: 날짜 지정 화면으로 이동
        GoRouter.of(context).push('/W2mConfirmScreen');
      },
      child: Text(
        '여행 날짜 확정하기',
        style: TextStyle(
          fontSize: 48.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
