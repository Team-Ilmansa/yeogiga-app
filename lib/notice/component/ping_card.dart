import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/notice/model/ping_model.dart';
import 'package:yeogiga/notice/provider/ping_provider.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';

class LeaderPingCard extends ConsumerWidget {
  final PingModel ping;

  const LeaderPingCard({super.key, required this.ping});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Slidable(
      key: ValueKey('notice_ping_${ping.place}'),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.16,
        children: [
          // 삭제 버튼
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                left: 12.w,
                right: 4.w,
                top: 16.h,
                bottom: 16.h,
              ),
              decoration: BoxDecoration(
                color: Color(0xfff0f0f0),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18.r),
                  onTap: () async {
                    final tripState = ref.read(tripProvider).valueOrNull;
                    if (tripState is TripModel) {
                      final result = await ref
                          .read(pingProvider.notifier)
                          .deletePing(tripId: tripState.tripId);

                      if (!result['success']) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('핑 삭제에 실패했습니다.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    }
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      '삭제',
                      style: TextStyle(
                        color: const Color(0xffff0000),
                        fontSize: 14.sp,
                        height: 1.4,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          // IngMap으로 이동하면서 ping 좌표 정보 전달
          context.push('/ingTripMap', extra: {
            'focusPing': true,
            'pingLatitude': ping.latitude,
            'pingLongitude': ping.longitude,
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xffe6e7ff),
            borderRadius: BorderRadius.circular(14.r),
          ),
          height: 60.h,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                SvgPicture.asset(
                  'asset/icon/ping.svg',
                  width: 24.w,
                  height: 24.h,
                ),
                SizedBox(width: 8.w),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      ping.place,
                      style: TextStyle(
                        fontSize: 16.sp,
                        height: 1.4,
                        letterSpacing: -0.3,
                        color: Color(0xff7d7d7d),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${ping.time.hour}시 ${ping.time.minute.toString().padLeft(2, '0')}분',
                      style: TextStyle(
                        fontSize: 12.sp,
                        height: 1.5,
                        letterSpacing: -0.36,
                        color: Color(0xff8287ff),
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

class PingCard extends StatelessWidget {
  final PingModel ping;

  const PingCard({super.key, required this.ping});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // IngMap으로 이동하면서 ping 좌표 정보 전달
        context.push('/ingTripMap', extra: {
          'focusPing': true,
          'pingLatitude': ping.latitude,
          'pingLongitude': ping.longitude,
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xffe6e7ff),
          borderRadius: BorderRadius.circular(14.r),
        ),
        height: 60.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              SvgPicture.asset(
                'asset/icon/ping.svg',
                width: 24.w,
                height: 24.h,
              ),
              SizedBox(width: 8.w),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    ping.place,
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.4,
                      letterSpacing: -0.3,
                      color: Color(0xff7d7d7d),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${ping.time.hour}시 ${ping.time.minute.toString().padLeft(2, '0')}분',
                    style: TextStyle(
                      fontSize: 12.sp,
                      height: 1.5,
                      letterSpacing: -0.3,
                      color: Color(0xff8287ff),
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
