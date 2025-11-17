import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/component/confirmation_dialog.dart';
import 'package:yeogiga/common/component/custom_text_form_field.dart';
import 'package:yeogiga/common/component/grey_bar.dart';
import 'package:yeogiga/common/component/menu_item.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yeogiga/common/utils/snackbar_helper.dart';

// 방장 전용 메뉴
class TripMoreMenuSheetLeader extends ConsumerWidget {
  const TripMoreMenuSheetLeader({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider).valueOrNull as TripModel?;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => GoRouter.of(context).pop(),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          height: trip?.status == TripStatus.SETTING ? 329.h : 265.h,
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

              // 여행 ID 확인하기
              // _TripMenuItem(
              //   svgUrl: 'asset/icon/menu/share_edit.svg',
              //   text: '여행 ID 확인하기',
              //   onTap: () async {
              //     final tripState = ref.read(tripProvider).valueOrNull;
              //     int? tripId;
              //     if (tripState is TripModel) {
              //       tripId = tripState.tripId;
              //     }
              //     await showDialog(
              //       context: context,
              //       builder:
              //           (context) => Dialog(
              //             backgroundColor: Colors.white,
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(14.r),
              //             ),
              //             insetPadding: EdgeInsets.all(14.w),
              //             child: Padding(
              //               padding: EdgeInsets.symmetric(
              //                 horizontal: 18.w,
              //                 vertical: 18.h,
              //               ),
              //               child: Container(
              //                 width: 1.w,
              //                 height: 59.h,
              //                 child: Center(
              //                   child: Center(
              //                     child: Padding(
              //                       padding: EdgeInsets.symmetric(
              //                         horizontal: 4.w,
              //                       ),
              //                       child: Text(
              //                         tripId != null
              //                             ? tripId.toString()
              //                             : '알 수 없음',
              //                         style: TextStyle(
              //                           fontSize: 18.sp,
              //                           fontWeight: FontWeight.w600,
              //                           color: const Color(0xff8287ff),
              //                         ),
              //                       ),
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //     );
              //   },
              // ),

              // 여행 이름 수정하기
              MenuItem(
                svgAsset: 'asset/icon/menu/title_edit.svg',
                text: '여행 개요 수정하기',
                onTap: () async {
                  final controller = TextEditingController();
                  final result = await showDialog<String>(
                    context: context,
                    builder:
                        (context) => Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.r),
                          ),
                          insetPadding: EdgeInsets.all(30.w),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 12.h,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                  ),
                                  child: Text(
                                    '여행 개요 수정',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff313131),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 4.w,
                                  ),
                                  child: CustomSettlementTextFormField(
                                    controller: controller,
                                    hintText: '새 여행 이름을 입력하세요',
                                    onChanged: (value) {},
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Align(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xff8287ff,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12.r,
                                          ),
                                        ),
                                        elevation: 0,
                                        minimumSize: Size(0, 45.h),
                                        padding: EdgeInsets.zero,
                                      ),
                                      onPressed: () {
                                        GoRouter.of(
                                          context,
                                        ).pop(controller.text.trim());
                                      },
                                      child: Text(
                                        '확인',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  );
                  if (result != null && result.isNotEmpty) {
                    try {
                      final success = await ref
                          .read(tripProvider.notifier)
                          .updateTripTitle(title: result);
                      // 수정: async gap 이후 context 사용 시 null 체크 추가 (StatelessWidget)
                      showAppSnackBar(
                        context,
                        success
                            ? '여행 이름이 수정되었습니다.'
                            : '여행 이름 수정에 실패했습니다.',
                        isError: !success,
                      );
                      GoRouter.of(context).pop();
                    } catch (e) {
                      String errorMsg = '';
                      if (e is Exception &&
                          e.toString().contains('Exception:')) {
                        errorMsg =
                            e.toString().replaceFirst('Exception:', '').trim();
                      } else {
                        errorMsg = e.toString();
                      }
                      showAppSnackBar(
                        context,
                        '여행 이름 수정에 실패했습니다${errorMsg.isNotEmpty ? "\n$errorMsg" : ""}',
                        isError: true,
                      );
                      GoRouter.of(context).pop();
                    }
                  }
                },
              ),
              // 날짜 수정하기 (SETTING 상태일 때만 표시)
              if (trip?.status == TripStatus.SETTING)
                MenuItem(
                  svgAsset: 'asset/icon/menu/calendar_edit.svg',
                  text: '일정 수정하기',
                  onTap: () {
                    GoRouter.of(context).pop();
                    GoRouter.of(context).push('/W2mConfirmScreen');
                    // TODO: 일정 수정
                  },
                ),
              // 여행 삭제하기
              MenuItem(
                svgAsset: 'asset/icon/menu/delete_edit.svg',
                text: '여행 삭제하기',
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => ConfirmationDialog(
                          title: '여행 삭제하기',
                          content:
                              '${trip?.title ?? '이 여행'}을 정말로 삭제하시겠어요?\n해당 작업은 복구할 수 없어요.',
                          cancelText: '취소',
                          confirmText: '삭제하기',
                          confirmColor: const Color(0xFFFF6B6B),
                        ),
                  );
                  if (confirm != true) return;

                  // context를 미리 저장
                  if (!context.mounted) return;
                  final navigator = Navigator.of(context);
                  final scaffoldMessenger = ScaffoldMessenger.of(context);

                  // 바텀시트 닫기
                  GoRouter.of(context).pop();

                  try {
                    final success =
                        await ref.read(tripProvider.notifier).deleteTrip();

                    // 성공 시 이전 화면으로 이동
                    if (success) {
                      navigator.pop();
                    }

                    // 스낵바 표시
                    scaffoldMessenger.showAppSnack(
                      success
                          ? '여행이 삭제되었습니다.'
                          : '여행 삭제에 실패했습니다.',
                      isError: !success,
                    );
                  } catch (e) {
                    String errorMsg = '';
                    if (e is Exception && e.toString().contains('Exception:')) {
                      errorMsg =
                          e.toString().replaceFirst('Exception:', '').trim();
                    } else {
                      errorMsg = e.toString();
                    }

                    // 스낵바 표시
                    scaffoldMessenger.showAppSnack(
                      '여행 삭제에 실패했습니다${errorMsg.isNotEmpty ? "\n$errorMsg" : ""}',
                      isError: true,
                    );
                  }
                },
              ),
              // 링크공유로 초대하기
              MenuItem(
                svgAsset: 'asset/icon/menu/share_edit.svg',
                text: '링크공유로 초대하기',
                onTap: () async {
                  GoRouter.of(context).pop();

                  // 여행 정보 가져오기
                  final tripState = ref.read(tripProvider).valueOrNull;
                  if (tripState is! TripModel) {
                    showAppSnackBar(
                      context,
                      '여행 정보를 불러올 수 없습니다.',
                      isError: true,
                    );
                    return;
                  }

                  final tripId = tripState.tripId;
                  final tripTitle = tripState.title;

                  // 날짜 포맷팅
                  String dateText = '날짜 미정';
                  if (tripState.startedAt != null &&
                      tripState.endedAt != null) {
                    try {
                      final start = DateTime.parse(tripState.startedAt!);
                      final end = DateTime.parse(tripState.endedAt!);
                      final formatter = DateFormat('yyyy.MM.dd');
                      dateText =
                          '${formatter.format(start)} - ${formatter.format(end)}';
                    } catch (e) {
                      // 날짜 파싱 실패 시 기본값 유지
                    }
                  }

                  final inviteLink =
                      'https://yeogiga.com/invite/$tripId?title=${Uri.encodeComponent(tripTitle)}';
                  final message =
                      '$tripTitle\n$dateText\n아래 링크를 눌러 여행에 참여하세요.\n$inviteLink';

                  try {
                    final box = context.findRenderObject() as RenderBox?;
                    final origin =
                        box != null
                            ? box.localToGlobal(Offset.zero) & box.size
                            : Rect.zero;
                    await Share.share(
                      message,
                      subject: '$tripTitle 초대 링크',
                      sharePositionOrigin: origin,
                    );

                    // 성공 메시지
                    if (!context.mounted) return;
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text('초대 링크를 공유했습니다!'),
                    //     backgroundColor: Color(0xFF38D479),
                    //     duration: Duration(seconds: 2),
                    //     behavior: SnackBarBehavior.floating,
                    //     margin: EdgeInsets.all(5.w),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(14.r),
                    //     ),
                    //     elevation: 0,
                    //   ),
                    // );
                  } catch (error) {
                    print('카카오톡 공유 실패: $error');
                    if (!context.mounted) return;
                    showAppSnackBar(
                      context,
                      '공유에 실패했습니다.',
                      isError: true,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 멤버 전용 메뉴
class TripMoreMenuSheetMember extends ConsumerWidget {
  const TripMoreMenuSheetMember({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => GoRouter.of(context).pop(),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          height: 207.h,
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
              // 여행 ID 확인하기
              // _TripMenuItem(
              //   svgUrl: 'asset/icon/menu/share_edit.svg',
              //   text: '여행 ID 확인하기',
              //   onTap: () async {
              //     final tripState = ref.read(tripProvider).valueOrNull;
              //     int? tripId;
              //     if (tripState is TripModel) {
              //       tripId = tripState.tripId;
              //     }
              //     await showDialog(
              //       context: context,
              //       builder:
              //           (context) => Dialog(
              //             backgroundColor: Colors.white,
              //             shape: RoundedRectangleBorder(
              //               borderRadius: BorderRadius.circular(14.r),
              //             ),
              //             insetPadding: EdgeInsets.all(14.w),
              //             child: Padding(
              //               padding: EdgeInsets.symmetric(
              //                 horizontal: 18.w,
              //                 vertical: 18.h,
              //               ),
              //               child: Container(
              //                 width: 1.w,
              //                 height: 59.h,
              //                 child: Center(
              //                   child: Padding(
              //                     padding: EdgeInsets.symmetric(
              //                       horizontal: 4.w,
              //                     ),
              //                     child: Text(
              //                       tripId != null
              //                           ? tripId.toString()
              //                           : '알 수 없음',
              //                       style: TextStyle(
              //                         fontSize: 18.sp,
              //                         fontWeight: FontWeight.w600,
              //                         color: const Color(0xff8287ff),
              //                       ),
              //                     ),
              //                   ),
              //                 ),
              //               ),
              //             ),
              //           ),
              //     );
              //   },
              // ),

              // 여행 탈퇴하기
              MenuItem(
                svgAsset: 'asset/icon/menu/delete_edit.svg',
                text: '여행 탈퇴하기',
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => Dialog(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          insetPadding: EdgeInsets.all(14.w),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 12.w,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Colors.red,
                                  size: 36.w,
                                ),
                                SizedBox(height: 14.h),
                                Text(
                                  '정말 탈퇴하시겠습니까?',
                                  style: TextStyle(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 15.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xffc6c6c6,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                          elevation: 0,
                                          minimumSize: Size.fromHeight(46.h),
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed:
                                            () => Navigator.of(
                                              context,
                                            ).pop(false),
                                        child: Text(
                                          '취소',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(
                                            0xFF8287FF,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                          elevation: 0,
                                          minimumSize: Size.fromHeight(46.h),
                                          padding: EdgeInsets.zero,
                                        ),
                                        onPressed:
                                            () =>
                                                Navigator.of(context).pop(true),
                                        child: Text(
                                          '탈퇴',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                  );
                  if (confirm == true) {
                    // context를 미리 저장
                    if (!context.mounted) return;
                    final navigator = Navigator.of(context);
                    final scaffoldMessenger = ScaffoldMessenger.of(context);

                    // 바텀시트 닫기
                    navigator.pop();

                    try {
                      final success =
                          await ref.read(tripProvider.notifier).leaveTrip();

                      // 성공 시 이전 화면으로 이동
                      if (success) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!navigator.mounted) return;
                          if (navigator.canPop()) {
                            navigator.pop();
                          }
                        });
                      }

                      // 스낵바 표시
                      scaffoldMessenger.showAppSnack(
                        success
                            ? '여행에서 탈퇴했습니다.'
                            : '탈퇴에 실패했습니다.',
                        isError: !success,
                      );
                    } catch (e) {
                      String errorMsg = '';
                      if (e is Exception &&
                          e.toString().contains('Exception:')) {
                        errorMsg =
                            e.toString().replaceFirst('Exception:', '').trim();
                      } else {
                        errorMsg = e.toString();
                      }

                      // 스낵바 표시
                      scaffoldMessenger.showAppSnack(
                        errorMsg,
                        isError: true,
                      );
                    }
                  }
                },
              ),
              // 링크공유로 초대하기
              MenuItem(
                svgAsset: 'asset/icon/menu/share_edit.svg',
                text: '링크공유로 초대하기',
                onTap: () async {
                  GoRouter.of(context).pop();

                  // 여행 정보 가져오기
                  final tripState = ref.read(tripProvider).valueOrNull;
                  if (tripState is! TripModel) {
                    showAppSnackBar(
                      context,
                      '여행 정보를 불러올 수 없습니다.',
                      isError: true,
                    );
                    return;
                  }

                  final tripId = tripState.tripId;
                  final tripTitle = tripState.title;

                  // 날짜 포맷팅
                  String dateText = '날짜 미정';
                  if (tripState.startedAt != null &&
                      tripState.endedAt != null) {
                    try {
                      final start = DateTime.parse(tripState.startedAt!);
                      final end = DateTime.parse(tripState.endedAt!);
                      final formatter = DateFormat('yyyy.MM.dd');
                      dateText =
                          '${formatter.format(start)} - ${formatter.format(end)}';
                    } catch (e) {
                      // 날짜 파싱 실패 시 기본값 유지
                    }
                  }

                  final inviteLink =
                      'https://yeogiga.com/invite/$tripId?title=${Uri.encodeComponent(tripTitle)}';
                  final message =
                      '$tripTitle\n$dateText\n아래 링크를 눌러 여행에 참여하세요.\n$inviteLink';

                  try {
                    final box = context.findRenderObject() as RenderBox?;
                    final origin =
                        box != null
                            ? box.localToGlobal(Offset.zero) & box.size
                            : Rect.zero;
                    await Share.share(
                      message,
                      subject: '$tripTitle 초대 링크',
                      sharePositionOrigin: origin,
                    );

                    // 성공 메시지
                    if (!context.mounted) return;
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(
                    //     content: Text('초대 링크를 공유했습니다!'),
                    //     backgroundColor: Color(0xFF38D479),
                    //     duration: Duration(seconds: 2),
                    //     behavior: SnackBarBehavior.floating,
                    //     margin: EdgeInsets.all(5.w),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(14.r),
                    //     ),
                    //     elevation: 0,
                    //   ),
                    // );
                  } catch (error) {
                    print('카카오톡 공유 실패: $error');
                    if (!context.mounted) return;
                    showAppSnackBar(
                      context,
                      '공유에 실패했습니다.',
                      isError: true,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
