import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/common/component/trip_name_card.dart';

class PastTripCardList extends StatelessWidget {
  const PastTripCardList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1080.h,
      child: ListView.separated(
        primary: false, // <- 세로 스크롤 우선
        shrinkWrap: true, // <- 높이 맞춤
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 48.w),
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(width: 36.w),
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
      borderRadius: BorderRadius.circular(60.r),
      child: Container(
        width: 960.w,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/img/home/sky.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(48.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "여행이름",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 84.sp,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 15.h),
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

              SizedBox(height: 9.h),
              Row(
                children: [
                  SvgPicture.asset(
                    'asset/icon/user-02.svg',
                    width: 51.w,
                    height: 51.h,
                    color: Colors.white,
                  ),
                  SizedBox(width: 15.w),
                  ...List.generate(
                    4,
                    (_) => Padding(
                      padding: EdgeInsets.only(right: 3.w),
                      child: Icon(Icons.circle, size: 54.sp, color: Colors.white),
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
