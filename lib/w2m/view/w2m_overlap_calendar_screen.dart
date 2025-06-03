import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/w2m/provider/trip_w2m_provider.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// 필요시: import 'package:yeogiga/user/provider/user_me_provider.dart';

class W2MOverlapCalendarScreen extends ConsumerStatefulWidget {
  static String get routeName => 'W2mConfirmScreen';
  const W2MOverlapCalendarScreen({super.key});

  @override
  ConsumerState<W2MOverlapCalendarScreen> createState() =>
      _W2MOverlapCalendarScreenState();
}

class _W2MOverlapCalendarScreenState
    extends ConsumerState<W2MOverlapCalendarScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    // tripId를 tripProvider의 상태에서 가져옵니다.
    final tripState = ref.watch(tripProvider);
    int tripId;
    if (tripState is TripModel) {
      tripId = tripState.tripId;
    } else {
      // tripProvider가 비어있을 일은 없으나, 안전하게 처리
      return const Scaffold(body: Center(child: Text('trip 정보가 필요합니다.')));
    }
    final tripW2mAsync = ref.watch(tripW2mProvider(tripId));

    return tripW2mAsync.when(
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('에러: $e'))),
      data: (tripW2m) {
        final now = DateTime.now();
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.black,
                size: 22,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 36.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60.w),
                  child: Text(
                    '여행날짜를\n확정해주세요',
                    style: TextStyle(
                      fontSize: 84.sp,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff222222),
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60.w),
                  child: Text(
                    '날짜는 추후 수정이 가능해요',
                    style: TextStyle(
                      fontSize: 48.sp,
                      color: Color(0xff818181),
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                SizedBox(height: 120.h),
                Expanded(
                  child:
                      tripW2m == null || tripW2m.availabilities == null
                          ? Center(child: Text('데이터 없음'))
                          : Builder(
                            builder: (context) {
                              // 날짜별 겹침 개수 계산 (모든 유저 기준)
                              final overlapMap = <DateTime, int>{};
                              for (final u in tripW2m.availabilities) {
                                for (final dateStr
                                    in (u['availableDates'] as List)) {
                                  final d = DateTime.parse(dateStr);
                                  final dayKey = DateTime(
                                    d.year,
                                    d.month,
                                    d.day,
                                  ); // 시간 정보 제거
                                  overlapMap[dayKey] =
                                      (overlapMap[dayKey] ?? 0) + 1;
                                }
                              }
                              return ListView.builder(
                                padding: EdgeInsets.symmetric(horizontal: 36.w),
                                itemBuilder: (context, index) {
                                  final month = DateTime(
                                    now.year,
                                    now.month + index,
                                  );
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 84.h),
                                    child: _buildMonthCalendar(
                                      month,
                                      overlapMap,
                                      tripW2m.availabilities,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
          bottomNavigationBar:
              (_startDate != null && _endDate != null)
                  ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(72.r),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          offset: const Offset(0, -2),
                          blurRadius: 1,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(36.w, 36.h, 36.w, 75.h),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff8287ff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(48.r),
                          ),
                          minimumSize: Size.fromHeight(180.h),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          if (_startDate != null && _endDate != null) {
                            final result = await ref
                                .read(tripProvider.notifier)
                                .updateTripTime(
                                  start: _startDate!,
                                  end: _endDate!,
                                );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    result ? '여행 일정이 저장되었습니다.' : '저장에 실패했습니다.',
                                  ),
                                  backgroundColor:
                                      result ? Colors.green : Colors.red,
                                ),
                              );
                              GoRouter.of(context).pop();
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('시작/종료 날짜를 선택해주세요.'),
                                ),
                              );
                            }
                          }
                        },
                        child: Text(
                          '${_startDate != null && _endDate != null ? '${_startDate!.year}.${_startDate!.month.toString().padLeft(2, '0')}.${_startDate!.day.toString().padLeft(2, '0')} - ${_endDate!.year}.${_endDate!.month.toString().padLeft(2, '0')}.${_endDate!.day.toString().padLeft(2, '0')} / ${_endDate!.difference(_startDate!).inDays + 1}박 ${_endDate!.difference(_startDate!).inDays}일' : ''}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 54.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  )
                  : null,
        );
      },
    );
  }

  Widget _buildMonthCalendar(
    DateTime month,
    Map<DateTime, int> overlapMap,
    List availabilities,
  ) {
    // 모든 유저의 availableDates를 유저별로 연속 구간(range)으로 변환
    Map<int, List<List<DateTime>>> userRanges = {};
    if (overlapMap.isNotEmpty) {
      for (final u in availabilities) {
        final userId = u['userId'];
        final dates =
            (u['availableDates'] as List).map((e) => DateTime.parse(e)).toList()
              ..sort();
        List<List<DateTime>> ranges = [];
        List<DateTime> currRange = [];
        for (int i = 0; i < dates.length; i++) {
          if (currRange.isEmpty) {
            currRange.add(dates[i]);
          } else {
            if (dates[i].difference(currRange.last).inDays == 1) {
              currRange.add(dates[i]);
            } else {
              ranges.add(List.from(currRange));
              currRange = [dates[i]];
            }
          }
        }
        if (currRange.isNotEmpty) ranges.add(currRange);
        userRanges[userId] = ranges;
      }
    }

    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday % 7; // 일요일=0
    final List<Widget> dayWidgets = [];

    // 요일 헤더
    dayWidgets.add(
      Row(
        children: List.generate(7, (i) {
          final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
          return Expanded(
            child: Center(
              child: Text(
                weekdays[i],
                style: TextStyle(
                  color:
                      i == 0
                          ? const Color(0xfff65a5a)
                          : (i == 6
                              ? const Color(0xff6d8fff)
                              : const Color(0xffbdbdbd)),
                  fontWeight: FontWeight.w600,
                  fontSize: 42.sp,
                ),
              ),
            ),
          );
        }),
      ),
    );
    dayWidgets.add(const SizedBox(height: 10));

    int day = 1;
    for (int week = 0; week < 6; week++) {
      List<Widget> row = [];
      for (int wd = 0; wd < 7; wd++) {
        if (week == 0 && wd < startWeekday) {
          row.add(const Expanded(child: SizedBox()));
        } else if (day > daysInMonth) {
          row.add(const Expanded(child: SizedBox()));
        } else {
          final thisDay = DateTime(month.year, month.month, day);
          final overlap = overlapMap[thisDay] ?? 0;
          final isSelected =
              _startDate != null &&
              _endDate != null &&
              !thisDay.isBefore(_startDate!) &&
              !thisDay.isAfter(_endDate!);

          // 겹치는 range의 시작/끝 여부를 overlapMap 기반으로 판단하는 헬퍼
          bool _isOverlapRangeStart(
            DateTime day,
            Map<DateTime, int> overlapMap,
          ) {
            final prev = day.subtract(const Duration(days: 1));
            return (overlapMap[day] ?? 0) > 0 && (overlapMap[prev] ?? 0) == 0;
          }

          bool _isOverlapRangeEnd(DateTime day, Map<DateTime, int> overlapMap) {
            final next = day.add(const Duration(days: 1));
            return (overlapMap[day] ?? 0) > 0 && (overlapMap[next] ?? 0) == 0;
          }

          final isRangeEdge = (thisDay == _startDate) || (thisDay == _endDate);
          row.add(
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_startDate == null ||
                        (_startDate != null && _endDate != null)) {
                      _startDate = thisDay;
                      _endDate = null;
                    } else if (_startDate != null && _endDate == null) {
                      if (thisDay.isBefore(_startDate!)) {
                        _startDate = thisDay;
                      } else if (thisDay == _startDate) {
                        _endDate = thisDay;
                      } else {
                        _endDate = thisDay;
                      }
                    }
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 24.h),
                  decoration:
                      isSelected
                          ? BoxDecoration(
                            color: const Color(0xffe3e5ff),
                            borderRadius: BorderRadius.horizontal(
                              left:
                                  isRangeEdge && thisDay == _startDate
                                      ? Radius.circular(150.r)
                                      : Radius.zero,
                              right:
                                  isRangeEdge && thisDay == _endDate
                                      ? Radius.circular(150.r)
                                      : Radius.zero,
                            ),
                          )
                          : null,
                  child: Container(
                    width: 114.w,
                    height: 114.h,
                    decoration:
                        overlapMap[thisDay] != null && overlapMap[thisDay]! > 0
                            ? BoxDecoration(
                              color: const Color(0xffe3e5ff).withOpacity(
                                _getOverlapOpacity(overlapMap[thisDay]!),
                              ),
                              borderRadius: BorderRadius.horizontal(
                                left:
                                    _isOverlapRangeStart(thisDay, overlapMap)
                                        ? Radius.circular(150.r)
                                        : Radius.zero,
                                right:
                                    _isOverlapRangeEnd(thisDay, overlapMap)
                                        ? Radius.circular(150.r)
                                        : Radius.zero,
                              ),
                            )
                            : null,
                    child: Center(
                      child: Container(
                        width: 114.w,
                        height: 114.h,
                        decoration:
                            isRangeEdge
                                ? BoxDecoration(
                                  color: const Color(0xff8287ff),
                                  shape: BoxShape.circle,
                                )
                                : null,
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color:
                                  isRangeEdge
                                      ? Colors.white
                                      : (isSelected
                                          ? const Color(0xff8287ff)
                                          : (thisDay.weekday == DateTime.sunday
                                              ? const Color(0xfff65a5a)
                                              : (thisDay.weekday ==
                                                      DateTime.saturday
                                                  ? const Color(0xff6d8fff)
                                                  : const Color(0xff313131)))),
                              fontSize: 42.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          day++;
        }
      }
      dayWidgets.add(Row(children: row));
      if (day > daysInMonth) break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 30),
            child: Text(
              '${month.year}년 ${month.month}월',
              style: TextStyle(
                fontSize: 54.sp,
                fontWeight: FontWeight.w700,
                color: Color(0xff222222),
              ),
            ),
          ),
          ...dayWidgets,
        ],
      ),
    );
  }

  // 겹침 단계별(1~5+) 투명도 반환 함수
  double _getOverlapOpacity(int overlapCount) {
    if (overlapCount <= 1) return 0.28; // 1명: 더 진하게
    if (overlapCount == 2) return 0.43;
    if (overlapCount == 3) return 0.58;
    if (overlapCount == 4) return 0.73;
    return 0.88; // 5명 이상
  }

  // 투명도 기반 색상 (기존 함수, 필요시 사용)
  Color getOverlapColor(int overlapCount) {
    double opacity = _getOverlapOpacity(overlapCount);
    return const Color(0xff8287ff).withOpacity(opacity);
  }

  String _rangeSummary(DateTime start, DateTime end) {
    final nights = end.difference(start).inDays;
    final days = nights + 1;
    String format(DateTime d) =>
        "${d.year}. ${d.month.toString().padLeft(2, '0')}. ${d.day.toString().padLeft(2, '0')}";
    return "${format(start)} - ${format(end)} / ${days}박 ${nights}일";
  }
}
