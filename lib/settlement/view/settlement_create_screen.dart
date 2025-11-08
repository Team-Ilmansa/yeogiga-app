import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yeogiga/common/component/bottom_app_bar_layout.dart';
import 'package:yeogiga/common/component/custom_text_form_field.dart';
import 'package:yeogiga/common/component/confirmation_dialog.dart';
import 'package:yeogiga/common/provider/util_state_provider.dart';
import 'package:yeogiga/common/utils/date_picker_util.dart';
import 'package:yeogiga/common/utils/system_ui_helper.dart';
import 'package:yeogiga/schedule/component/slider/category_selector.dart';
import 'package:yeogiga/settlement/component/settlement_payer_item.dart';
import 'package:yeogiga/settlement/model/settlement_model.dart';
import 'package:yeogiga/settlement/provider/settlement_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';

class SettlementCreateScreen extends ConsumerStatefulWidget {
  static String get routeName => 'settlementCreateScreen';
  final SettlementModel? initialSettlement;
  const SettlementCreateScreen({super.key, this.initialSettlement});

  @override
  ConsumerState<SettlementCreateScreen> createState() =>
      _SettlementCreateScreenState();
}

class _SettlementCreateScreenState
    extends ConsumerState<SettlementCreateScreen> {
  ProviderSubscription<AsyncValue<SettlementModel?>>? _settlementSubscription;
  bool _didPrefillFromSettlement = false;
  SettlementModel? _editingSettlement;
  bool _isLoading = false; // API 호출 중 로딩 상태

  int selectedCategoryIndex = 1; // 초기값: 관광지

  final TextEditingController priceContoller = TextEditingController();
  final TextEditingController titleContoller = TextEditingController();

  DateTime selectedDate = DateTime.now();
  Set<int> selectedMemberIds = {};
  bool isDivided = true; // true: 1/N 정산, false: 직접입력

  // 각 멤버별 수동 입력 가격을 저장할 Map
  Map<int, TextEditingController> manualPriceControllers = {};
  Map<int, int> manualPrices = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialSettlement != null) {
      _didPrefillFromSettlement = true;
      _prefillFormWithSettlement(widget.initialSettlement!);
    }

    // 플래그 초기화
    _didPrefillFromSettlement = false;

    // 수정 모드인 경우 바로 prefill 시도
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final isUpdateMode = ref.read(isSettlementUpdateModeProvider);

      if (isUpdateMode && !_didPrefillFromSettlement) {
        final settlement = ref.read(settlementProvider).valueOrNull;

        if (settlement != null && !_didPrefillFromSettlement) {
          _didPrefillFromSettlement = true;
          _prefillFormWithSettlement(settlement);
        }
      }
    });

    _settlementSubscription = ref.listenManual<AsyncValue<SettlementModel?>>(
      settlementProvider,
      (previous, next) {
        _handleSettlementForUpdate(next.valueOrNull);
      },
      fireImmediately: false,
    );
  }

  void _handleSettlementForUpdate(SettlementModel? settlement) {
    if (!mounted) return;
    if (!ref.read(isSettlementUpdateModeProvider)) return;
    if (_didPrefillFromSettlement) return;
    if (settlement == null) return;

    _didPrefillFromSettlement = true;
    _prefillFormWithSettlement(settlement);
  }

  void _prefillFormWithSettlement(SettlementModel settlement) {
    _editingSettlement = settlement;
    final formatter = NumberFormat('#,###');
    final dateString =
        settlement.date.length >= 10
            ? settlement.date.substring(0, 10)
            : settlement.date;

    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(dateString);
    } catch (_) {
      parsedDate = selectedDate;
    }

    final updatedSelectedMemberIds =
        settlement.payers.map((payer) => payer.userId).toSet();

    setState(() {
      priceContoller.text = formatter.format(settlement.totalPrice);
      titleContoller.text = settlement.name;
      selectedDate = parsedDate;
      selectedCategoryIndex = _categoryTypeToIndex(settlement.type);
      selectedMemberIds = updatedSelectedMemberIds;
      isDivided = false;

      manualPrices.clear();
      for (final controller in manualPriceControllers.values) {
        controller.clear();
      }
      for (final payer in settlement.payers) {
        final controller = manualPriceControllers.putIfAbsent(
          payer.userId,
          () => TextEditingController(),
        );
        controller.text = formatter.format(payer.price);
        manualPrices[payer.userId] = payer.price;
      }
    });
  }

  int _categoryTypeToIndex(String type) {
    switch (type) {
      case 'LODGING':
        return 2;
      case 'RESTAURANT':
        return 3;
      case 'TRANSPORT':
        return 4;
      case 'ETC':
        return 5;
      case 'TOURISM':
      default:
        return 1;
    }
  }

  String _categoryIndexToType(int index) {
    switch (index) {
      case 1:
        return 'TOURISM';
      case 2:
        return 'LODGING';
      case 3:
        return 'RESTAURANT';
      case 4:
        return 'TRANSPORT';
      case 5:
        return 'ETC';
      default:
        return 'TOURISM';
    }
  }

  /// 날짜 선택 범위 (제한 없음)
  List<DateTime> getAvailableDates() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dates = <DateTime>[];

    // 과거 1년 ~ 미래 1년까지 선택 가능
    final startDate = today.subtract(Duration(days: 365));
    final endDate = today.add(Duration(days: 365));

    for (var i = 0; i <= endDate.difference(startDate).inDays; i++) {
      dates.add(startDate.add(Duration(days: i)));
    }

    return dates;
  }

  @override
  void dispose() {
    _settlementSubscription?.close();
    _editingSettlement = null;
    priceContoller.dispose();
    titleContoller.dispose();
    // 수동 입력 컨트롤러들도 dispose
    for (var controller in manualPriceControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }

  // 1/N 정산 가격 계산
  String _calculateDividedPrice(
    int userId, {
    required String? currentUserNickname,
    required TripMember member,
  }) {
    if (selectedMemberIds.isEmpty) return '0 원';

    // 콤마 제거 후 파싱
    final totalPrice =
        int.tryParse(priceContoller.text.replaceAll(',', '')) ?? 0;
    if (totalPrice == 0) return '0 원';

    final basePrice = totalPrice ~/ selectedMemberIds.length; // 정수 나눗셈
    final remainder = totalPrice % selectedMemberIds.length; // 나머지

    // 현재 사용자(나)인 경우 나머지 추가
    final isMe =
        currentUserNickname != null && member.nickname == currentUserNickname;
    final finalPrice = isMe ? basePrice + remainder : basePrice;

    // 천 단위 콤마 추가
    final formatter = NumberFormat('#,###');
    return '${formatter.format(finalPrice)} 원';
  }

  // 수동 입력 가격 업데이트
  void _updateManualPrice(int userId, String value) {
    setState(() {
      final price = int.tryParse(value) ?? 0;
      manualPrices[userId] = price;
    });
  }

  // 총합 계산 (수동 입력 모드) - 포맷된 문자열 반환
  String _calculateTotalManualPrice() {
    final total = manualPrices.values.fold(0, (sum, price) => sum + price);
    final formatter = NumberFormat('#,###');
    return formatter.format(total);
  }

  // 총합 계산 (수동 입력 모드) - 숫자 반환
  int _calculateTotalManualPriceAsInt() {
    return manualPrices.values.fold(0, (sum, price) => sum + price);
  }

  // 확인 버튼 활성화 여부 체크
  bool _canConfirm() {
    // 1. 정산 비용 입력 확인
    final totalPriceText = priceContoller.text.replaceAll(',', '');
    final totalPrice = int.tryParse(totalPriceText) ?? 0;
    if (totalPrice == 0) return false;

    // 2. 내역 이름 입력 확인
    if (titleContoller.text.trim().isEmpty) return false;

    // 3. 정산 인원 선택 확인
    if (selectedMemberIds.isEmpty) return false;

    // 4. 분배된 금액 합계가 정산 비용과 일치하는지 확인
    if (isDivided) {
      // 1/N 정산 모드: 항상 일치 (자동 계산)
      return true;
    } else {
      // 직접입력 모드: 수동 입력 합계가 정산 비용과 일치해야 함
      final manualTotal = _calculateTotalManualPriceAsInt();
      return manualTotal == totalPrice;
    }
  }

  // API 전송용 데이터 생성
  Map<String, dynamic> _buildSettlementPayload({
    required String? currentUserNickname,
    required List<TripMember> members,
    required String type,
  }) {
    final totalPriceText = priceContoller.text.replaceAll(',', '');
    final totalPrice = int.tryParse(totalPriceText) ?? 0;

    // payers 배열 생성
    final List<Map<String, dynamic>> payers = [];

    if (isDivided) {
      // 1/N 정산 모드: 자동 분배
      final basePrice = totalPrice ~/ selectedMemberIds.length;
      final remainder = totalPrice % selectedMemberIds.length;

      for (var member in members) {
        if (selectedMemberIds.contains(member.userId)) {
          // 현재 사용자(나)인 경우 나머지 추가
          final isMe =
              currentUserNickname != null &&
              member.nickname == currentUserNickname;
          final price = isMe ? basePrice + remainder : basePrice;

          payers.add({
            'userId': member.userId,
            'price': price,
            // 'isCompleted': false,
          });
        }
      }
    } else {
      // 직접입력 모드: 수동 입력 금액
      for (var userId in selectedMemberIds) {
        final price = manualPrices[userId] ?? 0;
        payers.add({
          'userId': userId, 'price': price,
          // 'isCompleted': false
        });
      }
    }

    final payload = {
      'name': titleContoller.text,
      'totalPrice': totalPrice,
      'date':
          '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
      'type': type, // TODO: 카테고리 선택 기능 추가 시 변경
      'payers': payers,
    };

    // 최종 payload
    return payload;
  }

  @override
  Widget build(BuildContext context) {
    final isUpdateMode =
        ref.watch(isSettlementUpdateModeProvider) || _editingSettlement != null;
    final tripState = ref.watch(tripProvider).valueOrNull;
    final userState = ref.watch(userMeProvider);
    final members = tripState is TripModel ? tripState.members : <TripMember>[];

    // 현재 사용자를 맨 위로 정렬
    final sortedMembers = <TripMember>[...members];
    String? currentUserNickname;
    if (userState is UserResponseModel && userState.data != null) {
      currentUserNickname = userState.data!.nickname;
    } else if (userState is UserModel) {
      currentUserNickname = userState.nickname;
    }

    if (currentUserNickname != null) {
      sortedMembers.sort((a, b) {
        if (a.nickname == currentUserNickname) return -1;
        if (b.nickname == currentUserNickname) return 1;
        return 0;
      });
    }

    // 멤버별 컨트롤러 초기화 (아직 없는 경우에만)
    for (var member in sortedMembers) {
      if (!manualPriceControllers.containsKey(member.userId)) {
        manualPriceControllers[member.userId] = TextEditingController();
      }
    }

    return SafeArea(
      top: false,
      bottom: shouldUseSafeAreaBottom(context),
      child: WillPopScope(
        onWillPop: () async {
          ref.read(isSettlementUpdateModeProvider.notifier).state = false;
          _editingSettlement = null;
          return true;
        },
        child: Scaffold(
          backgroundColor: Color(0xfffafafa),
          appBar: AppBar(
            scrolledUnderElevation: 0,
            toolbarHeight: 48.h,
            backgroundColor: Color(0xfffafafa),
            shadowColor: Colors.transparent, // 그림자도 제거
            foregroundColor: Colors.black,
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true, // 타이틀 중앙 정렬
            leading: Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: GestureDetector(
                onTap: () {
                  if (ref.read(isSettlementUpdateModeProvider)) {
                    ref.read(isSettlementUpdateModeProvider.notifier).state =
                        false;
                  }
                  _editingSettlement = null;
                  GoRouter.of(context).pop();
                },
                child: Icon(Icons.arrow_back_ios_new, size: 16.sp),
              ),
            ),
            title: Text(
              isUpdateMode ? '정산 내역 수정하기' : '정산 내역 추가하기',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                height: 1.4,
                letterSpacing: -0.48,
                color: Color(0xff313131),
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBarLayout(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Row(
                children: [
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final settlementListAsync = ref.watch(
                          settlementListProvider,
                        );
                        final isLoading = settlementListAsync.isLoading;
                        final isUpdateMode =
                            ref.watch(isSettlementUpdateModeProvider) ||
                            _editingSettlement != null;

                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _canConfirm() && !isLoading
                                    ? const Color(0xFF8287FF)
                                    : const Color(0xFFD9D9D9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                            minimumSize: Size.fromHeight(46.h),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed:
                              _canConfirm() && !isLoading
                                  ? () async {
                                    final isUpdateMode =
                                        ref.read(
                                          isSettlementUpdateModeProvider,
                                        ) ||
                                        _editingSettlement != null;

                                    // 수정 모드일 때 확인 모달 표시
                                    if (isUpdateMode) {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder:
                                            (context) => ConfirmationDialog(
                                              title: '정산 내역 수정하기',
                                              content: '정산 내역을 이대로 수정하시겠어요?',
                                              cancelText: '취소',
                                              confirmText: '수정하기',
                                              confirmColor: const Color(
                                                0xFF8287FF,
                                              ),
                                            ),
                                      );

                                      if (confirmed != true) return;
                                    }

                                    final payload = _buildSettlementPayload(
                                      currentUserNickname: currentUserNickname,
                                      members: sortedMembers,
                                      type: _categoryIndexToType(
                                        selectedCategoryIndex,
                                      ),
                                    );

                                    final tripState =
                                        ref.read(tripProvider).valueOrNull;

                                    if (tripState is TripModel) {
                                      final settlementNotifier = ref.read(
                                        settlementListProvider.notifier,
                                      );

                                      // BuildContext를 async 이전에 저장 (async gap 대비)
                                      if (!context.mounted) return;
                                      final navigator = GoRouter.of(context);
                                      final messenger = ScaffoldMessenger.of(
                                        context,
                                      );

                                      Map<String, dynamic> result;

                                      // API 요청 먼저 실행
                                      if (isUpdateMode) {
                                        final settlement =
                                            ref
                                                .read(settlementProvider)
                                                .valueOrNull;
                                        if (settlement == null) {
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                '정산 정보를 불러오지 못했습니다.',
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                    229,
                                                    226,
                                                    81,
                                                    65,
                                                  ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              margin: EdgeInsets.all(5.w),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14.r),
                                              ),
                                              elevation: 6,
                                              duration: const Duration(
                                                seconds: 2,
                                              ),
                                            ),
                                          );
                                          return;
                                        }

                                        result = await settlementNotifier
                                            .updateSettlement(
                                              tripId: tripState.tripId,
                                              settlementId: settlement.id,
                                              name: payload['name'],
                                              totalPrice: payload['totalPrice'],
                                              date: payload['date'],
                                              type: payload['type'],
                                              payers: payload['payers'],
                                            );
                                      } else {
                                        result = await settlementNotifier
                                            .createSettlement(
                                              tripId: tripState.tripId,
                                              name: payload['name'],
                                              totalPrice: payload['totalPrice'],
                                              date: payload['date'],
                                              type: payload['type'],
                                              payers: payload['payers'],
                                            );
                                      }

                                      // 성공 시에만 화면 닫기
                                      if (!mounted) return;
                                      if (result['success'] == true) {
                                        _editingSettlement = null;
                                        if (isUpdateMode) {
                                          ref
                                              .read(
                                                isSettlementUpdateModeProvider
                                                    .notifier,
                                              )
                                              .state = false;
                                        }
                                        navigator.pop();
                                      }

                                      // 결과 스낵바 표시
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            result['message'] ??
                                                '알 수 없는 오류가 발생했습니다.',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          backgroundColor:
                                              result['success']
                                                  ? const Color.fromARGB(
                                                    212,
                                                    56,
                                                    212,
                                                    121,
                                                  )
                                                  : const Color.fromARGB(
                                                    229,
                                                    226,
                                                    81,
                                                    65,
                                                  ),
                                          behavior: SnackBarBehavior.floating,
                                          margin: EdgeInsets.all(5.w),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14.r,
                                            ),
                                          ),
                                          elevation: 6,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                  : null,
                          child:
                              isLoading
                                  ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : Text(
                                    isUpdateMode ? '수정하기' : '확인',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    '정산 비용',
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.4,
                      letterSpacing: -0.48,
                      color: Color(0xff313131),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomSettlementTextFormField(
                    numbersOnly: true,
                    suffix: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '원',
                          style: TextStyle(
                            fontSize: 16.sp,
                            height: 1.4,
                            letterSpacing: -0.48,
                            color: Color(0xff7d7d7d),
                          ),
                        ),
                      ],
                    ),
                    controller: priceContoller,
                    onChanged: (value) {
                      // 1/N 정산 모드일 때만 가격 변경 시 리빌드
                      if (isDivided) {
                        setState(() {});
                      }
                    },
                  ),
                  SizedBox(height: 28.h),
                  Text(
                    '내역 이름',
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.4,
                      letterSpacing: -0.48,
                      color: Color(0xff313131),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  CustomSettlementTextFormField(controller: titleContoller),
                  SizedBox(height: 28.h),
                  Text(
                    '날짜',
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.4,
                      letterSpacing: -0.48,
                      color: Color(0xff313131),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  GestureDetector(
                    onTap: () {
                      DatePickerUtil.showDateListPicker(
                        context: context,
                        selectedDateTime: selectedDate,
                        availableDates: getAvailableDates(),
                        onDateChanged: (picked) {
                          setState(() => selectedDate = picked);
                        },
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 19.h,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xfff0f0f0),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Text(
                            '${selectedDate.year}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              height: 1.4,
                              letterSpacing: -0.48,
                              color: Color(0xff7d7d7d),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text('.', style: TextStyle(fontSize: 16.sp)),
                        ),
                        Container(
                          width: 60.w,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 19.h,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xfff0f0f0),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Center(
                            child: Text(
                              selectedDate.month.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 16.sp,
                                height: 1.4,
                                letterSpacing: -0.48,
                                color: Color(0xff7d7d7d),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text('.', style: TextStyle(fontSize: 16.sp)),
                        ),
                        Container(
                          width: 60.w,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 19.h,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xfff0f0f0),
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Center(
                            child: Text(
                              selectedDate.day.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 16.sp,
                                height: 1.4,
                                letterSpacing: -0.48,
                                color: Color(0xff7d7d7d),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 28.h),
                  Text(
                    '카테고리',
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.4,
                      letterSpacing: -0.48,
                      color: Color(0xff313131),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CategorySelector(
                    key: ValueKey(selectedCategoryIndex),
                    initialSelectedIndex: selectedCategoryIndex,
                    onCategoryChanged: (index) {
                      setState(() {
                        selectedCategoryIndex = index;
                      });
                    },
                  ),
                  SizedBox(height: 28.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '정산 인원 ',
                            style: TextStyle(
                              fontSize: 16.sp,
                              height: 1.4,
                              letterSpacing: -0.48,
                              color: Color(0xff313131),
                            ),
                          ),
                          Text(
                            '${members.length}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              height: 1.4,
                              letterSpacing: -0.48,
                              color: Color(0xff8287ff),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(18.r),
                            onTap: () {
                              setState(() {
                                isDivided = true;
                                // 수동 입력 값들 초기화
                                manualPrices.clear();
                                for (var controller
                                    in manualPriceControllers.values) {
                                  controller.clear();
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 11.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.10),
                                    offset: const Offset(0, 0),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                '1/N 정산하기',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  height: 1.4,
                                  letterSpacing: -0.42,
                                  color:
                                      isDivided
                                          ? Color(0xff8287ff)
                                          : Color(0xff7d7d7d),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          InkWell(
                            borderRadius: BorderRadius.circular(18.r),
                            onTap: () {
                              setState(() {
                                isDivided = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 11.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.10),
                                    offset: const Offset(0, 0),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: Text(
                                '직접입력',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  height: 1.4,
                                  letterSpacing: -0.42,
                                  color:
                                      isDivided
                                          ? Color(0xff7d7d7d)
                                          : Color(0xff8287ff),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  ...sortedMembers.asMap().entries.map((entry) {
                    final member = entry.value;
                    final isLast = entry.key == sortedMembers.length - 1;
                    final isMe =
                        currentUserNickname != null &&
                        member.nickname == currentUserNickname;
                    return Column(
                      children: [
                        SettlementPayerItem(
                          name: member.nickname,
                          profileImageUrl: member.imageUrl,
                          isSelected: selectedMemberIds.contains(member.userId),
                          isManualMode: !isDivided,
                          isMe: isMe,
                          displayPrice:
                              isDivided
                                  ? _calculateDividedPrice(
                                    member.userId,
                                    currentUserNickname: currentUserNickname,
                                    member: member,
                                  )
                                  : null,
                          priceController:
                              !isDivided
                                  ? manualPriceControllers[member.userId]
                                  : null,
                          onPriceChanged:
                              !isDivided
                                  ? (value) =>
                                      _updateManualPrice(member.userId, value)
                                  : null,
                          onTap: () {
                            setState(() {
                              if (selectedMemberIds.contains(member.userId)) {
                                selectedMemberIds.remove(member.userId);
                                // 선택 해제 시 수동 입력 값도 제거
                                if (!isDivided) {
                                  manualPrices.remove(member.userId);
                                  manualPriceControllers[member.userId]
                                      ?.clear();
                                }
                              } else {
                                selectedMemberIds.add(member.userId);
                              }
                            });
                          },
                        ),
                        if (!isLast) SizedBox(height: 8.h),
                      ],
                    );
                  }),

                  // 직접입력 모드일 때 합계 표시
                  if (!isDivided && selectedMemberIds.isNotEmpty) ...[
                    SizedBox(height: 20.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xfff0f0f0),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '합계',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff313131),
                            ),
                          ),
                          Text(
                            '${_calculateTotalManualPrice()}원',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff8287ff),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
