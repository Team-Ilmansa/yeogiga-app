import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/notice/component/notice_card.dart';
import 'package:yeogiga/notice/component/notice_card_ping.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

class NoticeListScreen extends StatefulWidget {
  static String get routeName => 'noticeListScreen';
  const NoticeListScreen({super.key});

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
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
          final tripState = ref.watch(tripProvider).valueOrNull;

          String tripTitle = '미정';
          if (tripState is TripModel && tripState.title.isNotEmpty) {
            tripTitle = tripState.title;
          }

          return Column(
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
              Text(
                '지난 공지',
                style: TextStyle(
                  fontSize: 16.sp,
                  height: 1.4,
                  letterSpacing: -0.3,
                  color: Color(0xff313131),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
