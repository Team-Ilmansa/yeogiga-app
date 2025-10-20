import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/notice/component/notice_card.dart';
import 'package:yeogiga/notice/component/ping_card.dart';
import 'package:yeogiga/notice/provider/notice_provider.dart';
import 'package:yeogiga/notice/provider/ping_provider.dart';

class NoticePanel extends ConsumerStatefulWidget {
  final bool isLeader;
  const NoticePanel({super.key, required this.isLeader});

  @override
  ConsumerState<NoticePanel> createState() => _NoticePanelState();
}

class _NoticePanelState extends ConsumerState<NoticePanel> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final noticeListData = ref.watch(noticeListProvider);
    final pingData = ref.watch(pingProvider);
    final isLeader = widget.isLeader;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        children: [
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Text(
                    '현재 공지',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      letterSpacing: -0.3,
                      color: const Color(0xff313131),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  // 여긴 일부러 GestureDetector씀
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: AnimatedRotation(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                      turns: _isExpanded ? 0.50 : 0, // 90도 회전 (0.25 = 90/360)
                      child: Icon(
                        Icons.keyboard_arrow_up,
                        size: 20.sp,
                        color: const Color(0xff313131),
                      ),
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    GoRouter.of(context).push('/noticeListScreen');
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Text(
                      '지난 공지 전체보기',
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.5,
                        letterSpacing: -0.3,
                        color: const Color(0xffc6c6c6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // 완료되지 않은 공지사항만 표시 (애니메이션 적용)
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: () {
              final currentNotices =
                  noticeListData.where((notice) => !notice.completed).toList();

              // if (currentNotices.isEmpty && pingData == null) {
              //   return Container(
              //     height: 60.h,
              //     alignment: Alignment.center,
              //     child: Text(
              //       '현재 공지가 없습니다.',
              //       style: TextStyle(fontSize: 14.sp, color: Color(0xffc6c6c6)),
              //     ),
              //   );
              // }

              return Column(
                children: [
                  // 핑이 있으면 항상 표시
                  if (pingData != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child:
                          isLeader
                              ? LeaderPingCard(ping: pingData)
                              : PingCard(ping: pingData),
                    ),
                  // 첫 번째 공지는 항상 표시
                  if (currentNotices.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child:
                          isLeader
                              ? LeaderNoticeCard(notice: currentNotices.first)
                              : NoticeCard(notice: currentNotices.first),
                    ),

                  // 나머지 공지들은 확장 상태에서만 애니메이션으로 표시
                  ClipRect(
                    child: AnimatedAlign(
                      duration: Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      heightFactor: _isExpanded ? 1.0 : 0.0,
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 200),
                        opacity: _isExpanded ? 1.0 : 0.0,
                        child:
                            currentNotices.isEmpty && pingData == null
                                ? Container(
                                  height: 60.h,
                                  alignment: Alignment.center,
                                  child: Text(
                                    '현재 공지가 없습니다.',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Color(0xffc6c6c6),
                                    ),
                                  ),
                                )
                                : Column(
                                  children:
                                      currentNotices.skip(1).map((notice) {
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: 8.h),
                                          child:
                                              isLeader
                                                  ? LeaderNoticeCard(
                                                    notice: notice,
                                                  )
                                                  : NoticeCard(notice: notice),
                                        );
                                      }).toList(),
                                ),
                      ),
                    ),
                  ),
                ],
              );
            }(),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}
