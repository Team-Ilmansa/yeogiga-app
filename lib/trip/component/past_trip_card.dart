import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/common/component/trip_name_card.dart';

import 'package:yeogiga/trip/model/trip_model.dart';

class PastTripCardList extends StatelessWidget {
  final List<TripModel?> trips;
  const PastTripCardList({super.key, required this.trips});

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return Center(
        child: Text(
          '여행 내역이 없습니다.',
          style: TextStyle(fontSize: 48.sp, color: Colors.grey),
        ),
      );
    }
    return SizedBox(
      height: 1080.h,
      child: ListView.separated(
        primary: false,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 48.w),
        itemCount: trips.length,
        separatorBuilder: (_, __) => SizedBox(width: 36.w),
        itemBuilder: (context, index) {
          final trip = trips[index];
          if (trip == null) return const SizedBox.shrink();
          return PastTripCard(
            title: trip.title,
            city: trip.city,
            startedAt: trip.startedAt,
            endedAt: trip.endedAt,
            memberCount: trip.members.length,
          );
        },
      ),
    );
  }
}

class PastTripCard extends StatelessWidget {
  final String title;
  final String? city;
  final String? startedAt;
  final String? endedAt;
  final int memberCount;

  const PastTripCard({
    super.key,
    required this.title,
    required this.city,
    required this.startedAt,
    required this.endedAt,
    required this.memberCount,
  });

  String _formatDate(String date) {
    // Expecting date like '2025-03-17T00:00:00Z' or '2025-03-17'
    try {
      final d = DateTime.parse(date);
      return "${d.year.toString().padLeft(4, '0')}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}";
    } catch (_) {
      // fallback: just return the date part if possible
      if (date.contains('T')) return date.split('T')[0].replaceAll('-', '.');
      return date.replaceAll('-', '.');
    }
  }

  @override
  Widget build(BuildContext context) {
    String cityText = (city == null || city!.isEmpty) ? '미정' : city!;
    String dateText;
    if (startedAt == null || endedAt == null) {
      dateText = '미정';
    } else {
      dateText = '${_formatDate(startedAt!)} - ${_formatDate(endedAt!)}';
    }
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
                title,
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
                name: cityText,
                color: Colors.white,
              ),
              TripNameCardByAsset(
                assetUrl: 'asset/icon/calendar.svg',
                name: dateText,
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
                    memberCount,
                    (_) => Padding(
                      padding: EdgeInsets.only(right: 3.w),
                      child: Icon(
                        Icons.circle,
                        size: 54.sp,
                        color: Colors.white,
                      ),
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
