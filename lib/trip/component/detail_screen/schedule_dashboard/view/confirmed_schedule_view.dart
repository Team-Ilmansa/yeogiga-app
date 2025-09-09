import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/schedule/model/schedule_model.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
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
        final confirmed = ref.watch(confirmScheduleProvider).valueOrNull;
        if (confirmed == null) {
          // 최초 진입 시 state가 null이면 fetchAll을 한 번만 호출
          final tripState = ref.read(tripProvider).valueOrNull;
          if (tripState is TripModel) {
            final tripId = tripState.tripId;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(confirmScheduleProvider.notifier).fetchAll(tripId);
            });
          }
          return const Center(child: CircularProgressIndicator());
        }
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            SliverToBoxAdapter(
              child: DaySelector(
                itemCount: dynamicDays.length + 1, // +1 for 전체
                selectedIndex: selectedDayIndex,
                onChanged: onDaySelected,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 6.h)),
            //여기
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
        children: [
          if (hasPlaces)
            // Consumer로 감싸 ref를 스코프 내에서 안전하게 사용
            Consumer(
              builder: (context, ref, _) {
                // tripProvider에서 tripId 추출
                final tripState = ref.watch(tripProvider).valueOrNull;
                final tripId =
                    (tripState is TripModel) ? tripState.tripId : null;

                // DnD(드래그&드롭) 및 슬라이드 삭제가 가능한 확정 일정 리스트
                return ReorderableListView.builder(
                  shrinkWrap: true, // ExpansionTile 내부에서 스크롤 충돌 방지
                  physics: const NeverScrollableScrollPhysics(), // 외부 스크롤만 허용
                  key: ValueKey(daySchedule.day), // 일차별로 고유 key 부여
                  itemCount: daySchedule.places.length,
                  // 순서 변경 시 호출: 서버에 변경된 순서(placeId 리스트) 전달 & 최신화
                  onReorder: (oldIndex, newIndex) async {
                    if (tripId == null) return;
                    // 현재 리스트 복사 후 순서 변경
                    final places = List.of(daySchedule.places);
                    final moved = places.removeAt(oldIndex);
                    places.insert(
                      newIndex > oldIndex ? newIndex - 1 : newIndex,
                      moved,
                    );
                    // 변경된 순서의 placeId만 추출
                    final orderedPlaceIds = places.map((p) => p.id).toList();
                    // 서버에 순서 반영 및 해당 일차만 최신화
                    await ref
                        .read(confirmScheduleProvider.notifier)
                        .reorderAndRefreshDaySchedule(
                          tripId: tripId.toInt(),
                          tripDayPlaceId: daySchedule.id,
                          day: daySchedule.day,
                          orderedPlaceIds: orderedPlaceIds,
                        );
                  },
                  // 드래그 피드백 커스텀: 배경 투명 + 우측 파란 테두리 강조
                  proxyDecorator: (child, index, animation) {
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border(
                          right: BorderSide(
                            color: Color(0xff8287ff),
                            width: 4.0,
                          ),
                        ),
                      ),
                      child: child,
                    );
                  },
                  // 각 일정 아이템 렌더링 (슬라이드 삭제 포함)
                  itemBuilder: (context, index) {
                    final place = daySchedule.places[index];
                    return Slidable(
                      key: ValueKey(place.id), // DnD/슬라이드 모두를 위한 고유 key
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          // 오른쪽으로 슬라이드 시 삭제 버튼
                          SlidableAction(
                            onPressed: (_) async {
                              if (tripId != null) {
                                // 서버에서 삭제 및 상태 최신화
                                await ref
                                    .read(confirmScheduleProvider.notifier)
                                    .deletePlace(
                                      tripId: tripId,
                                      tripDayPlaceId: daySchedule.id,
                                      placeId: place.id,
                                    );
                              }
                            },
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: '삭제',
                            flex: 1,
                          ),
                        ],
                      ),
                      // 실제 일정 정보 표시 위젯
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          if (tripId != null) {
                            await ref
                                .read(confirmScheduleProvider.notifier)
                                .markAndRefreshPlaceVisited(
                                  tripId: tripId,
                                  tripDayPlaceId: daySchedule.id,
                                  placeId: place.id,
                                  day: daySchedule.day,
                                  isVisited: !place.isVisited, // 토글
                                );
                          }
                        },
                        child: ScheduleItem(
                          key: ValueKey(place.id),
                          title: place.name,
                          category: place.placeType,
                          time: null, // 필요시 시간 표시 가능
                          done: place.isVisited,
                        ),
                      ),
                    );
                  },
                );
              },
            )
          else
            Center(
              child: Text(
                '등록된 일정이 없습니다.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xffc6c6c6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Consumer(
            builder: (context, ref, _) {
              final tripState = ref.watch(tripProvider).valueOrNull;
              // TripStatus.COMPLETED일 때는 버튼 미노출
              final isCompleted =
                  tripState is TripModel &&
                  tripState.status.toString().contains('COMPLETED');
              if (isCompleted) return SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Builder(
                  builder:
                      (buttonContext) => TextButton(
                        onPressed: () {
                          // day와 dayId(id) 모두 전달
                          GoRouter.of(buttonContext).push(
                            '/naverPlaceMapScreen?day=${daySchedule.day}&dayId=${daySchedule.id}',
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          splashFactory: NoSplash.splashFactory,
                        ),
                        child: Text(
                          '+ 일정 담으러 가기',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: const Color(0xff8287ff),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
