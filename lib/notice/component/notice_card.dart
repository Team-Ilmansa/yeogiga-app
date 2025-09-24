import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/notice/model/notice_model.dart';
import 'package:yeogiga/notice/provider/notice_provider.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';

class LeaderNoticeCard extends ConsumerWidget {
  final NoticeModel notice;

  const LeaderNoticeCard({super.key, required this.notice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Slidable(
      key: ValueKey('notice_${notice.title}'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: notice.completed ? 0.16 : 0.31,
        children: [
          // 삭제 버튼
          Expanded(
            child: Container(
              margin:
                  notice.completed
                      ? EdgeInsets.only(
                        left: 12.w,
                        right: 4.w,
                        top: 16.h,
                        bottom: 16.h,
                      )
                      : EdgeInsets.only(left: 12.w, top: 16.h, bottom: 16.h),
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
                  onTap: () async {
                    final tripState = ref.read(tripProvider).valueOrNull;
                    if (tripState is TripModel) {
                      await ref
                          .read(noticeListProvider.notifier)
                          .deleteNotice(
                            tripId: tripState.tripId,
                            noticeId: notice.id,
                          );
                    }
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
          if (notice.completed == false)
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
                    onTap: () async {
                      final tripState = ref.read(tripProvider).valueOrNull;
                      if (tripState is TripModel) {
                        await ref
                            .read(noticeListProvider.notifier)
                            .toggleNoticeComplete(
                              tripId: tripState.tripId,
                              noticeId: notice.id,
                              completed: true,
                            );
                      }
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
          _showNoticeModal(context, notice);
        },
        child: Container(
          decoration: BoxDecoration(
            color: notice.completed ? Color(0xfff0f0f0) : Color(0xffe6e7ff),
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
                  notice.title,
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

class NoticeCard extends StatelessWidget {
  final NoticeModel notice;

  const NoticeCard({super.key, required this.notice});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: 공지사항 자세히보기 모달 펼치기
        _showNoticeModal(context, notice);
      },
      child: Container(
        decoration: BoxDecoration(
          color: notice.completed ? Color(0xfff0f0f0) : Color(0xffe6e7ff),
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
                notice.title,
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
    );
  }
}

void _showNoticeModal(BuildContext context, NoticeModel notice) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 340.w,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, size: 24),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                '${notice.title}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20.sp,
                  height: 1.4,
                  letterSpacing: -0.3,
                  color: Color(0xff313131),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                '${notice.description}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  height: 1.4,
                  letterSpacing: -0.42,
                  color: Color(0xff7d7d7d),
                ),
              ),
              SizedBox(height: 67.h),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 120.w,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: () {
                      GoRouter.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff8287ff),
                      disabledBackgroundColor: Color(0xffc6c6c6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      '확인',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        height: 1.4,
                        letterSpacing: -0.3,
                        color: Color(0xffffffff),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
