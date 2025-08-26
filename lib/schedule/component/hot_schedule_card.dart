import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/schedule/component/tag_card.dart';

class HotScheduleCardGridList extends StatelessWidget {
  const HotScheduleCardGridList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 267.h,
      child: GridView.builder(
        primary: false, // <- 세로 스크롤 우선
        shrinkWrap: true, // <- 높이 맞춤
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 11.w,
          crossAxisSpacing: 11.w,
          childAspectRatio: 1,
        ),
        itemCount: 10,
        itemBuilder: (_, i) => HotScheduleCard(),
      ),
    );
  }
}

class HotScheduleCard extends StatelessWidget {
  const HotScheduleCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 107.h,
        width: 107.w,
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('asset/img/home/sky.jpg', fit: BoxFit.cover),
            ),
            Positioned(bottom: 11.h, left: 11.w, child: TagCard(label: "#tag")),
          ],
        ),
      ),
    );
  }
}
