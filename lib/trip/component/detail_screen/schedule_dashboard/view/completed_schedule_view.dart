import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/schedule/component/schedule_item.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/trip/component/detail_screen/schedule_dashboard/completed_trip_mini_map.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/trip_map/end/end_trip_map.dart';

class CompletedScheduleView extends StatelessWidget {
  final List<String> dynamicDays;
  final int selectedDayIndex;
  final void Function(int) onDaySelected;

  const CompletedScheduleView({
    super.key,
    required this.dynamicDays,
    required this.selectedDayIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final completed = ref.watch(completedScheduleProvider).valueOrNull;
        if (completed == null) {
          // 최초 진입 시 state가 null이면 fetch를 한 번만 호출
          final tripState = ref.read(tripProvider).valueOrNull;
          if (tripState is TripModel) {
            final tripId = tripState.tripId;
            Future.microtask(() {
              ref.read(completedScheduleProvider.notifier).fetch(tripId);
            });
          }
          return const Center(child: CircularProgressIndicator());
        }
        final schedules = completed.data;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            //TODO: 날짜 선택기
            SliverToBoxAdapter(
              child: DaySelector(
                itemCount: dynamicDays.length + 1, // +1 for 전체
                selectedIndex: selectedDayIndex,
                onChanged: onDaySelected,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            //TODO: 미니맵
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 13.w),
                child: CompletedTripMiniMap(
                  dayPlaceModels:
                      selectedDayIndex == 0
                          ? schedules
                          : schedules
                              .where((s) => s.day == selectedDayIndex)
                              .toList(),
                  onTap: () async {
                    GoRouter.of(context).pushNamed(EndTripMapScreen.routeName);
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 6.h)),
            //TODO: 일정들
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (selectedDayIndex == 0) {
                  // 전체 보기: 모든 Day
                  final daySchedule = schedules.firstWhere(
                    (s) => s.day == index + 1,
                    orElse:
                        () => CompletedTripDayPlaceModel(
                          id: '',
                          day: index + 1,
                          places: [],
                          unmatchedImage: null,
                        ),
                  );
                  return _buildExpansionTile(daySchedule, 'Day ${index + 1}');
                } else {
                  // 선택된 Day만 보기
                  if (index == selectedDayIndex - 1) {
                    final daySchedule = schedules.firstWhere(
                      (s) => s.day == selectedDayIndex,
                      orElse:
                          () => CompletedTripDayPlaceModel(
                            id: '',
                            day: selectedDayIndex,
                            places: [],
                            unmatchedImage: null,
                          ),
                    );
                    return _buildExpansionTile(
                      daySchedule,
                      'Day $selectedDayIndex',
                    );
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
    CompletedTripDayPlaceModel daySchedule,
    String dayLabel,
  ) {
    final hasPlaces = daySchedule.places.isNotEmpty;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(16.r),
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.04),
      //       blurRadius: 2.r,
      //       offset: Offset(0, 4.h),
      //     ),
      //   ],
      // ),
      child: ExpansionTile(
        // shape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(16.r),
        // ),
        // collapsedShape: RoundedRectangleBorder(
        //   borderRadius: BorderRadius.circular(16.r),
        // ),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: const BorderSide(color: Color.fromARGB(255, 221, 221, 221)),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: const BorderSide(color: Color(0xffd9d9d9)),
        ),
        minTileHeight: 55.h,
        title: Text(
          dayLabel,
          style: TextStyle(
            fontSize: 14.sp,
            color: Color(0xff7d7d7d),
            letterSpacing: -0.1,
            fontWeight: FontWeight.w600,
          ),
        ),
        children:
            hasPlaces
                ? daySchedule.places
                    .map(
                      (place) => ScheduleItem(
                        key: ValueKey(place.id),
                        title: place.name,
                        time: null, // 필요시 시간 필드 추가
                        // TODO: 일단은 끝나면 전부 다녀왔다고 표시함.
                        done: true,
                        // subtitle: '${place.latitude}, ${place.longitude}', // 필요시 ScheduleItem에 subtitle 추가
                      ),
                    )
                    .toList()
                : [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Center(
                      child: Text(
                        '등록된 일정이 없습니다.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xffc6c6c6),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
      ),
    );
  }
}
