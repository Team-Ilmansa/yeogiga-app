import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/schedule/component/schedule_item.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/trip/component/detail_screen/schedule_dashboard/completed_trip_mini_map.dart';
import 'package:yeogiga/trip/trip_map/end/end_trip_map.dart';

class CompletedScheduleView extends StatefulWidget {
  final List<String> dynamicDays;

  const CompletedScheduleView({super.key, required this.dynamicDays});

  @override
  State<CompletedScheduleView> createState() => _CompletedScheduleViewState();
}

class _CompletedScheduleViewState extends State<CompletedScheduleView> {
  int selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final completedAsync = ref.watch(completedScheduleProvider);
        return completedAsync.when(
          data: (data) {
            if (data == null) {
              return const Center(
                child: Text(
                  '완료된 일정이 없습니다.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }
            final schedules = data.data;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                //TODO: 날짜 선택기
                SliverToBoxAdapter(
                  child: DaySelector(
                    itemCount: widget.dynamicDays.length + 1, // +1 for 전체
                    selectedIndex: selectedDayIndex,
                    onChanged: (index) {
                      setState(() {
                        selectedDayIndex = index;
                      });
                    },
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12.h)),
                //TODO: 미니맵
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 2,
                            offset: Offset(0, 0),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: CompletedTripMiniMap(
                        dayPlaceModels:
                            selectedDayIndex == 0
                                ? schedules
                                : schedules
                                    .where((s) => s.day == selectedDayIndex)
                                    .toList(),
                        onTap: () async {
                          GoRouter.of(
                            context,
                          ).pushNamed(EndTripMapScreen.routeName);
                        },
                      ),
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
                      return _buildExpansionTile(
                        daySchedule,
                        'Day ${index + 1}',
                      );
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
                  }, childCount: widget.dynamicDays.length),
                ),
              ],
            );
          },
          loading:
              () => const Center(
                child: CircularProgressIndicator(color: Color(0xff8287ff)),
              ),
          error:
              (error, stackTrace) => Center(
                child: Text(
                  '데이터를 불러오는데 실패했습니다: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
        );
      },
    );
  }

  Widget _buildExpansionTile(
    CompletedTripDayPlaceModel daySchedule,
    String dayLabel,
  ) {
    final hasPlaces = daySchedule.places.isNotEmpty;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 2,
              offset: Offset(0, 0),
              spreadRadius: 0,
            ),
          ],
        ),
        child: ExpansionTile(
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(16.r),
          // ),
          // collapsedShape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(16.r),
          // ),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          minTileHeight: 62.h,
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
                          category: place.type,
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
      ),
    );
  }
}
