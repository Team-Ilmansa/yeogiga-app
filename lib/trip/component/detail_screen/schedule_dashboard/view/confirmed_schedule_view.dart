import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/schedule/component/schedule_item.dart';

class ConfirmedScheduleView extends StatelessWidget {
  final List<String> dynamicDays;
  final int selectedDayIndex;
  final void Function(int) onDaySelected;

  const ConfirmedScheduleView({
    super.key,
    required this.dynamicDays,
    required this.selectedDayIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final confirmed = ref.watch(confirmScheduleProvider);
        if (confirmed == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 40.h)),
            SliverToBoxAdapter(
              child: DaySelector(
                itemCount: dynamicDays.length + 1, // +1 for 전체
                selectedIndex: selectedDayIndex,
                onChanged: onDaySelected,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 20.h)),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final schedules = confirmed.schedules;
                if (selectedDayIndex == 0) {
                  // 전체 보기: 모든 Day
                  final daySchedule = schedules.firstWhere(
                    (s) => s.day == index + 1,
                    orElse:
                        () => ConfirmedDayScheduleModel(
                          id: '',
                          day: index + 1,
                          places: [],
                        ),
                  );
                  return _buildExpansionTile(daySchedule, 'Day ${index + 1}');
                } else {
                  // 선택된 Day만 보기
                  if (index == selectedDayIndex - 1) {
                    final daySchedule = schedules.firstWhere(
                      (s) => s.day == index + 1,
                      orElse:
                          () => ConfirmedDayScheduleModel(
                            id: '',
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
    ConfirmedDayScheduleModel daySchedule,
    String dayLabel,
  ) {
    final hasPlaces = daySchedule.places.isNotEmpty;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 42.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(54.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24.r,
            offset: Offset(0, 12.h),
          ),
        ],
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(54.r),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(54.r),
        ),
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          child: Text(
            dayLabel,
            style: TextStyle(
              fontSize: 48.sp,
              color: Color(0xff7d7d7d),
              letterSpacing: -0.3,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        children: [
          if (hasPlaces)
            ...daySchedule.places.map(
              (place) => ScheduleItem(
                title: place.name,
                time: null, // 필요시 시간 필드 추가
                done: place.isVisited,
              ),
            )
          else
            Center(
              child: Text(
                '등록된 일정이 없습니다.',
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
                      // day와 dayId(id) 모두 전달
                      GoRouter.of(buttonContext).push('/naverPlaceMapScreen?day=${daySchedule.day}&dayId=${daySchedule.id}');
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
    );
  }
}
