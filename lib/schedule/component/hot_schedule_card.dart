import 'package:flutter/material.dart';
import 'package:yeogiga/schedule/component/tag_card.dart';

class HotScheduleCardGridList extends StatelessWidget {
  const HotScheduleCardGridList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GridView.builder(
        primary: false, // <- 세로 스크롤 우선
        shrinkWrap: true, // <- 높이 맞춤
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
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
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120,
        width: 120,
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('asset/img/home/sky.jpg', fit: BoxFit.cover),
            ),
            Positioned(bottom: 12, left: 12, child: TagCard(label: "#tag")),
          ],
        ),
      ),
    );
  }
}
