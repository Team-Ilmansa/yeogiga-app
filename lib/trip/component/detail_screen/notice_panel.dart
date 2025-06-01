import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/trip/component/detail_screen/notice_card.dart';
import 'package:yeogiga/trip/component/detail_screen/notice_card_ping.dart';

class NoticePanel extends StatelessWidget {
  const NoticePanel({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> pingNotice = [
      {'title': '집결 1', 'time': '11:00'},
      {'title': '집결 2', 'time': '13:30'},
      {'title': '집결 3', 'time': '16:45'},
    ];

    List<String> notice = ['집결 시간 변경', '숙소 체크인 안내', '저녁 식사 장소 공지'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 48.w),
      child: Column(
        children: [
          SizedBox(height: 3.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '현재 공지',
                style: TextStyle(
                  fontSize: 60.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  color: const Color(0xff313131),
                ),
              ),
              Text(
                '지난 공지 전체보기',
                style: TextStyle(
                  fontSize: 39.sp,
                  letterSpacing: -0.6,
                  color: const Color.fromARGB(255, 193, 193, 193),
                ),
              ),
            ],
          ),
          // TODO: 핑 공지 있으면
          if (true) NoticeCardPing(title: 'Text', time: 'Time'),
          // ...pingNotice.map(
          //   (item) => NoticeCardPing(title: item['title']!, time: item['time']!),
          // ),
          // TODO: 일반 공지 있으면
          if (true) NoticeCard(title: 'Text'),
          // ...notice.map((n) => NoticeCard(title: n)),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }
}
