import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yeogiga/common/component/trip_name_card.dart';

class PastTripCardList extends StatelessWidget {
  const PastTripCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: ListView.separated(
        primary: false, // <- 세로 스크롤 우선
        shrinkWrap: true, // <- 높이 맞춤
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(width: 12),
        itemBuilder: (context, index) {
          return PastTripCard();
        },
      ),
    );
  }
}

class PastTripCard extends StatelessWidget {
  const PastTripCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/img/home/sky.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "여행이름",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 5),
              TripNameCardByAsset(
                assetUrl: 'asset/icon/marker-pin-01.svg',
                name: '경주시, 포항시',
                color: Colors.white,
              ),
              TripNameCardByAsset(
                assetUrl: 'asset/icon/calendar.svg',
                name: "2025.03.17 - 2025.03.20",
                color: Colors.white,
              ),

              SizedBox(height: 3),
              Row(
                children: [
                  SvgPicture.asset(
                    'asset/icon/user-02.svg',
                    width: 17,
                    height: 17,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  ...List.generate(
                    4,
                    (_) => Padding(
                      padding: const EdgeInsets.only(right: 1),
                      child: Icon(Icons.circle, size: 18, color: Colors.white),
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
