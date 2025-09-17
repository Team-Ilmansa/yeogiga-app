import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/notice/component/notice_card.dart';
import 'package:yeogiga/notice/provider/notice_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/user/model/user_model.dart';

class NoticeListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'noticeListScreen';
  const NoticeListScreen({super.key});

  @override
  ConsumerState<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends ConsumerState<NoticeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripState = ref.read(tripProvider).valueOrNull;
      if (tripState is TripModel) {
        ref.read(noticeListProvider.notifier).fetchNoticeList(tripId: tripState.tripId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 36.h,
        backgroundColor: Color(0xfffafafa),
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios_new, size: 16.sp),
            ),
          ],
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final noticeListData = ref.watch(noticeListProvider);
          final tripState = ref.watch(tripProvider).valueOrNull;
          final userMe = ref.watch(userMeProvider);

          String tripTitle = '미정';
          if (tripState is TripModel && tripState.title.isNotEmpty) {
            tripTitle = tripState.title;
          }

          // 방장 여부 확인: 내 userId가 trip의 leaderId와 같은지 체크
          bool isLeader = false;
          if (tripState is TripModel &&
              userMe is UserResponseModel &&
              userMe.data != null) {
            final leaderId = tripState.leaderId;
            // 현재 사용자의 멤버 정보 찾기
            final myMember = tripState.members.firstWhere(
              (member) => member.nickname == userMe.data!.nickname,
              orElse:
                  () => TripMember(userId: -1, nickname: '', imageUrl: null),
            );
            isLeader = myMember.userId == leaderId;
          }

          // 현재 공지 (완료되지 않은 공지)
          final currentNotices =
              noticeListData.where((notice) => !notice.completed).toList();
          // 지난 공지 (완료된 공지)
          final pastNotices =
              noticeListData.where((notice) => notice.completed).toList();

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 14.h),
                  Text(
                    '$tripTitle의\n지난 공지에요.',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 28.sp,
                      height: 1.4,
                      letterSpacing: -0.3,
                      color: Color(0xff313131),
                    ),
                  ),
                  SizedBox(height: 17.h),
                  Text(
                    '현재 공지',
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.4,
                      letterSpacing: -0.3,
                      color: Color(0xff313131),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // 현재 공지사항들 표시
                  ...currentNotices.map((notice) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child:
                          isLeader
                              ? LeaderNoticeCard(notice: notice)
                              : NoticeCard(notice: notice),
                    );
                  }),
                  if (currentNotices.isEmpty)
                    Container(
                      height: 60.h,
                      alignment: Alignment.center,
                      child: Text(
                        '현재 공지가 없습니다.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xffc6c6c6),
                        ),
                      ),
                    ),

                  SizedBox(height: 28.h),
                  Text(
                    '지난 공지',
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.4,
                      letterSpacing: -0.3,
                      color: Color(0xff313131),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // 지난 공지사항들 표시
                  ...pastNotices.map((notice) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child:
                          isLeader
                              ? LeaderNoticeCard(notice: notice)
                              : NoticeCard(notice: notice),
                    );
                  }),
                  if (pastNotices.isEmpty)
                    Container(
                      height: 60.h,
                      alignment: Alignment.center,
                      child: Text(
                        '지난 공지가 없습니다.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Color(0xffc6c6c6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
