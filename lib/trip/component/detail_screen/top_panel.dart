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
        final tripState = ref.watch(tripProvider).valueOrNull;
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
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                tripStatusText,
                style: TextStyle(
                  color: const Color(0xff8287ff),
                  fontSize: 14.sp,
                  height: 1.4,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                tripTitle,
                style: TextStyle(
                  color: const Color(0xff313131),
                  fontWeight: FontWeight.w700,
                  fontSize: 28.sp,
                  height: 1.4,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 8.h),
              TripNameCardByAsset(
                assetUrl: 'asset/icon/marker-pin-01.svg',
                name: tripCity,
                color: const Color(0xff7d7d7d),
              ),
              SizedBox(height: 4.h),
              TripNameCardByAsset(
                assetUrl: 'asset/icon/calendar.svg',
                name: tripDate,
                color: const Color(0xff7d7d7d),
              ),
              SizedBox(height: 4.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'asset/icon/user-02.svg',
                    width: 20.w,
                    height: 20.h,
                    color: const Color(0xff7d7d7d),
                  ),
                  SizedBox(width: 4.w),
                  ...List.generate(
                    memberCount,
                    (_) => Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: Icon(
                        Icons.circle,
                        size: 18.sp,
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
