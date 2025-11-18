import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/common/utils/category_icon_util.dart';
import 'package:yeogiga/common/utils/profile_placeholder_util.dart';
import 'package:yeogiga/settlement/model/settlement_model.dart';
import 'package:yeogiga/settlement/model/settlement_payer_model.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';

class SettlementItem extends ConsumerWidget {
  final SettlementModel settlement;

  const SettlementItem({super.key, required this.settlement});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 카테고리에 따라 아이콘 경로 결정
    final categoryIcon = CategoryIconUtil.getCategoryIconByEnglish(
      settlement.type,
    );

    // 총 정산자 수와 완료한 사람 수 계산
    final totalPayers = settlement.payers.length;
    final completedPayers =
        settlement.payers.where((p) => p.isCompleted).length;

    final userState = ref.watch(userMeProvider);
    String? myNickname;
    if (userState is UserResponseModel && userState.data != null) {
      myNickname = userState.data!.nickname;
    }
    SettlementPayerModel? myPayer;
    if (myNickname != null) {
      for (final payer in settlement.payers) {
        if (payer.nickname == myNickname) {
          myPayer = payer;
          break;
        }
      }
    }
    final bool isMySettlement =
        myPayer != null && myPayer.userId == settlement.payerId;
    final bool showCompletedText =
        isMySettlement
            ? settlement.isCompleted
            : (myPayer?.isCompleted ?? settlement.isCompleted);
    final Color badgeColor;
    if (isMySettlement) {
      badgeColor =
          showCompletedText
              ? const Color(0xFFC6C6C6).withOpacity(0.4)
              : const Color(0xff8287ff);
    } else {
      if (showCompletedText) {
        badgeColor = const Color(0xFFC6C6C6).withOpacity(0.4);
      } else {
        badgeColor = Colors.white;
      }
    }

    // 완료 여부에 따른 투명도 설정
    final opacity = showCompletedText ? 0.4 : 1.0;

    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push('/settlementDetailScreen/${settlement.id}');
      },
      child: Opacity(
        opacity: opacity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(categoryIcon, width: 24.w, height: 24.h),
            SizedBox(width: 12.w),
            Container(
              width: 301.w,
              height: 100.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                color: Color(0xfff0f0f0),
              ),
              child: Padding(
                padding: EdgeInsetsGeometry.fromLTRB(20.w, 18.h, 12.w, 18.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          settlement.name,
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.5,
                            letterSpacing: -0.36,
                            color: Color(0xff7d7d7d),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          '${settlement.totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
                          style: TextStyle(
                            fontSize: 16.sp,
                            height: 1.4,
                            letterSpacing: -0.48,
                            color: Color(0xff313131),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'asset/icon/user-02.svg',
                              width: 12.w,
                              height: 12.h,
                            ),
                            SizedBox(width: 4.w),
                            ...settlement.payers.map((payer) {
                              final isActualPayer =
                                  payer.userId == settlement.payerId;
                              final hasImage =
                                  payer.imageUrl != null &&
                                  payer.imageUrl!.isNotEmpty;

                              return Padding(
                                padding: EdgeInsets.only(right: 4.w),
                                child: Container(
                                  width: 16.w,
                                  height: 16.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(36.r),
                                    border:
                                        isActualPayer
                                            ? Border.all(
                                              width: 0.889.sp,
                                              color: Color(0xff8287ff),
                                            )
                                            : null,
                                  ),
                                  child: ClipOval(
                                    child: SizedBox(
                                      width: 16.w,
                                      height: 16.h,
                                      child:
                                          hasImage
                                              ? Image.network(
                                                payer.imageUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) =>
                                                        buildProfileAvatarPlaceholder(
                                                          nickname:
                                                              payer.nickname,
                                                          size: 16.w,
                                                          backgroundColor:
                                                              const Color(
                                                                0xffebebeb,
                                                              ),
                                                          textColor:
                                                              const Color(
                                                                0xff8287ff,
                                                              ),
                                                        ),
                                              )
                                              : buildProfileAvatarPlaceholder(
                                                nickname: payer.nickname,
                                                size: 16.w,
                                                backgroundColor: const Color(
                                                  0xffebebeb,
                                                ),
                                                textColor: const Color(
                                                  0xff8287ff,
                                                ),
                                              ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    Container(
                      width: 41.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(18.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            offset: Offset(0, 0),
                            blurRadius: 4,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          showCompletedText
                              ? '완료'
                              : '$completedPayers/$totalPayers',
                          style: TextStyle(
                            color:
                                (!isMySettlement && !showCompletedText)
                                    ? const Color(0xff7d7d7d)
                                    : Colors.white,
                            fontSize: 14.sp,
                            height: 1.4,
                            letterSpacing: -0.42,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
