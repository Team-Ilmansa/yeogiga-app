import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/component/grey_bar.dart';
import 'package:yeogiga/common/component/confirmation_dialog.dart';
import 'package:yeogiga/common/component/menu_item.dart';
import 'package:yeogiga/common/provider/util_state_provider.dart';
import 'package:yeogiga/settlement/provider/settlement_provider.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/common/utils/snackbar_helper.dart';

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
              MenuItem(
                svgAsset: 'asset/icon/menu/title_edit.svg',
                text: '정산 내역 수정하기',
                onTap: () {
                  if (settlement == null) return;

                  ref.read(isSettlementUpdateModeProvider.notifier).state =
                      true;

                  final router = GoRouter.of(context);
                  router.pop();
                  router.push('/settlementCreateScreen', extra: settlement);
                },
              ),
              // 정산 내역 삭제하기
              MenuItem(
                svgAsset: 'asset/icon/menu/delete_edit.svg',
                text: '정산 내역 삭제하기',
                onTap: () async {
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
                      scaffoldMessenger.showAppSnack(
                        result['message'] ?? '알 수 없는 오류가 발생했습니다.',
                        isError: !(result['success'] as bool),
                      );
                    }
                  }
                },
              ),
              // 정산 재공지하기
              MenuItem(
                svgAsset: 'asset/icon/menu/re_notice.svg',
                text: '정산 내역 재공지하기',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
