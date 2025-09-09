import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
        final scheduleAsync = ref.watch(pendingScheduleProvider).valueOrNull;
        if (scheduleAsync == null) {
          // 최초 진입 시 state가 null이면 fetchAll을 한 번만 호출
          final tripState = ref.read(tripProvider).valueOrNull;
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
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            SliverToBoxAdapter(
              child: DaySelector(
                itemCount: dynamicDays.length + 1, // +1 for '여행 전체'
                selectedIndex: selectedDayIndex,
                onChanged: onDaySelected,
              ),
            ),
            SliverToBoxAdapter(child: SizedBox(height: 6.h)),
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
                  return _buildExpansionTiles(daySchedule, 'Day ${index + 1}');
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
                    return _buildExpansionTiles(
                      daySchedule,
                      dynamicDays[index],
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

  // pending 전용
  Widget _buildExpansionTiles(
    PendingDayScheduleModel daySchedule,
    String dayLabel,
  ) {
    final hasPlaces = daySchedule.places.isNotEmpty;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExpansionTile(
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
            trailing: const Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xff7d7d7d),
            ),
            children: [
              //TODO: Consumer를 children에 직접 넣으면 타입 오류가 발생하므로, 즉시실행 함수로 감싸서 List<Widget>만 children에 들어가도록 함
              ...(() {
                return [
                  // Riverpod의 ref를 안전하게 사용하기 위해 children 전체를 Consumer로 감쌈
                  Consumer(
                    builder: (context, ref, _) {
                      // 일정(place)이 있을 때와 없을 때 분기 처리
                      if (hasPlaces) {
                        // DnD(드래그&드롭)와 슬라이드 삭제를 동시에 지원하는 리스트
                        return ReorderableListView.builder(
                          shrinkWrap: true, // ExpansionTile 내부에서 스크롤 충돌 방지
                          physics:
                              const NeverScrollableScrollPhysics(), // 부모 스크롤만 사용
                          key: ValueKey(daySchedule.day), // 각 day별로 고유 키 부여
                          itemCount: daySchedule.places.length,
                          proxyDecorator: (child, index, animation) {
                            // 드래그 중인 아이템에만 파란색 border, 배경색 없음(투명)
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border(
                                  right: BorderSide(
                                    color: Colors.blue,
                                    width: 4.0,
                                  ),
                                ),
                              ),
                              child: child,
                            );
                          },
                          // buildDefaultDragHandles:
                          //     false, // 드래그 시 기본 피드백(색상 변화) 제거
                          // 순서 변경 시 호출: places 리스트를 복사해 순서 변경 후, placeId만 추출해서 API 호출
                          onReorder: (oldIndex, newIndex) async {
                            final places = List.of(daySchedule.places);
                            final moved = places.removeAt(oldIndex);
                            places.insert(
                              newIndex > oldIndex ? newIndex - 1 : newIndex,
                              moved,
                            );
                            final orderedPlaceIds =
                                places.map((p) => p.id).toList(); // 순서만 추출
                            final tripState =
                                ref
                                    .read(tripProvider)
                                    .valueOrNull; // tripId는 provider에서 안전하게 가져옴
                            final tripId =
                                (tripState is SettingTripModel)
                                    ? tripState.tripId.toString()
                                    : '';
                            // 순서 변경 API 호출 및 상태 동기화
                            await ref
                                .read(pendingScheduleProvider.notifier)
                                .reorderPlaces(
                                  tripId: tripId,
                                  day: daySchedule.day,
                                  orderedPlaceIds: orderedPlaceIds,
                                );
                          },
                          // 각 place를 Slidable로 감싸 슬라이드 삭제 지원
                          itemBuilder: (context, index) {
                            final place = daySchedule.places[index];
                            return Slidable(
                              key: ValueKey(place.id),
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) async {
                                      final tripState =
                                          ref.read(tripProvider).valueOrNull;
                                      final tripId =
                                          (tripState is SettingTripModel)
                                              ? tripState.tripId.toString()
                                              : '';
                                      await ref
                                          .read(
                                            pendingScheduleProvider.notifier,
                                          )
                                          .deletePlace(
                                            tripId: tripId,
                                            day: daySchedule.day,
                                            placeId: place.id,
                                          );
                                    },
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: '삭제',
                                    flex: 1,
                                  ),
                                ],
                              ),
                              child: ScheduleItem(
                                title: place.name,
                                category: place.placeCategory,
                                time: null,
                                done: false,
                              ),
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: Text(
                            '아직 예정된 일정이 없어요',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xffc6c6c6),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ];
              })(),
              Padding(
                padding: EdgeInsets.only(bottom: 6.h),
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
                            fontSize: 14.sp,
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
