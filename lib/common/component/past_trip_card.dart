import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/common/component/trip_name_card.dart';

import 'package:yeogiga/trip/model/trip_model.dart';

class PastTripCardList extends StatelessWidget {
  final List<TripModel?> trips;
  final void Function(int tripId)? onTap;
  const PastTripCardList({super.key, required this.trips, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return Center(
        child: Text(
          '여행 내역이 없습니다.',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      );
    }
    return SizedBox(
      height: 321.h,
      child: ListView.separated(
        primary: false,
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        itemCount: trips.length,
        separatorBuilder: (_, __) => SizedBox(width: 11.w),
        itemBuilder: (context, index) {
          final trip = trips[index];
          if (trip == null) return const SizedBox.shrink();
          return PastTripCard(
            title: trip.title,
            city: trip.city,
            startedAt: trip.startedAt,
            endedAt: trip.endedAt,
            memberCount: trip.members.length,
            tripId: trip.tripId,
            onTap: () {
              if (onTap != null && trip.tripId != null) {
                onTap!(trip.tripId!);
              }
            },
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
  final VoidCallback? onTap;
  final int? tripId; // Hero tag용

  const PastTripCard({
    super.key,
    required this.title,
    required this.city,
    required this.startedAt,
    required this.endedAt,
    required this.memberCount,
    this.onTap,
    this.tripId,
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
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          width: 286.w,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('asset/img/home/sky.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: EdgeInsets.all(14.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 25.sp,
                    letterSpacing: -0.1,
                  ),
                ),
                SizedBox(height: 4.h),
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

                SizedBox(height: 3.h),
                Row(
                  children: [
                    SvgPicture.asset(
                      'asset/icon/user-02.svg',
                      width: 15.w,
                      height: 15.h,
                      color: Colors.white,
                    ),
                    SizedBox(width: 4.w),
                    ...List.generate(
                      memberCount,
                      (_) => Padding(
                        padding: EdgeInsets.only(right: 1.w),
                        child: Icon(
                          Icons.circle,
                          size: 16.sp,
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
      ),
    );
  }
}
