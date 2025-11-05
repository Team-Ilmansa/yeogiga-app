import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:yeogiga/common/component/tab_bar_header_delegate.dart';
import 'package:yeogiga/common/provider/util_state_provider.dart';
import 'package:yeogiga/common/route_observer.dart';
import 'package:yeogiga/settlement/component/settlement_more_menu_sheet.dart';
import 'package:yeogiga/settlement/model/settlement_model.dart';
import 'package:yeogiga/settlement/model/settlement_payer_model.dart';
import 'package:yeogiga/settlement/provider/settlement_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/common/utils/category_icon_util.dart';
import 'package:yeogiga/common/utils/data_utils.dart';
import 'package:yeogiga/common/utils/profile_placeholder_util.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/user/model/user_model.dart';

class SettlementDetailScreen extends ConsumerStatefulWidget {
  static String get routeName => 'settlementDetailScreen';
  final int settlementId;

  const SettlementDetailScreen({super.key, required this.settlementId});

  @override
  ConsumerState<SettlementDetailScreen> createState() =>
      _SettlementDetailScreenState();
}

class _SettlementDetailScreenState extends ConsumerState<SettlementDetailScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  bool _isSubscribedToRouteObserver = false;

  bool _canEditSettlement(SettlementModel? settlement) {
    if (settlement == null) return false;

    final user = ref.read(userMeProvider);
    String? myNickname;
    if (user is UserResponseModel && user.data != null) {
      myNickname = user.data!.nickname;
    } else if (user is UserModel) {
      myNickname = user.nickname;
    }

    if (myNickname == null) return false;

    return settlement.payers.any(
      (payer) =>
          payer.userId == settlement.payerId && payer.nickname == myNickname,
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // 화면 진입 시 정산 내역 조회
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripState = ref.read(tripProvider).valueOrNull;
      if (tripState is TripModel) {
        ref
            .read(settlementProvider.notifier)
            .getOneSettlement(
              tripId: tripState.tripId,
              settlementId: widget.settlementId,
            );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (_isSubscribedToRouteObserver) {
      settlementRouteObserver.unsubscribe(this);
      _isSubscribedToRouteObserver = false;
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isSubscribedToRouteObserver) {
      final route = ModalRoute.of(context);
      if (route != null) {
        settlementRouteObserver.subscribe(this, route);
        _isSubscribedToRouteObserver = true;
      }
    }
  }

  @override
  void didPopNext() {
    super.didPopNext();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(isSettlementUpdateModeProvider.notifier).state = false;

      final tripState = ref.read(tripProvider).valueOrNull;
      final settlement = ref.read(settlementProvider).valueOrNull;

      if (tripState is TripModel && settlement != null) {
        ref
            .read(settlementProvider.notifier)
            .getOneSettlement(
              tripId: tripState.tripId,
              settlementId: settlement.id,
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settlementAsync = ref.watch(settlementProvider);
    final settlement = settlementAsync.valueOrNull;

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
        centerTitle: true, // 타이틀 중앙 정렬
        leading: Padding(
          padding: EdgeInsets.only(left: 4.w),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back_ios_new, size: 16.sp),
          ),
        ),
        actions: [
          if (_canEditSettlement(settlement)) ...[
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: false,
                  backgroundColor: Colors.transparent,
                  barrierColor: Colors.black.withOpacity(0.5),
                  builder: (context) {
                    return SettlementMoreMenuSheet();
                  },
                );
              },
              child: Icon(Icons.more_vert, color: Colors.black),
            ),
            SizedBox(width: 14.w),
          ],
        ],
      ),
      body: settlementAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error:
            (error, stack) => Center(
              child: Text(
                '정산 내역을 불러오는데 실패했습니다.',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
            ),
        data: (settlement) {
          if (settlement == null) {
            return Center(
              child: Text(
                '정산 내역이 없습니다.',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
            );
          }

          // 총 정산자 수와 완료한 사람 수 계산
          final totalPayers = settlement.payers.length;
          final completedPayers =
              settlement.payers.where((p) => p.isCompleted).length;

          return NestedScrollView(
            headerSliverBuilder:
                (context, innerBoxIsScrolled) => [
                  _TopPanel(settlement: settlement),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: TabBarHeaderDelegate(
                      child: Container(
                        key: ValueKey(
                          'tab-$totalPayers-$completedPayers',
                        ), // 강제 리빌드
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        color: Color(0xfffafafa),
                        child: SizedBox(
                          height: 36.h,
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Color(0xFF8287FF),
                                  width: 2.w,
                                ),
                              ),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: Color(0xFF8287FF),
                            unselectedLabelColor: Colors.grey,
                            tabs: [
                              Tab(
                                child: Text(
                                  '미정산 ${totalPayers - completedPayers}',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    height: 1.40,
                                    letterSpacing: -0.48,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Tab(
                                child: Text(
                                  '정산 완료 $completedPayers',
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    height: 1.40,
                                    letterSpacing: -0.48,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
            body: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // 미정산 탭
                ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.h,
                  ),
                  itemCount:
                      settlement.payers.where((p) => !p.isCompleted).length,
                  separatorBuilder: (context, index) => SizedBox(height: 20.h),
                  itemBuilder: (context, index) {
                    final unpaidPayers =
                        settlement.payers.where((p) => !p.isCompleted).toList();
                    final payer = unpaidPayers[index];
                    return getPayerCard(
                      payer: payer,
                      settlement: settlement,
                      isCompleted: false,
                    );
                  },
                ),
                // 정산 완료 탭
                ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.h,
                  ),
                  itemCount:
                      settlement.payers.where((p) => p.isCompleted).length,
                  separatorBuilder: (context, index) => SizedBox(height: 20.h),
                  itemBuilder: (context, index) {
                    final completedPayers =
                        settlement.payers.where((p) => p.isCompleted).toList();
                    final payer = completedPayers[index];
                    return getPayerCard(
                      payer: payer,
                      settlement: settlement,
                      isCompleted: true,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget getPayerCard({
    required SettlementPayerModel payer,
    required SettlementModel settlement,
    required bool isCompleted,
  }) {
    // 현재 사용자 정보 가져오기
    final userMe = ref.watch(userMeProvider);
    String? myNickname;
    if (userMe is UserResponseModel && userMe.data != null) {
      myNickname = userMe.data!.nickname;
    }

    // 현재 사용자인지 확인 (nickname으로 비교)
    final isMe = payer.nickname == myNickname;

    // 내 닉네임과 일치하는 payer를 찾아서 그 userId가 settlement의 payerId와 같은지 확인
    final myPayer = settlement.payers.cast<SettlementPayerModel?>().firstWhere(
      (p) => p?.nickname == myNickname,
      orElse: () => null,
    );
    final isMySettlement =
        myPayer != null && myPayer.userId == settlement.payerId;

    return Row(
      children: [
        Container(
          width: 40.sp,
          height: 40.sp,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            image:
                payer.imageUrl != null && payer.imageUrl!.isNotEmpty
                    ? DecorationImage(
                      image: NetworkImage(payer.imageUrl!),
                      fit: BoxFit.cover,
                    )
                    : null,
            shape: RoundedRectangleBorder(
              side:
                  isMe
                      ? BorderSide(width: 1.sp, color: Color(0xff8287ff))
                      : BorderSide.none,
              borderRadius: BorderRadius.circular(24.r),
            ),
          ),
          child:
              payer.imageUrl == null || payer.imageUrl!.isEmpty
                  ? Icon(Icons.person, size: 20.sp, color: Color(0xff8287ff))
                  : null,
        ),
        SizedBox(width: 8.w),
        Text(
          isMe ? '(나) ${payer.nickname}' : payer.nickname,
          style: TextStyle(
            color: const Color(0xFF313131),
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            height: 1.40,
            letterSpacing: -0.48,
          ),
        ),
        Spacer(),
        Text(
          '${payer.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
          style: TextStyle(
            color: const Color(0xFF313131),
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            height: 1.40,
            letterSpacing: -0.48,
          ),
        ),
        SizedBox(width: 8.w),
        isMySettlement
            ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x19000000),
                    blurRadius: 4,
                    offset: Offset(0, 0),
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Material(
                borderRadius: BorderRadius.circular(18.r),
                color: Colors.white,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18.r),
                  onTap: () async {
                    final tripState = ref.read(tripProvider).valueOrNull;
                    if (tripState is! TripModel) return;

                    // Optimistic UI: 먼저 UI 상태를 업데이트
                    // 모든 payer를 새로운 객체로 생성하여 불변성 보장
                    final List<SettlementPayerModel> updatedPayers =
                        settlement.payers.cast<SettlementPayerModel>().map((p) {
                          return SettlementPayerModel(
                            id: p.id,
                            userId: p.userId,
                            nickname: p.nickname,
                            imageUrl: p.imageUrl,
                            price: p.price,
                            isCompleted:
                                p.id == payer.id ? !isCompleted : p.isCompleted,
                          );
                        }).toList();

                    // ⭐️⭐️⭐️모든 payer가 완료되었는지 확인⭐️⭐️⭐️
                    // ⭐️⭐️⭐️top panel 딤처리에 매우 중요⭐️⭐️⭐️
                    final allCompleted = updatedPayers.every(
                      (p) => p.isCompleted,
                    );

                    final updatedSettlement = SettlementModel(
                      id: settlement.id,
                      name: settlement.name,
                      totalPrice: settlement.totalPrice,
                      type: settlement.type,
                      date: settlement.date,
                      payerId: settlement.payerId,
                      isCompleted: allCompleted,
                      payers: updatedPayers,
                    );

                    // Optimistic update
                    ref
                        .read(settlementProvider.notifier)
                        .setOptimisticSettlement(updatedSettlement);

                    // settlement의 모든 payer 정보를 payInfos에 담기
                    final payInfos =
                        updatedPayers.map((p) {
                          return {
                            'payInfoId': p.id,
                            'isCompleted': p.isCompleted,
                          };
                        }).toList();

                    // API 호출 (백그라운드에서 실행)
                    final result = await ref
                        .read(settlementProvider.notifier)
                        .updateSettlementCompletion(
                          tripId: tripState.tripId,
                          settlementId: settlement.id,
                          payInfos: payInfos,
                        );

                    // 실패 시에만 롤백 및 에러 표시
                    if (!result['success']) {
                      // 원래 상태로 롤백
                      ref
                          .read(settlementProvider.notifier)
                          .setOptimisticSettlement(settlement);

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ?? '알 수 없는 오류가 발생했습니다.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: const Color.fromARGB(
                            229,
                            226,
                            81,
                            65,
                          ),
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(5.w),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          elevation: 6,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }

                    // // 결과 스낵바 표시 (기존 코드 - 주석처리)
                    // if (!mounted) return;
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text(
                    //       result['message'] ?? '알 수 없는 오류가 발생했습니다.',
                    //       style: TextStyle(
                    //         fontSize: 14.sp,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    //     ),
                    //     backgroundColor:
                    //         result['success']
                    //             ? const Color.fromARGB(212, 56, 212, 121)
                    //             : const Color.fromARGB(229, 226, 81, 65),
                    //     behavior: SnackBarBehavior.floating,
                    //     margin: EdgeInsets.all(5.w),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(14.r),
                    //     ),
                    //     elevation: 6,
                    //     duration: const Duration(seconds: 2),
                    //   ),
                    // );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 11.w,
                      vertical: 4.h,
                    ),
                    child: Text(
                      isCompleted ? '취소' : '완료',
                      style: TextStyle(
                        color: const Color(0xFF7D7D7D),
                        fontSize: 14.sp,
                        height: 1.40,
                        letterSpacing: -0.42,
                      ),
                    ),
                  ),
                ),
              ),
            )
            : Container(),
      ],
    );
  }
}

class _TopPanel extends StatelessWidget {
  final SettlementModel settlement;

  const _TopPanel({required this.settlement});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Opacity(
        opacity: settlement.isCompleted ? 0.4 : 1,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 14.h),
              Text(
                settlement.isCompleted ? '정산이 완료됐어요' : '정산 진행중이에요',
                style: TextStyle(
                  color: const Color(0xFF8287FF),
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.40,
                  letterSpacing: -0.42,
                ),
              ),
              Text(
                '${settlement.name}\n${settlement.totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                style: TextStyle(
                  color: const Color(0xFF313131),
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.40,
                  letterSpacing: -0.84,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  SvgPicture.asset(
                    CategoryIconUtil.getCategoryIconByEnglish(settlement.type),
                    width: 20.w,
                    height: 20.h,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    CategoryIconUtil.getCategoryKoreanName(settlement.type),
                    style: TextStyle(
                      color: const Color(0xFF7D7D7D),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.40,
                      letterSpacing: -0.42,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  SvgPicture.asset(
                    'asset/icon/menu/calendar_edit.svg',
                    color: Color(0xff7d7d7d),
                    width: 18.w,
                    height: 18.h,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    DataUtils.formatDate(settlement.date),
                    style: TextStyle(
                      color: const Color(0xFF7D7D7D),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      height: 1.40,
                      letterSpacing: -0.42,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  SvgPicture.asset(
                    'asset/icon/user-02.svg',
                    color: Color(0xff7d7d7d),
                    width: 18.w,
                    height: 18.h,
                  ),
                  SizedBox(width: 4.w),
                  ...settlement.payers.map((payer) {
                    final hasImage =
                        payer.imageUrl != null && payer.imageUrl!.isNotEmpty;
                    return Padding(
                      padding: EdgeInsets.only(right: 4.w),
                      child: ClipOval(
                        child: SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: hasImage
                              ? Image.network(
                                  payer.imageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          buildProfileAvatarPlaceholder(
                                            nickname: payer.nickname,
                                            size: 18.w,
                                            backgroundColor:
                                                const Color(0xffebebeb),
                                            textColor: const Color(0xff8287ff),
                                          ),
                                )
                              : buildProfileAvatarPlaceholder(
                                  nickname: payer.nickname,
                                  size: 18.w,
                                  backgroundColor: const Color(0xffebebeb),
                                  textColor: const Color(0xff8287ff),
                                ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
