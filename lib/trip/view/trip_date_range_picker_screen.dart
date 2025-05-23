import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class TripDateRangePickerScreen extends ConsumerStatefulWidget {
  static String get routeName => 'dateRangePicker';
  const TripDateRangePickerScreen({super.key});

  @override
  ConsumerState<TripDateRangePickerScreen> createState() =>
      _TripDateRangePickerScreenState();
}

class _TripDateRangePickerScreenState
    extends ConsumerState<TripDateRangePickerScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    // 한국 로케일로 날짜 포맷 적용
    Intl.defaultLocale = 'ko_KR';
    final now = DateTime.now();
    return Scaffold(
      //헤더 공간
      backgroundColor: Colors.white,
      appBar: AppBar(
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
      //달력 선택 공간
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 상단 안내 영역
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '여행날짜를\n선택해주세요',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff222222),
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '아직 확정된 날짜는 아니며, 추후 수정이 가능해요',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff818181),
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 2. 무한 스크롤 달력 영역
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemBuilder: (context, index) {
                  final month = DateTime(now.year, now.month + index);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 28),
                    child: _buildMonthCalendar(month),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      //하단 바 (날짜 선택 시 노출)
      bottomNavigationBar:
          (_startDate != null && _endDate != null)
              ? Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 25),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xff8287ff),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      '${DateFormat('yyyy.MM.dd').format(_startDate!)} - ${DateFormat('yyyy.MM.dd').format(_endDate!)} / ${_endDate!.difference(_startDate!).inDays}박 ${_endDate!.difference(_startDate!).inDays + 1}일',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              )
              : null,
    );
  }

  Widget _buildMonthCalendar(DateTime month) {
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
                  fontSize: 15,
                ),
              ),
            ),
          );
        }),
      ),
    );
    dayWidgets.add(const SizedBox(height: 10));

    // TODO: 다시한번 로직 검토하기
    // 날짜 그리드
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
          final isSelected =
              _startDate != null &&
              _endDate != null &&
              !thisDay.isBefore(_startDate!) &&
              !thisDay.isAfter(_endDate!);
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
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration:
                      isSelected
                          ? BoxDecoration(
                            color: const Color(0xffe3e5ff),
                            borderRadius: BorderRadius.horizontal(
                              left:
                                  isRangeEdge && thisDay == _startDate
                                      ? const Radius.circular(50)
                                      : Radius.zero,
                              right:
                                  isRangeEdge && thisDay == _endDate
                                      ? const Radius.circular(50)
                                      : Radius.zero,
                            ),
                          )
                          : null,
                  child: Center(
                    child: Container(
                      width: 38,
                      height: 38,
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
                                    : const Color(0xff313131),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: Text(
              '${month.year}년 ${month.month}월',
              style: const TextStyle(
                fontSize: 18,
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
}
