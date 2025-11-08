import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/component/grey_bar.dart';
import 'package:yeogiga/common/component/confirmation_dialog.dart';
import 'package:yeogiga/common/provider/util_state_provider.dart';
import 'package:yeogiga/settlement/provider/settlement_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

class SettlementMoreMenuSheet extends ConsumerWidget {
  const SettlementMoreMenuSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settlementAsync = ref.watch(settlementProvider);
    final settlement = settlementAsync.valueOrNull;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => GoRouter.of(context).pop(),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          height: 265.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          padding: EdgeInsets.only(
            left: 0,
            right: 0,
            top: 0,
            bottom: MediaQuery.of(context).viewPadding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GreyBar(),
              // 정산 내역 수정하기
              _SettlementMenuItem(
                () {
                  if (settlement == null) return;

                  ref.read(isSettlementUpdateModeProvider.notifier).state =
                      true;

                  final router = GoRouter.of(context);
                  router.pop();
                  router.push('/settlementCreateScreen', extra: settlement);
                },
                title: '정산 내역 수정하기',
                svgAsset: 'asset/icon/menu/title_edit.svg',
              ),
              // 정산 내역 삭제하기
              _SettlementMenuItem(
                () async {
                  if (settlement == null) return;

                  // 정산 삭제 확인 다이얼로그 표시 (커스텀 스타일)
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => ConfirmationDialog(
                          title: '정산 내역 삭제하기',
                          content: '정산 내역을 삭제하시겠습니까?\n삭제된 내역은 복구할 수 없습니다.',
                          cancelText: '취소',
                          confirmText: '삭제하기',
                          confirmColor: const Color(0xFFE25141),
                        ),
                  );

                  if (confirmed == true) {
                    final tripState = ref.read(tripProvider).valueOrNull;
                    if (tripState is TripModel) {
                      if (!context.mounted) return;

                      // Optimistic UI: 화면을 닫기 전에 ScaffoldMessenger 저장
                      final scaffoldMessenger = ScaffoldMessenger.of(context);

                      // 화면 닫기
                      GoRouter.of(context).pop(); // 바텀시트 닫기
                      Navigator.of(context).pop(); // 상세 화면 닫기

                      // 정산 삭제 API 호출 (백그라운드에서 실행)
                      final result = await ref
                          .read(settlementListProvider.notifier)
                          .deleteSettlement(
                            tripId: tripState.tripId,
                            settlementId: settlement.id,
                          );

                      // 결과를 스낵바로 표시 (저장된 scaffoldMessenger 사용)
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ?? '알 수 없는 오류가 발생했습니다.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor:
                              result['success']
                                  ? const Color.fromARGB(212, 56, 212, 121)
                                  : const Color.fromARGB(229, 226, 81, 65),
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
                  }
                },
                title: '정산 내역 삭제하기',
                svgAsset: 'asset/icon/menu/delete_edit.svg',
              ),
              // 정산 재공지하기
              _SettlementMenuItem(
                () {},
                title: '정산 내역 재공지하기',
                svgAsset: 'asset/icon/menu/re_notice.svg',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettlementMenuItem extends ConsumerWidget {
  final String title;
  final String svgAsset;
  final GestureTapCallback? onTap;
  const _SettlementMenuItem(
    this.onTap, {
    super.key,
    required this.title,
    required this.svgAsset,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 64.h,
          child: Row(
            children: [
              SizedBox(width: 20.w),
              SvgPicture.asset(svgAsset, width: 24.w, height: 24.h),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  color: const Color(0xFF313131),
                  fontSize: 16.sp,
                  height: 1.40,
                  letterSpacing: -0.48,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
