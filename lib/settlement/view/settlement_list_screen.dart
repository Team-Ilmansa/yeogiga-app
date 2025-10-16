import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/component/bottom_app_bar_layout.dart';
import 'package:yeogiga/common/component/day_selector.dart';
import 'package:yeogiga/common/utils/trip_utils.dart';
import 'package:yeogiga/settlement/component/settlement_item.dart';
import 'package:yeogiga/settlement/model/settlement_model.dart';
import 'package:yeogiga/settlement/provider/settlement_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';

class SettlementListScreen extends ConsumerStatefulWidget {
  static String get routeName => 'settlementListScreen';
  const SettlementListScreen({super.key});

  @override
  ConsumerState<SettlementListScreen> createState() =>
      _SettlementListScreenState();
}

class _SettlementListScreenState extends ConsumerState<SettlementListScreen> {
  int _selectedIndex = 0; // 0: 미정산내역, 1: 여행전체, 2~: Day 1, Day 2, ...

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripState = ref.read(tripProvider).valueOrNull;
      if (tripState is TripModel) {
        ref
            .read(settlementListProvider.notifier)
            .getSettlements(tripId: tripState.tripId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripProvider).valueOrNull;
    final dynamicDays = TripUtils.getDaysForTrip(tripState);
    // itemCount: 미정산내역(1) + 여행전체(1) + Day 개수
    final itemCount = 2 + dynamicDays.length;

    // 현재 사용자 정보 가져오기
    final userState = ref.watch(userMeProvider);
    String? currentUserNickname;
    if (userState is UserResponseModel && userState.data != null) {
      currentUserNickname = userState.data!.nickname;
    } else if (userState is UserModel) {
      currentUserNickname = userState.nickname;
    }

    // 미정산 내역 개수 계산 (내가 속한 미정산 내역만)
    final settlements = ref.watch(settlementListProvider).valueOrNull;
    int unpaidCount = 0;
    bool hasAnySettlement = false;

    if (settlements != null &&
        settlements.isNotEmpty &&
        currentUserNickname != null) {
      hasAnySettlement = true;
      for (var daySettlements in settlements.values) {
        for (var settlement in daySettlements) {
          // 내가 정산 참여자에 포함되어 있는지 닉네임으로 확인
          final myPayer = settlement.payers.firstWhere(
            (payer) => payer.nickname == currentUserNickname,
            orElse: () => settlement.payers.first, // 임시 기본값
          );

          // 내가 정산 참여자이고, 내가 완료하지 않은 경우만 카운트
          if (settlement.payers.any((p) => p.nickname == currentUserNickname) &&
              !myPayer.isCompleted) {
            unpaidCount++;
          }
        }
      }
    }

    // 메시지 결정
    String headerMessage;
    if (!hasAnySettlement) {
      headerMessage = '아직\n정산 내역이 없어요.';
    } else if (unpaidCount > 0) {
      headerMessage = '$unpaidCount건의\n미정산 내역이 있어요';
    } else {
      headerMessage = '모든 정산이\n완료되었어요!';
    }

    return Scaffold(
      backgroundColor: Color(0xfffafafa),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 48.h,
        backgroundColor: Color(0xfffafafa),
        shadowColor: Colors.transparent, // 그림자도 제거
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 4.w),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.arrow_back_ios_new, size: 16.sp),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBarLayout(
        child: Row(
          children: [
            SizedBox(width: 6.w),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8287FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                  minimumSize: Size.fromHeight(46.h),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  GoRouter.of(context).push('/settlementCreateScreen');
                },
                child: Text(
                  '내역 추가하기',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: 6.w),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 14.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(
              headerMessage,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                height: 1.4,
                letterSpacing: -0.84,
                color: Color(0xff313131),
              ),
            ),
          ),
          SizedBox(height: 17.h),
          DaySelector(
            itemCount: itemCount,
            selectedIndex: _selectedIndex,
            onChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelBuilder: (index) {
              if (index == 0) return '미정산 내역';
              if (index == 1) return '여행 전체';
              // index 2부터는 Day 1, Day 2, ...
              return 'DAY ${index - 1}';
            },
          ),

