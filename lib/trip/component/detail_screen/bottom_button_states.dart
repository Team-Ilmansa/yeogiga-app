import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../schedule/provider/confirm_schedule_provider.dart';

class AddNoticeState extends StatelessWidget {
  const AddNoticeState({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Expanded(
        //   child: ElevatedButton(
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Color(0xff8287ff),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(42.r),
        //       ),
        //       minimumSize: Size.fromHeight(156.h),
        //       elevation: 0,
        //       padding: EdgeInsets.zero,
        //     ),
        //     onPressed: () {
        //       // TODO: 일정 추가 액션
        //     },
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.center,
        //       crossAxisAlignment: CrossAxisAlignment.center,
        //       children: [
        //         SvgPicture.asset(
        //           'asset/icon/add_schedule.svg',
        //           width: 72.w,
        //           height: 72.h,
        //         ),
        //         SizedBox(width: 30.w),
        //         Text(
        //           '일정 추가하기',
        //           style: TextStyle(
        //             color: Colors.white,
        //             fontSize: 48.sp,
        //             fontWeight: FontWeight.w600,
        //             letterSpacing: -0.3,
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        // SizedBox(width: 36.w),
        SizedBox(width: 40.w),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff8287ff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(42.r),
              ),
              minimumSize: Size.fromHeight(156.h),
              elevation: 0,
              padding: EdgeInsets.zero,
            ),
            onPressed: () {
              // TODO: 공지 추가 액션
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'asset/icon/gong_ji.svg',
                  width: 72.w,
                  height: 72.h,
                ),
                SizedBox(width: 30.w),
                Text(
                  '공지 추가하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 40.w),
      ],
    );
  }
}

class AddPictureState extends StatefulWidget {
  const AddPictureState({super.key});

  @override
  State<AddPictureState> createState() => _AddPictureState();
}

class _AddPictureState extends State<AddPictureState> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 160.h,
          child: PageView(
            controller: _pageController,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            children: [
              // 사진 업로드 버튼
              Row(
                children: [
                  SizedBox(width: 40.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff8287ff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(42.r),
                        ),
                        minimumSize: Size.fromHeight(156.h),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        // TODO: 사진 업로드 액션
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'asset/icon/add_picture.svg',
                            width: 72.w,
                            height: 72.h,
                          ),
                          SizedBox(width: 30.w),
                          Text(
                            '사진 업로드하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 40.sp),
                ],
              ),
              // 사진 매핑/리매핑 버튼 (두 개를 Row로 묶어서 한 페이지에)
              Row(
                children: [
                  Icon(Icons.chevron_left, size: 40.sp),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff8287ff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(42.r),
                        ),
                        minimumSize: Size.fromHeight(156.h),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        // TODO: 사진 매핑 api 호출
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '사진 맵핑하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 36.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff8287ff),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(42.r),
                        ),
                        minimumSize: Size.fromHeight(156.h),
                        elevation: 0,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {
                        // TODO: 사진 리매핑 api 호출
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '리매핑하기',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 40.w),
                ],
              ),
            ],
          ),
        ),
        // SizedBox(height: 18.h),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: List.generate(
        //     2,
        //     (idx) => Container(
        //       width: 18.w,
        //       height: 18.w,
        //       margin: EdgeInsets.symmetric(horizontal: 6.w),
        //       decoration: BoxDecoration(
        //         shape: BoxShape.circle,
        //         color:
        //             _currentPage == idx ? Color(0xff8287ff) : Color(0xffe0e0e0),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}

class PictureOptionState extends StatelessWidget {
  const PictureOptionState({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffc6c6c6),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              onPressed: () {}, // 삭제 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('asset/icon/delete.svg'),
                  SizedBox(height: 6.h),
                  Text(
                    '삭제',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 36.sp,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffc6c6c6),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              onPressed: () {}, // 공유 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('asset/icon/share.svg'),
                  SizedBox(height: 6.h),
                  Text(
                    '공유',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 36.sp,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xffc6c6c6),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              onPressed: () {}, // 저장 액션
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('asset/icon/download.svg'),
                  SizedBox(height: 6.h),
                  Text(
                    '내 갤러리에 저장',
                    style: TextStyle(
                      color: Color(0xffc6c6c6),
                      fontSize: 36.sp,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ConfirmScheduleState extends ConsumerWidget {
  final int tripId;
  final int lastDay;
  const ConfirmScheduleState({
    super.key,
    required this.tripId,
    required this.lastDay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        SizedBox(width: 40.w),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8287FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(42.r),
            ),
            elevation: 0,
            minimumSize: Size.fromHeight(156.h),
            padding: EdgeInsets.zero,
          ),
          onPressed: () async {
            final scaffoldContext = context;
            final confirm = await showDialog<bool>(
              context: scaffoldContext,
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
                            Icons.info_outline,
                            color: Color(0xFF8287FF),
                            size: 120.w,
                          ),
                          SizedBox(height: 48.h),
                          Text(
                            '정말 여행 일정을 확정하시겠습니까?',
                            style: TextStyle(
                              fontSize: 56.sp,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff313131),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 50.h),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xffc6c6c6),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(42.r),
                                    ),
                                    elevation: 0,
                                    minimumSize: Size.fromHeight(156.h),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
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
                                    backgroundColor: const Color(0xFF8287FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(42.r),
                                    ),
                                    elevation: 0,
                                    minimumSize: Size.fromHeight(156.h),
                                    padding: EdgeInsets.zero,
                                  ),
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: Text(
                                    '확정',
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
            if (confirm != true) return;

            bool success = false;
            String? errorMsg;
            try {
              final notifier = ref.read(confirmScheduleProvider.notifier);
              success = await notifier.confirmAndRefreshTrip(
                tripId: tripId,
                lastDay: lastDay,
                ref: ref,
              );
            } catch (e) {
              success = false;
              if (e is Exception && e.toString().contains('Exception:')) {
                errorMsg = e.toString().replaceFirst('Exception:', '').trim();
              } else {
                errorMsg = e.toString();
              }
            }
            if (scaffoldContext.mounted) {
              await showDialog(
                context: scaffoldContext,
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
                              success
                                  ? Icons.check_circle_outline
                                  : Icons.error_outline,
                              color:
                                  success
                                      ? const Color(0xFF8287FF)
                                      : Colors.red,
                              size: 120.w,
                            ),
                            SizedBox(height: 48.h),
                            Text(
                              success
                                  ? '여행 일정이 확정되었습니다!'
                                  : '일정 확정에 실패했습니다${errorMsg != null ? "\n$errorMsg" : ""}',
                              style: TextStyle(
                                fontSize: 56.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff313131),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 50.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      success
                                          ? const Color(0xFF8287FF)
                                          : Colors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(42.r),
                                  ),
                                  elevation: 0,
                                  minimumSize: Size.fromHeight(156.h),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () => Navigator.of(context).pop(),
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
                          ],
                        ),
                      ),
                    ),
              );
            }
          },
          child: Text(
            '여행 일정 확정하기',
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 40.w),
      ],
    );
  }
}

class ConfirmCalendarState extends StatelessWidget {
  const ConfirmCalendarState({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 40.w),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8287FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(42.r),
            ),
            elevation: 0,
            minimumSize: Size.fromHeight(156.h),
            padding: EdgeInsets.zero,
          ),
          onPressed: () {
            // TODO: 날짜 지정 화면으로 이동
            GoRouter.of(context).push('/W2mConfirmScreen');
          },
          child: Text(
            '여행 날짜 확정하기',
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(width: 40.w),
      ],
    );
  }
}
