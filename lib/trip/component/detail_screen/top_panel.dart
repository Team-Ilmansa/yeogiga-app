import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yeogiga/common/component/trip_name_card.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

class TopPanel extends StatelessWidget {
  const TopPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final tripState = ref.watch(tripProvider);
        // 상태 텍스트
        String tripStatusText = '진행중인 여행';
        if (tripState is SettingTripModel) {
          tripStatusText = '확정되지 않은 여행';
        } else if (tripState is PlannedTripModel) {
          tripStatusText = '계획된 여행';
        } else if (tripState is InProgressTripModel) {
          tripStatusText = '진행중인 여행';
        } else if (tripState is CompletedTripModel) {
          tripStatusText = '종료된 여행';
        }
        // 여행이름
        String tripTitle = '미정';
        if (tripState is TripModel && tripState.title.isNotEmpty) {
          tripTitle = tripState.title;
        }
        // 도시
        String tripCity = '미정';
        if (tripState is TripModel &&
            tripState.city != null &&
            tripState.city!.isNotEmpty) {
          tripCity = tripState.city!;
        }
        // 날짜
        String tripDate = '미정';
        if (tripState is TripModel &&
            tripState.startedAt != null &&
            tripState.endedAt != null) {
          final startStr =
              tripState.startedAt!.length >= 10
                  ? tripState.startedAt!.substring(0, 10)
                  : tripState.startedAt!;
          final endStr =
              tripState.endedAt!.length >= 10
                  ? tripState.endedAt!.substring(0, 10)
                  : tripState.endedAt!;
          tripDate = '$startStr - $endStr';
        }
        // 멤버 수
        int memberCount = 0;
        if (tripState is TripModel && tripState.members.isNotEmpty) {
          memberCount = tripState.members.length;
        }

        return Padding(
          padding: EdgeInsets.all(48.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                tripStatusText,
                style: TextStyle(
                  color: const Color(0xff8287ff),
                  fontSize: 42.sp,
                  letterSpacing: -0.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                tripTitle,
                style: TextStyle(
                  color: const Color(0xff313131),
                  fontWeight: FontWeight.w700,
                  fontSize: 84.sp,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 30.h),
              TripNameCardByAsset(
                assetUrl: 'asset/icon/marker-pin-01.svg',
                name: tripCity,
                color: const Color(0xff7d7d7d),
              ),
              SizedBox(height: 9.h),
              TripNameCardByAsset(
                assetUrl: 'asset/icon/calendar.svg',
                name: tripDate,
                color: const Color(0xff7d7d7d),
              ),
              SizedBox(height: 18.h),
              Row(
                children: [
                  SvgPicture.asset(
                    'asset/icon/user-02.svg',
                    width: 51.w,
                    height: 51.h,
                    color: const Color(0xff7d7d7d),
                  ),
                  SizedBox(width: 15.w),
                  ...List.generate(
                    memberCount,
                    (_) => Padding(
                      padding: EdgeInsets.only(right: 3.w),
                      child: Icon(
                        Icons.circle,
                        size: 54.sp,
                        color: const Color.fromARGB(255, 235, 235, 235),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
