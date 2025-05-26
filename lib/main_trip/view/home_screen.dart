import 'package:flutter/material.dart';
import 'package:yeogiga/schedule/component/hot_schedule_card.dart';
import 'package:yeogiga/schedule/component/schedule_item.dart';
import 'package:yeogiga/trip/component/past_trip_card.dart';
import 'package:yeogiga/schedule/component/recommend_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(255, 248, 248, 248),
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: SafeArea(
          top: false,
          bottom: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HomeAppBar(),
              Transform.translate(
                offset: Offset(0, -28),
                child: Column(
                  children: [
                    ScheduleItemList(),
                    Container(height: 12, color: Color(0xfff0f0f0)),
                  ],
                ),
              ),
              _SectionTitle("규희님께 딱 맞을 것 같은 스팟"),
              RecommendScheduleCardList(),
              SizedBox(height: 30),
              _SectionTitle("인기급상승 여행스팟"),
              HotScheduleCardGridList(),
              SizedBox(height: 30),
              _SectionTitle("지난여행 돌아보기"),
              PastTripCardList(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 246,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'asset/img/weather/sunnyday.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          // 자연스러운 하얀 그라데이션 → 투명 → 살짝 어두움
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color.fromARGB(20, 255, 255, 255), // 8% 흰색
                    Color.fromARGB(60, 255, 255, 255), // 24% 흰색
                  ],
                  stops: [0.7, 0.85, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 16,
                    left: 16,
                    right: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.wb_sunny_outlined, size: 30),
                          SizedBox(width: 5),
                          Text(
                            '00°',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black.withAlpha(204),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.map_outlined, color: Color(0xff313131)),
                          SizedBox(width: 12),
                          Icon(
                            Icons.notifications_none,
                            color: Color(0xff313131),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
                  child: Text(
                    '오늘은\n경주여행 2일차에요!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ],
            ),

            // Positioned(child: SizedBox(height: 20)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.black,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}
