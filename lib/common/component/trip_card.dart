import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/common/component/trip_name_card.dart';
import 'package:yeogiga/common/utils/profile_placeholder_util.dart';
import 'package:yeogiga/trip/model/trip_model.dart';

class TripCardList extends StatelessWidget {
  final List<TripModel?> trips;
  final void Function(int tripId)? onTap;
  const TripCardList({super.key, required this.trips, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (trips.isEmpty) {
      return SizedBox(
        height: 100.h,
        child: Center(
          child: Text(
            '여행 내역이 없습니다.',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey),
          ),
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
          return TripCard(
            title: trip.title,
            city: trip.city,
            startedAt: trip.startedAt,
            endedAt: trip.endedAt,
            members: trip.members,
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

class TripCard extends StatelessWidget {
  final String title;
  final List<String>? city;
  final String? startedAt;
  final String? endedAt;
  final List<TripMember> members;
  final VoidCallback? onTap;
  final int? tripId; // Hero tag용

  const TripCard({
    super.key,
    required this.title,
    required this.city,
    required this.startedAt,
    required this.endedAt,
    required this.members,
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
    String cityText = (city == null || city!.isEmpty) ? '미정' : city!.join(', ');
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
                    if (members.isEmpty)
                      Icon(
                        Icons.person_outline,
                        size: 16.sp,
                        color: Colors.white,
                      )
                    else ...[
                      ...members.take(4).map((member) {
                        final hasImage =
                            member.imageUrl != null &&
                            member.imageUrl!.isNotEmpty;
                        return Padding(
                          padding: EdgeInsets.only(right: 3.w),
                          child: ClipOval(
                            child: SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: hasImage
                                  ? Image.network(
                                      member.imageUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              buildProfileAvatarPlaceholder(
                                                nickname: member.nickname,
                                                size: 16.w,
                                                backgroundColor: Colors.white24,
                                                textColor: Colors.white,
                                              ),
                                    )
                                  : buildProfileAvatarPlaceholder(
                                      nickname: member.nickname,
                                      size: 16.w,
                                      backgroundColor: Colors.white24,
                                      textColor: Colors.white,
                                    ),
                            ),
                          ),
                        );
                      }),
                      if (members.length > 4)
                        Container(
                          width: 22.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '+${members.length - 4}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
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
