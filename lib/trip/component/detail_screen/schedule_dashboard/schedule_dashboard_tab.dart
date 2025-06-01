import 'package:flutter/material.dart' hide ExpansionPanel;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/common/component/expansion_panel.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

class ScheduleDashboardTab extends ConsumerStatefulWidget {
  const ScheduleDashboardTab({super.key});

  @override
  ConsumerState<ScheduleDashboardTab> createState() =>
      _ScheduleDashboardTabState();
}

class _ScheduleDashboardTabState extends ConsumerState<ScheduleDashboardTab> {
  final List<String> days = List.generate(10, (index) => 'Day ${index + 1}');
  int selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripProvider);
    if (tripState is SettingTripModel &&
        (tripState.startedAt == null || tripState.endedAt == null)) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 100.h),
          SvgPicture.asset(
            'asset/icon/add_schedule.svg',
            height: 168.h,
            width: 168.w,
            color: const Color(0xffc6c6c6),
          ),
          SizedBox(height: 24.h),
          Text(
            '날짜 확정 후 일정을 추가할 수 있어요.',
            style: TextStyle(
              fontSize: 42.sp,
              color: const Color(0xffc6c6c6),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    } else {
      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: SizedBox(height: 40.h)),
          SliverToBoxAdapter(
            child: DaySelector(
              itemCount: days.length + 1, // +1 for '여행 전체'
              selectedIndex: selectedDayIndex,
              onChanged: (index) {
                setState(() {
                  selectedDayIndex = index;
                });
              },
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 20.h)),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (selectedDayIndex == 0) {
                // 전체 보기: 모든 Day
                return ExpansionPanel(dayName: 'Day ${index + 1}');
              } else {
                // 선택된 Day만 보기
                if (index == selectedDayIndex - 1) {
                  return ExpansionPanel(dayName: days[index]);
                } else {
                  return const SizedBox.shrink();
                }
              }
            }, childCount: days.length),
          ),
        ],
      );
    }
  }
}
