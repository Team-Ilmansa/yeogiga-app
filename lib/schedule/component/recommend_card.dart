import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/schedule/component/tag_card.dart';

class RecommendScheduleCardList extends StatelessWidget {
  const RecommendScheduleCardList({super.key});

  @override
  Widget build(BuildContext context) {
    final tags = ['태그', '태그', '태그'];
    return SizedBox(
      height: 540.h,
      child: ListView.builder(
        primary: false, // <- 세로 스크롤 우선
        shrinkWrap: true, // <- 높이 맞춤
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 48.w),
        itemCount: 5,
        itemBuilder:
            (_, i) => RecommendScheduleCard(
              tags: tags,
              imagePath: 'asset/img/home/sky.jpg',
            ),
      ),
    );
  }
}

class RecommendScheduleCard extends StatelessWidget {
  final List<String> tags;
  final String imagePath;

  const RecommendScheduleCard({
    super.key,
    required this.tags,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1140.w,
      margin: EdgeInsets.only(right: 36.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(48.r),
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.cover)),
            Positioned(
              bottom: 30.h,
              left: 36.w,
              right: 36.w,
              child: Wrap(
                spacing: 18.w,
                children: tags.map((tag) => TagCard(label: "#$tag")).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
