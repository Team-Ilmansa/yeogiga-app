import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/schedule/component/schedule_item.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/schedule/provider/pending_schedule_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

class PendingScheduleView extends StatelessWidget {
  final List<String> dynamicDays;
  final int selectedDayIndex;
  final void Function(int) onDaySelected;

  const PendingScheduleView({
    super.key,
    required this.dynamicDays,
    required this.selectedDayIndex,
    required this.onDaySelected,
  });

  List<String> dynamicDaysFromTrip(SettingTripModel trip) {
    final start = DateTime.parse(trip.startedAt!.substring(0, 10));
    final end = DateTime.parse(trip.endedAt!.substring(0, 10));
    final dayCount = end.difference(start).inDays + 1;
    return List.generate(dayCount, (index) => 'Day ${index + 1}');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final scheduleAsync = ref.watch(pendingScheduleProvider);
        if (scheduleAsync == null) {
          // 최초 진입 시 state가 null이면 fetchAll을 한 번만 호출
          final tripState = ref.read(tripProvider);
          if (tripState is SettingTripModel &&
              tripState.startedAt != null &&
              tripState.endedAt != null) {
            final dynamicDays = dynamicDaysFromTrip(tripState);
            final tripId = tripState.tripId;
            final days = List.generate(dynamicDays.length, (i) => i + 1);
            Future.microtask(() {
              ref
                  .read(pendingScheduleProvider.notifier)
                  .fetchAll(tripId.toString(), days);
            });
          }
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 40.h)),
            SliverToBoxAdapter(
              child: DaySelector(
                itemCount: dynamicDays.length + 1, // +1 for '여행 전체'
                selectedIndex: selectedDayIndex,
                onChanged: onDaySelected,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final schedules = scheduleAsync.schedules;
                if (selectedDayIndex == 0) {
                  // 전체 보기: 모든 Day
                  final daySchedule = schedules.firstWhere(
                    (s) => s.day == index + 1,
                    orElse:
                        () =>
                            PendingDayScheduleModel(day: index + 1, places: []),
                  );
                  return _buildExpansionTile(daySchedule, 'Day ${index + 1}');
                } else {
                  // 선택된 Day만 보기
                  if (index == selectedDayIndex - 1) {
                    final daySchedule = schedules.firstWhere(
                      (s) => s.day == index + 1,
                      orElse:
                          () => PendingDayScheduleModel(
                            day: index + 1,
                            places: [],
                          ),
                    );
                    return _buildExpansionTile(daySchedule, dynamicDays[index]);
                  } else {
                    return const SizedBox.shrink();
                  }
                }
              }, childCount: dynamicDays.length),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExpansionTile(
    PendingDayScheduleModel daySchedule,
    String dayLabel,
  ) {
    final hasPlaces = daySchedule.places.isNotEmpty;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 18.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExpansionTile(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(66.r),
              side: const BorderSide(color: Color.fromARGB(255, 221, 221, 221)),
            ),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(66.r),
              side: const BorderSide(color: Color(0xffd9d9d9)),
            ),
            minTileHeight: 186.h,
            title: Text(
              dayLabel,
              style: TextStyle(
                fontSize: 48.sp,
                color: Color(0xff7d7d7d),
                letterSpacing: -0.3,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xff7d7d7d),
            ),
            children: [
              if (hasPlaces)
                ...daySchedule.places.map(
                  (place) => ScheduleItem(
                    title: place.name,
                    time: null, // place에 시간 필드가 있으면 매핑
                    done: false, // pending은 기본적으로 false
                  ),
                )
              else
                Center(
                  child: Text(
                    '아직 예정된 일정이 없어요',
                    style: TextStyle(
                      fontSize: 48.sp,
                      color: const Color(0xffc6c6c6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.h),
                child: Builder(
                  builder:
                      (buttonContext) => TextButton(
                        onPressed: () {
                          // 몇일차 정보(daySchedule.day)를 NaverPlaceMapScreen으로 전달
                          GoRouter.of(
                            buttonContext,
                          ).push('/naverPlaceMapScreen?day=${daySchedule.day}');
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: Text(
                          '+ 일정 담으러 가기',
                          style: TextStyle(
                            fontSize: 48.sp,
                            color: const Color(0xff8287ff),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
