import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/w2m/provider/trip_w2m_provider.dart';
// 필요시: import 'package:yeogiga/user/provider/user_me_provider.dart';

class W2MOverlapCalendarScreen extends ConsumerStatefulWidget {
  const W2MOverlapCalendarScreen({super.key});

  @override
  ConsumerState<W2MOverlapCalendarScreen> createState() => _W2MOverlapCalendarScreenState();
}

class _W2MOverlapCalendarScreenState extends ConsumerState<W2MOverlapCalendarScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    // tripId는 상위에서 전달받거나, route arguments 등에서 꺼내세요.
    final tripId = ModalRoute.of(context)?.settings.arguments as int?;
    if (tripId == null) {
      return const Scaffold(body: Center(child: Text('tripId가 필요합니다.')));
    }
    final tripW2mAsync = ref.watch(tripW2mProvider(tripId));
    // 필요시: final myUserId = ref.watch(userMeProvider)?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('여행 날짜 겹침 보기')),
      body: tripW2mAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('에러: $e')),
        data: (tripW2m) {
          if (tripW2m == null) return const Center(child: Text('데이터 없음'));
          // 1. 날짜별 겹침 개수 Map 생성
          final overlapCountMap = <DateTime, int>{};
          for (final entry in tripW2m.availabilities) {
            final dates = (entry['availableDates'] as List).cast<String>();
            for (final dateStr in dates) {
              final date = DateTime.parse(dateStr);
              final day = DateTime(date.year, date.month, date.day);
              overlapCountMap[day] = (overlapCountMap[day] ?? 0) + 1;
            }
          }
          // 2. 달력 위젯 (한 달만 예시)
          DateTime month = DateTime.now();
          int daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // 요일 헤더
                Row(
                  children: List.generate(7, (i) {
                    final label = ['일','월','화','수','목','금','토'][i];
                    final color = i == 0
                      ? const Color(0xfff65a5a)
                      : (i == 6 ? const Color(0xff6d8fff) : const Color(0xffbdbdbd));
                    return Expanded(
                      child: Center(
                        child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                // 달력 날짜
                ..._buildCalendarRows(month, daysInMonth, overlapCountMap),
                // 하단 range 요약
                if (_startDate != null && _endDate != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xff8287ff),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          _rangeSummary(_startDate!, _endDate!),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildCalendarRows(
    DateTime month,
    int daysInMonth,
    Map<DateTime, int> overlapCountMap,
  ) {
    List<Widget> rows = [];
    int firstWeekday = DateTime(month.year, month.month, 1).weekday % 7;
    int day = 1 - firstWeekday;

    for (int week = 0; week < 6; week++) {
      List<Widget> cells = [];
      for (int i = 0; i < 7; i++, day++) {
        final thisDay = DateTime(month.year, month.month, day);
        final overlapCount = overlapCountMap[thisDay] ?? 0;
        final isSelected = _startDate != null && _endDate != null && !thisDay.isBefore(_startDate!) && !thisDay.isAfter(_endDate!);
        final isRangeEdge = (thisDay == _startDate) || (thisDay == _endDate);

        cells.add(
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: day < 1 || day > daysInMonth
                  ? const SizedBox()
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_startDate == null || (_startDate != null && _endDate != null)) {
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
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 겹침 배경
                          if (overlapCount > 0)
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: getOverlapColor(overlapCount),
                                borderRadius: BorderRadius.circular(19),
                              ),
                            ),
                          // range의 시작/끝 날짜에만 원(circle) 그림
                          if (isRangeEdge)
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: Color(0xff8287ff),
                                shape: BoxShape.circle,
                              ),
                            ),
                          // 날짜 숫자
                          Text(
                            '${thisDay.day}',
                            style: TextStyle(
                              color: isRangeEdge
                                  ? Colors.white
                                  : (_startDate != null && _endDate != null && thisDay.isAfter(_startDate!) && thisDay.isBefore(_endDate!)
                                      ? const Color(0xff8287ff)
                                      : (thisDay.weekday == DateTime.sunday
                                          ? const Color(0xfff65a5a)
                                          : (thisDay.weekday == DateTime.saturday
                                              ? const Color(0xff6d8fff)
                                              : const Color(0xff313131)))),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      }
      rows.add(Row(children: cells));
      if (day > daysInMonth) break;
    }
    return rows;
  }

  // 투명도 기반 색상
  Color getOverlapColor(int overlapCount) {
    double opacity = (0.18 + 0.15 * (overlapCount - 1)).clamp(0.18, 0.88);
    return const Color(0xff8287ff).withOpacity(opacity);
  }

  String _rangeSummary(DateTime start, DateTime end) {
    final nights = end.difference(start).inDays;
    final days = nights + 1;
    String format(DateTime d) => "${d.year}. ${d.month.toString().padLeft(2, '0')}. ${d.day.toString().padLeft(2, '0')}";
    return "${format(start)} - ${format(end)} / ${days}박 ${nights}일";
  }
}
