import 'package:flutter/material.dart';
import 'package:yeogiga/schedule/component/tag_card.dart';

class RecommendScheduleCardList extends StatelessWidget {
  const RecommendScheduleCardList({super.key});

  @override
  Widget build(BuildContext context) {
    final tags = ['태그', '태그', '태그'];
    return SizedBox(
      height: 180,
      child: ListView.builder(
        primary: false, // <- 세로 스크롤 우선
        shrinkWrap: true, // <- 높이 맞춤
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
      width: 380,
      margin: const EdgeInsets.only(right: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(child: Image.asset(imagePath, fit: BoxFit.cover)),
            Positioned(
              bottom: 10,
              left: 12,
              right: 12,
              child: Wrap(
                spacing: 6,
                children: tags.map((tag) => TagCard(label: "#$tag")).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
