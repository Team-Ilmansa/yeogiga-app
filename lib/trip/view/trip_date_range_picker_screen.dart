import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/w2m/provider/user_w2m_provider.dart';
import 'package:yeogiga/w2m/model/user_w2m_model.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

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
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    // 에러 메시지 노출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!), backgroundColor: Colors.red),
        );
        setState(() {
          _error = null;
        });
      }
    });

    // 한국 로케일로 날짜 포맷 적용
    Intl.defaultLocale = 'ko_KR';
    final now = DateTime.now();
    return Scaffold(
      //헤더 공간
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
          onPressed: () {
            // GoRouter 6.x 이상이면 context.canPop/context.pop 사용, 아니면 Navigator fallback
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ),
      //달력 선택 공간
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 상단 안내 영역
            SizedBox(height: 11.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Text(
                '여행날짜를\n선택해주세요',
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff222222),
                  height: 1.2,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            SizedBox(height: 9.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Text(
                '아직 확정된 날짜는 아니며, 추후 수정이 가능해요',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Color(0xff818181),
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.1,
                ),
              ),
            ),
            SizedBox(height: 36.h),
            // 2. 무한 스크롤 달력 영역
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 11.w),
                //TODO: 아이템 빌더에 아이템 수 안넣어도 무한대로 생성되나 ??
                itemBuilder: (context, index) {
                  final month = DateTime(now.year, now.month + index);
                  return Padding(
                    padding: EdgeInsets.only(bottom: 25.h),
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
              ? Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21.r),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      offset: const Offset(0, -2),
                      blurRadius: 4,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(11.w, 11.h, 11.w, 22.h),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff8287ff),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                      minimumSize: Size.fromHeight(53.h),
                      elevation: 0,
                    ),
                    onPressed:
                        //TODO: w2m을 수정하는 상황도 만들어야함.
                        _isLoading
                            ? null
                            : () async {
                              if (_startDate == null || _endDate == null) {}

                              setState(() {
                                _isLoading = true;
                                _error = null;
                              });
                              try {
                                // tripProvider에서 tripId 가져오기
                                final tripState = ref.read(tripProvider);
                                int? tripId;
                                if (tripState is TripModel) {
                                  tripId = tripState.tripId;
                                } else {
                                  setState(() {
                                    _error = '잘못된 접근입니다.';
                                    _isLoading = false;
                                  });
                                  return;
                                }
                                // 날짜 리스트 생성
                                final days =
                                    _endDate!.difference(_startDate!).inDays +
                                    1;
                                final availableDates = List.generate(days, (i) {
                                  final d = _startDate!.add(Duration(days: i));
                                  return DateFormat('yyyy-MM-dd').format(d);
                                });
                                final userW2m = await ref
                                    .read(userW2mProvider.notifier)
                                    .postUserW2m(
                                      tripId: tripId,
                                      availableDates: availableDates,
                                    );
                                if (userW2m is UserW2mModel) {
                                  GoRouter.of(
                                    context,
                                  ).pushReplacement('/tripDetailScreen');
                                } else {
                                  setState(() {
                                    _error = '날짜 저장에 실패했습니다.';
                                  });
                                }
                              } catch (e) {
                                setState(() {
                                  _error = '에러가 발생했습니다.';
                                });
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                    child:
                        _isLoading
                            ? SizedBox(
                              height: 21.h,
                              width: 21.w,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : Text(
                              '${DateFormat('yyyy.MM.dd').format(_startDate!)} - ${DateFormat('yyyy.MM.dd').format(_endDate!)} / ${_endDate!.difference(_startDate!).inDays}박 ${_endDate!.difference(_startDate!).inDays + 1}일',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
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
                  fontSize: 12.sp,
                ),
              ),
            ),
          );
        }),
      ),
    );
    dayWidgets.add(const SizedBox(height: 3));

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
                  margin: EdgeInsets.symmetric(vertical: 7.h),
                  decoration:
                      isSelected
                          ? BoxDecoration(
                            color: const Color(0xffe3e5ff),
                            borderRadius: BorderRadius.horizontal(
                              left:
                                  isRangeEdge && thisDay == _startDate
                                      ? Radius.circular(45.r)
                                      : Radius.zero,
                              right:
                                  isRangeEdge && thisDay == _endDate
                                      ? Radius.circular(45.r)
                                      : Radius.zero,
                            ),
                          )
                          : null,
                  child: Center(
                    child: Container(
                      width: 34.w,
                      height: 34.h,
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
                                    : ( // range 내부(시작/끝 제외)
                                    (_startDate != null &&
                                            _endDate != null &&
                                            thisDay.isAfter(_startDate!) &&
                                            thisDay.isBefore(_endDate!))
                                        ? const Color(0xff8287ff)
                                        : (thisDay.weekday == DateTime.sunday
                                            ? const Color(0xfff65a5a)
                                            : (thisDay.weekday ==
                                                    DateTime.saturday
                                                ? const Color(0xff6d8fff)
                                                : const Color(0xff313131)))),
                            fontSize: 12.sp,
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
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 30),
            child: Text(
              '${month.year}년 ${month.month}월',
              style: TextStyle(
                fontSize: 16.sp,
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
