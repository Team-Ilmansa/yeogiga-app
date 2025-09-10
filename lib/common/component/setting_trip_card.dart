import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/trip/model/trip_model.dart';

class SettingTripCardList extends StatelessWidget {
  final List<TripModel?> trips;
  final void Function(int tripId)? onTap;

  const SettingTripCardList({super.key, required this.trips, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return Center(
        child: Text(
          '설정 중인 여행이 없습니다.',
          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
        ),
      );
    }
    return SizedBox(
      height: 112.h,
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
          return SettingTripCard(
            title: trip.title,
            city: trip.city,
            startedAt: trip.startedAt,
            endedAt: trip.endedAt,
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

class SettingTripCard extends StatelessWidget {
  final String title;
  final String? city;
  final String? startedAt;
  final String? endedAt;
  final VoidCallback? onTap;

  const SettingTripCard({
    super.key,
    required this.title,
    required this.city,
    required this.startedAt,
    required this.endedAt,
    this.onTap,
  });

  String _formatDate(String date) {
    try {
      final d = DateTime.parse(date);
      return "${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}";
    } catch (_) {
      if (date.contains('T')) return date.split('T')[0].replaceAll('-', '.');
      return date.replaceAll('-', '.');
    }
  }

  String _getDaysUntilTrip() {
    if (startedAt == null) return '-??';
    try {
      final startDate = DateTime.parse(startedAt!);
      final now = DateTime.now();
      final difference = startDate.difference(now).inDays;
      if (difference < -1) {
        return '+${(-difference - 1).toString()}'; // D+숫자
      } else if (difference < 0) {
        return '-0';
      } else {
        return '-${(difference + 1).toString()}'; // D-숫자
      }
    } catch (_) {
      return '-??';
    }
  }

  @override
  Widget build(BuildContext context) {
    String cityText = (city == null || city!.isEmpty) ? '미정' : city!;
    String dateText;
    if (startedAt == null || endedAt == null) {
      dateText = '미정';
    } else {
      dateText = '${_formatDate(startedAt!)}-${_formatDate(endedAt!)}';
    }

    final daysLeft = _getDaysUntilTrip();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 340.w,
        height: 112.h,
        padding: EdgeInsets.fromLTRB(16.w, 15.h, 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          color: Color(0xffe6e7ff),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 55.w,
                  height: 28.h,
                  padding: EdgeInsets.symmetric(
                    horizontal: 11.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'D$daysLeft',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Color(0xFF8287ff),
                        height: 1.4,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    color: Color(0xff313131),
                    fontWeight: FontWeight.w700,
                    fontSize: 22.sp,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                SvgPicture.asset(
                  'asset/icon/marker-pin-01.svg',
                  width: 18.w,
                  height: 18.h,
                ),
                SizedBox(width: 8.w),
                Text(
                  cityText,
                  style: TextStyle(
                    color: Color(0xff7d7d7d),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                SvgPicture.asset(
                  'asset/icon/calendar.svg',
                  width: 18.w,
                  height: 18.h,
                ),
                SizedBox(width: 8.w),
                Text(
                  dateText,
                  style: TextStyle(
                    color: Color(0xff7d7d7d),
                    fontSize: 14.sp,
                    height: 1.4,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
