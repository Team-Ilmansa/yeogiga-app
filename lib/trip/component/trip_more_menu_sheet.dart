import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/component/custom_text_form_field.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

// 방장 전용 메뉴
class TripMoreMenuSheetLeader extends ConsumerWidget {
  const TripMoreMenuSheetLeader({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trip = ref.watch(tripProvider) as TripModel;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 1004.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(36.r),
                  ),
                ),
                padding: EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: 24.h,
                  bottom: 36.h + MediaQuery.of(context).viewPadding.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 333.w,
                      height: 18.h,
                      margin: EdgeInsets.only(bottom: 28.h, top: 14.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),

                    // TODO: 여행 ID 확인하기
                    _TripMenuItem(
                      svgUrl: 'asset/icon/menu/share_edit.svg',
                      text: '여행 ID 확인하기',
                      onTap: () async {
                        final tripState = ref.read(tripProvider);
                        int? tripId;
                        if (tripState is TripModel) {
                          tripId = tripState.tripId;
                        }
                        await showDialog(
                          context: context,
                          builder:
                              (context) => Dialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(48.r),
                                ),
                                insetPadding: EdgeInsets.all(48.w),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 60.w,
                                    vertical: 60.h,
                                  ),
                                  child: Container(
                                    width: 0.w,
                                    height: 200.h,
                                    child: Center(
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 15.w,
                                          ),
                                          child: Text(
                                            tripId != null
                                                ? tripId.toString()
                                                : '알 수 없음',
                                            style: TextStyle(
                                              fontSize: 60.sp,
                                              fontWeight: FontWeight.w600,
                                              color: const Color(0xff8287ff),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        );
                      },
                    ),
                    // TODO: 여행 이름 수정하기
                    _TripMenuItem(
                      svgUrl: 'asset/icon/menu/title_edit.svg',
                      text: '여행 개요 수정하기',
                      onTap: () async {
                        final controller = TextEditingController();
                        final result = await showDialog<String>(
                          context: context,
                          builder:
                              (context) => Dialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(60.r),
                                ),
                                insetPadding: EdgeInsets.all(100.w),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 40.w,
                                    vertical: 40.h,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 15.w,
                                        ),
                                        child: Text(
                                          '여행 개요 수정',
                                          style: TextStyle(
                                            fontSize: 54.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xff313131),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 48.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 15.w,
                                        ),
                                        child: CustomTextFormField(
                                          controller: controller,
                                          hintText: '새 여행 이름을 입력하세요',
                                          onChanged: (value) {},
                                        ),
                                      ),
                                      SizedBox(height: 40.h),
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
                                                borderRadius:
                                                    BorderRadius.circular(42.r),
                                              ),
                                              elevation: 0,
                                              minimumSize: Size(0, 150.h),
                                              padding: EdgeInsets.zero,
                                            ),
                                            onPressed:
                                                () => Navigator.of(
                                                  context,
                                                ).pop(controller.text.trim()),
                                            child: Text(
                                              '확인',
                                              style: TextStyle(
                                                fontSize: 48.sp,
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? '여행 이름이 수정되었습니다.'
                                      : '여행 이름 수정에 실패했습니다.',
                                ),
                                backgroundColor:
                                    success
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
                                margin: EdgeInsets.all(16.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(48.r),
                                ),
                                elevation: 0,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            GoRouter.of(context).pop();
                          } catch (e) {
                            String errorMsg = '';
                            if (e is Exception &&
                                e.toString().contains('Exception:')) {
                              errorMsg =
                                  e
                                      .toString()
                                      .replaceFirst('Exception:', '')
                                      .trim();
                            } else {
                              errorMsg = e.toString();
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '여행 이름 수정에 실패했습니다${errorMsg.isNotEmpty ? "\n$errorMsg" : ""}',
                                  style: TextStyle(
                                    fontSize: 48.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.all(16.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(48.r),
                                ),
                                elevation: 0,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            GoRouter.of(context).pop();
                          }
                        }
                      },
                    ),
                    // TODO: 날짜 수정하기
                    _TripMenuItem(
                      svgUrl: 'asset/icon/menu/calendar_edit.svg',
                      text: '일정 수정하기',
                      onTap: () {
                        GoRouter.of(context).pop();
                        GoRouter.of(context).push('/W2mConfirmScreen');
                        // TODO: 일정 수정
                      },
                    ),
                    // TODO: 여행 삭제하기
                    _TripMenuItem(
                      svgUrl: 'asset/icon/menu/delete_edit.svg',
                      text: '여행 삭제하기',
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => Dialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(60.r),
                                ),
                                insetPadding: EdgeInsets.all(100.w),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 50.h,
                                    horizontal: 50.w,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 10.h),
                                      Text(
                                        '${trip.title}을 정말로 삭제하시겠어요?',
                                        style: TextStyle(
                                          fontSize: 60.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                          letterSpacing: -0.9.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 10.h),
                                      Text(
                                        '해당 작업은 복구할 수 없어요',
                                        style: TextStyle(
                                          color: Color(0xff7d7d7d),
                                          fontSize: 42.sp,
                                        ),
                                      ),
                                      SizedBox(height: 150.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xfff0f0f0,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        42.r,
                                                      ),
                                                ),
                                                elevation: 0,
                                                minimumSize: Size.fromHeight(
                                                  160.h,
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                              child: Text(
                                                '취소',
                                                style: TextStyle(
                                                  fontSize: 48.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 32.w),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFFf0f0f0,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        42.r,
                                                      ),
                                                ),
                                                elevation: 0,
                                                minimumSize: Size.fromHeight(
                                                  160.h,
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                              child: Text(
                                                '삭제하기',
                                                style: TextStyle(
                                                  fontSize: 48.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.red,
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
                        if (confirm != true) return;
                        GoRouter.of(context).pop();
                        try {
                          final success =
                              await ref
                                  .read(tripProvider.notifier)
                                  .deleteTrip();
                          GoRouter.of(context).pop(); // 화면 닫기(성공/실패 모두)
                          Future.microtask(() {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success ? '여행이 삭제되었습니다.' : '여행 삭제에 실패했습니다.',
                                    style: TextStyle(
                                      fontSize: 48.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor:
                                      success
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
                                  margin: EdgeInsets.all(16.w),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(48.r),
                                  ),
                                  elevation: 0,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          });
                        } catch (e) {
                          String errorMsg = '';
                          if (e is Exception &&
                              e.toString().contains('Exception:')) {
                            errorMsg =
                                e
                                    .toString()
                                    .replaceFirst('Exception:', '')
                                    .trim();
                          } else {
                            errorMsg = e.toString();
                          }
                          if (context.mounted) {
                            GoRouter.of(context).pop();
                          }
                          Future.microtask(() {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '여행 삭제에 실패했습니다${errorMsg.isNotEmpty ? "\n$errorMsg" : ""}',
                                    style: TextStyle(
                                      fontSize: 48.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  margin: EdgeInsets.all(16.w),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(48.r),
                                  ),
                                  elevation: 0,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          });
                        }
                      },
                    ),
                    // _TripMenuItem(
                    //   svgUrl: 'asset/icon/menu/share_edit.svg',
                    //   text: '링크공유로 초대하기',
                    //   onTap: () {
                    //     GoRouter.of(context).pop();
                    //     // TODO: 링크공유
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
      onTap: () => Navigator.of(context).pop(),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 620.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(36.r),
                  ),
                ),
                padding: EdgeInsets.only(
                  left: 0,
                  right: 0,
                  top: 24.h,
                  bottom: 36.h + MediaQuery.of(context).viewPadding.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 333.w,
                      height: 18.h,
                      margin: EdgeInsets.only(bottom: 28.h, top: 14.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDEDED),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    // 여행 ID 확인하기
                    _TripMenuItem(
                      svgUrl: 'asset/icon/menu/share_edit.svg',
                      text: '여행 ID 확인하기',
                      onTap: () async {
                        final tripState = ref.read(tripProvider);
                        int? tripId;
                        if (tripState is TripModel) {
                          tripId = tripState.tripId;
                        }
                        await showDialog(
                          context: context,
                          builder:
                              (context) => Dialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(48.r),
                                ),
                                insetPadding: EdgeInsets.all(48.w),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 60.w,
                                    vertical: 60.h,
                                  ),
                                  child: Container(
                                    width: 0.w,
                                    height: 200.h,
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 15.w,
                                        ),
                                        child: Text(
                                          tripId != null
                                              ? tripId.toString()
                                              : '알 수 없음',
                                          style: TextStyle(
                                            fontSize: 60.sp,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xff8287ff),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                        );
                      },
                    ),
                    // 여행 탈퇴하기
                    _TripMenuItem(
                      svgUrl: 'asset/icon/menu/delete_edit.svg',
                      text: '여행 탈퇴하기',
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => Dialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(48.r),
                                ),
                                insetPadding: EdgeInsets.all(48.w),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 40.h,
                                    horizontal: 40.w,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.warning_amber_rounded,
                                        color: Colors.red,
                                        size: 120.w,
                                      ),
                                      SizedBox(height: 48.h),
                                      Text(
                                        '정말 탈퇴하시겠습니까?',
                                        style: TextStyle(
                                          fontSize: 56.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 50.h),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xffc6c6c6,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        42.r,
                                                      ),
                                                ),
                                                elevation: 0,
                                                minimumSize: Size.fromHeight(
                                                  156.h,
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(false),
                                              child: Text(
                                                '취소',
                                                style: TextStyle(
                                                  fontSize: 48.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 32.w),
                                          Expanded(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF8287FF,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        42.r,
                                                      ),
                                                ),
                                                elevation: 0,
                                                minimumSize: Size.fromHeight(
                                                  156.h,
                                                ),
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed:
                                                  () => Navigator.of(
                                                    context,
                                                  ).pop(true),
                                              child: Text(
                                                '탈퇴',
                                                style: TextStyle(
                                                  fontSize: 48.sp,
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
                          try {
                            final success =
                                await ref
                                    .read(tripProvider.notifier)
                                    .leaveTrip();
                            GoRouter.of(context).pop();
                            if (success) GoRouter.of(context).pop();
                            Future.microtask(() {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success ? '여행에서 탈퇴했습니다.' : '탈퇴에 실패했습니다.',
                                      style: TextStyle(
                                        fontSize: 48.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    backgroundColor:
                                        success
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
                                    margin: EdgeInsets.all(16.w),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(48.r),
                                    ),
                                    elevation: 0,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            });
                          } catch (e) {
                            String errorMsg = '';
                            if (e is Exception &&
                                e.toString().contains('Exception:')) {
                              errorMsg =
                                  e
                                      .toString()
                                      .replaceFirst('Exception:', '')
                                      .trim();
                            } else {
                              errorMsg = e.toString();
                            }
                            GoRouter.of(context).pop();
                            Future.microtask(() {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      errorMsg,
                                      style: TextStyle(
                                        fontSize: 48.sp,
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
                                    margin: EdgeInsets.all(16.w),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(48.r),
                                    ),
                                    elevation: 0,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripMenuItem extends StatelessWidget {
  // final IconData icon;
  final String svgUrl;
  final String text;
  final VoidCallback onTap;
  const _TripMenuItem({
    // required this.icon,
    required this.svgUrl,
    required this.text,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 192.h,
        child: Row(
          children: [
            SizedBox(width: 40.w),
            // Icon(icon, color: Colors.black87, size: 72.sp),
            SvgPicture.asset(svgUrl, height: 72.h, width: 72.w),
            SizedBox(width: 40.w),
            Text(
              text,
              style: TextStyle(
                fontSize: 48.sp,
                color: Color(0xff313131),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