          // TODO: 선택된 인덱스에 따라 필터링된 정산 내역 표시
          Expanded(child: _buildSettlementList()),
        ],
      ),
    );
  }

  Widget _buildSettlementList() {
    final settlements = ref.watch(settlementListProvider).valueOrNull;

    if (settlements == null || settlements.isEmpty) {
      return Center(
        child: Text(
          '등록된 정산 내역이 없습니다.',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xffc6c6c6),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // 날짜별로 정렬된 엔트리 리스트
    final sortedEntries =
        settlements.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    // 현재 사용자 닉네임 가져오기 (필터링용)
    final userState = ref.watch(userMeProvider);
    String? currentUserNickname;
    if (userState is UserResponseModel && userState.data != null) {
      currentUserNickname = userState.data!.nickname;
    } else if (userState is UserModel) {
      currentUserNickname = userState.nickname;
    }

    // _selectedIndex에 따라 필터링
    Map<String, dynamic> filteredData = {};

    if (_selectedIndex == 0) {
      // 미정산 내역: 내가 포함되어 있고, 내가 완료하지 않은 정산만
      if (currentUserNickname != null) {
        for (var entry in sortedEntries) {
          final myUnpaidSettlements =
              entry.value.where((s) {
                // 내가 정산 참여자에 포함되어 있는지 확인
                final myPayer = s.payers.firstWhere(
                  (payer) => payer.nickname == currentUserNickname,
                  orElse: () => s.payers.first, // 임시 기본값
                );
                // 내가 참여자이고, 내가 완료하지 않은 경우
                return s.payers.any((p) => p.nickname == currentUserNickname) &&
                    !myPayer.isCompleted;
              }).toList();

          if (myUnpaidSettlements.isNotEmpty) {
            filteredData[entry.key] = myUnpaidSettlements;
          }
        }
      }
    } else if (_selectedIndex == 1) {
      // 여행 전체: 모든 정산 내역
      filteredData = Map.from(settlements);
    } else {
      // Day별: 특정 일차의 정산 내역만
      final tripState = ref.watch(tripProvider).valueOrNull;
      if (tripState is TripModel && tripState.startedAt != null) {
        final dayIndex = _selectedIndex - 2; // 0부터 시작하는 Day 인덱스

        // 여행 시작일 + dayIndex로 해당 Day의 날짜 계산
        final start = DateTime.parse(tripState.startedAt!.substring(0, 10));
        final targetDate = start.add(Duration(days: dayIndex));
        final dateKey =
            '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}';

        // 해당 날짜의 정산만 필터링
        if (settlements.containsKey(dateKey)) {
          filteredData[dateKey] = settlements[dateKey]!;
        }
      }
    }

    if (filteredData.isEmpty) {
      return Center(
        child: Text(
          '등록된 정산 내역이 없습니다.',
          style: TextStyle(
            fontSize: 14.sp,
            color: const Color(0xffc6c6c6),
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    // 날짜 오름차순으로 정렬 (여행 시작일부터)
    final sortedFilteredEntries =
        filteredData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

    ///TODO: DaySelector 아래 자연스럽게 처리
    /// ㅡㅡㅡㅡㅡㅡㅡ 여기부터 ㅡㅡㅡㅡㅡㅡㅡ
    return Padding(
      padding: EdgeInsets.only(top: 5.h),
      child: ShaderMask(
        shaderCallback: (Rect bound) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.white],
            stops: [0, 0.05],
          ).createShader(bound);
        },
        blendMode: BlendMode.dstIn,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(14.w, 15.h, 14.w, 0),

          /// ㅡㅡㅡㅡㅡㅡㅡ 여기까지 ㅡㅡㅡㅡㅡㅡㅡ
          itemCount: sortedFilteredEntries.length,
          itemBuilder: (context, index) {
            final entry = sortedFilteredEntries[index];
            return SettlementDayExpansionTile(
              dayLabel: _formatDateLabel(entry.key),
              date: entry.key,
              settlements: entry.value,
            );
          },
        ),
      ),
    );
  }

  String _formatDateLabel(String dateKey) {
    try {
      final date = DateTime.parse(dateKey);
      final tripState = ref.read(tripProvider).valueOrNull;

      // 여행 정보가 있고, 시작일과 종료일이 있는 경우
      if (tripState is TripModel &&
          tripState.startedAt != null &&
          tripState.endedAt != null) {
        final start = DateTime.parse(tripState.startedAt!.substring(0, 10));
        final end = DateTime.parse(tripState.endedAt!.substring(0, 10));

        // 여행 기간 내의 날짜인지 확인
        if (!date.isBefore(start) && !date.isAfter(end)) {
          // 여행 시작일로부터 며칠째인지 계산
          final dayNumber = date.difference(start).inDays + 1;
          return 'DAY $dayNumber';
        }
      }

      // 여행 기간 외의 날짜는 날짜 형식으로 표시
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateKey;
    }
  }
}

/// 일차별 정산 내역 ExpansionTile
class SettlementDayExpansionTile extends ConsumerWidget {
  final String dayLabel;
  final String date;
  final List<SettlementModel> settlements;

  const SettlementDayExpansionTile({
    super.key,
    required this.dayLabel,
    required this.date,
    required this.settlements,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSettlements = settlements.isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
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
          initiallyExpanded: true, // 기본적으로 펼쳐진 상태
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
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
            if (hasSettlements)
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
                child: Column(
                  children: [
                    for (var settlement in settlements)
                      Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: SettlementItem(settlement: settlement),
                      ),
                  ],
                ),
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Text(
                    '등록된 정산 내역이 없습니다.',
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
