import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomeScreen(), debugShowCheckedModeBanner: false);
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2C2C2E),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeAppBar(),
            ScheduleItemList(),
            Container(height: 12, color: Color.fromARGB(255, 66, 65, 65)),
            SizedBox(height: 20),
            SectionTitle("규희님께 딱 맞을 것 같은 스팟"),
            RecommendCardList(),
            SizedBox(height: 30),
            SectionTitle("인기급상승 여행스팟"),
            PopularCardGridList(),
            SizedBox(height: 30),
            SectionTitle("지난여행 돌아보기"),
            PastTravelCardList(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'asset/img/home/sky.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.bottomRight,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Color(0xFF2C2C2E),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '23°, 맑음',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.map_outlined, color: Colors.white),
                      SizedBox(width: 12),
                      Icon(Icons.notifications_none, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            bottom: 10,
            child: Text(
              '규희님,\n경주여행이 3일 남았어요!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduleItemList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            decoration: BoxDecoration(
              color: Color(0xFF1C1C1E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "3월 25일 여행 첫날의 일정",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 12),
                SizedBox(
                  height: 230,
                  child: Stack(
                    children: [
                      ListView.builder(
                        primary: false, // <- 세로 스크롤 우선
                        shrinkWrap: true, // <- 높이 맞춤
                        physics: BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: 5,
                        itemBuilder: (context, index) {
                          return ScheduleItem(
                            title: '대릉원',
                            time: '11:00',
                            imagePath: 'asset/img/home/sky.jpg',
                          );
                        },
                      ),
                      // 개선된 그라데이션: 더 부드럽고 넓은 영역
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 40, // 낮은 높이
                        child: IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0xFF1C1C1E).withOpacity(0.15),
                                  Color(0xFF1C1C1E).withOpacity(0.9),
                                ],
                                stops: [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(0, -20),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6366F1),
                shape: StadiumBorder(),
                minimumSize: Size(90, 35),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                elevation: 0,
              ),
              child: Text(
                "더보기",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduleItem extends StatelessWidget {
  final String title;
  final String time;
  final String imagePath;

  const ScheduleItem({
    required this.title,
    required this.time,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipOval(
                  child: Image.asset(
                    imagePath,
                    width: 26,
                    height: 26,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 3,
                  child: Text(
                    time,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 60,
              padding: EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

class RecommendCardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tags = ['태그', '태그', '태그'];
    return SizedBox(
      height: 160,
      child: ListView.builder(
        primary: false, // <- 세로 스크롤 우선
        shrinkWrap: true, // <- 높이 맞춤
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder:
            (_, i) =>
                RecommendCard(tags: tags, imagePath: 'asset/img/home/sky.jpg'),
      ),
    );
  }
}

class RecommendCard extends StatelessWidget {
  final List<String> tags;
  final String imagePath;

  const RecommendCard({required this.tags, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
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

class TagCard extends StatelessWidget {
  final String label;

  const TagCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 45,
      height: 22,
      decoration: BoxDecoration(
        color: Color(0xFF6366F1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class PopularCardGridList extends StatelessWidget {
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
        itemBuilder: (_, i) => PopularCard(),
      ),
    );
  }
}

class PopularCard extends StatelessWidget {
  const PopularCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      width: 128,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset('asset/img/home/sky.jpg', fit: BoxFit.cover),
      ),
    );
  }
}

class PastTravelCardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 324,
      child: ListView.separated(
        primary: false, // <- 세로 스크롤 우선
        shrinkWrap: true, // <- 높이 맞춤
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(width: 12),
        itemBuilder: (context, index) {
          return PastTravelCard();
        },
      ),
    );
  }
}

class PastTravelCard extends StatelessWidget {
  const PastTravelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 284,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/img/home/sky.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.4),
                Colors.black.withOpacity(0.85),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 3),
                child: Text(
                  "여행이름",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 28,
                  ),
                ),
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  SvgPicture.asset(
                    'asset/icon/marker-pin-01.svg',
                    width: 15,
                    height: 15,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "경주시, 포항시",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              Row(
                children: [
                  SvgPicture.asset(
                    'asset/icon/calendar.svg',
                    width: 15,
                    height: 15,
                  ),
                  SizedBox(width: 4),
                  Text(
                    "2025.03.17 - 2025.03.20",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 3),
              Row(
                children: [
                  SvgPicture.asset(
                    'asset/icon/user-02.svg',
                    width: 15,
                    height: 15,
                  ),
                  SizedBox(width: 3),
                  ...List.generate(
                    4,
                    (_) => Padding(
                      padding: const EdgeInsets.only(right: 1),
                      child: Icon(Icons.circle, size: 15, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
