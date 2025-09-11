import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/notice/component/notice_card.dart';
import 'package:yeogiga/notice/component/notice_card_ping.dart';

class NoticePanel extends StatelessWidget {
  const NoticePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        children: [
          SizedBox(height: 1.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
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
              GestureDetector(
                onTap: () {
                  // TODO: notice_list_screen으로 push해주기
                },
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
            ],
          ),
          SizedBox(height: 8.h),
          // TODO: 핑 공지 있으면
          if (true) NoticeCardPing(title: 'Text', time: 'Time'),
          // ...pingNotice.map(
          //   (item) => NoticeCardPing(title: item['title']!, time: item['time']!),
          // ),
          SizedBox(height: 8.h),
          // TODO: 일반 공지 있으면
          if (true) NoticeCard(title: 'Text'),
          // ...notice.map((n) => NoticeCard(title: n)),
          SizedBox(height: 28.h),
        ],
      ),
    );
  }
}
