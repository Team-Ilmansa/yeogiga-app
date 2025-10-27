import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

/// 딥링크로 여행 초대 링크를 클릭했을 때 처리하는 화면
/// 자동으로 joinTrip() API를 호출하고 결과에 따라 화면 이동
class TripInviteHandler extends ConsumerStatefulWidget {
  final int? tripId;
  final String? tripTitle;

  const TripInviteHandler({super.key, this.tripId, this.tripTitle});

  @override
  ConsumerState<TripInviteHandler> createState() => _TripInviteHandlerState();
}

class _TripInviteHandlerState extends ConsumerState<TripInviteHandler> {
  /// 여행 초대 처리
  Future<void> _handleInvite() async {
    // tripId 유효성 검사
    if (widget.tripId == null || widget.tripId! <= 0) {
      _showErrorAndGoHome('유효하지 않은 초대 링크입니다.');
      return;
    }

    try {
      // joinTrip API 호출 (positional parameter)
      final success = await ref
          .read(tripProvider.notifier)
          .joinTrip(widget.tripId!);

      if (!mounted) return;

      if (success) {
        // 성공: 여행 상세 화면으로 이동

        final router = GoRouter.of(context);
        final navigator = Navigator.of(context);

        if (navigator.canPop()) {
          navigator.pop();
        }

        router.go('/tripDetailScreen/${widget.tripId}');

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('여행에 참가했습니다!'),
            backgroundColor: Color(0xFF38D479),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(5.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            elevation: 0,
          ),
        );
      } else {
        // 실패
        _showErrorAndGoHome('여행 참가에 실패했습니다.');
      }
    } catch (e) {
      // 에러 처리
      String errorMsg = '알 수 없는 오류가 발생했습니다.';

      // 에러 메시지 파싱
      String errorStr = e.toString();
      if (errorStr.contains('이미')) {
        errorMsg = '이미 참가한 여행입니다.';

        // 이미 참가한 경우 → 여행 상세로 바로 이동
        if (mounted) {
          final router = GoRouter.of(context);
          final navigator = Navigator.of(context);

          if (navigator.canPop()) {
            navigator.pop();
          }

          router.go('/tripDetailScreen/${widget.tripId}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('이미 참가 중인 여행입니다.'),
              backgroundColor: Color(0xFF8287FF),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(5.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              elevation: 0,
            ),
          );
          return;
        }
      } else if (errorStr.contains('존재하지')) {
        errorMsg = '존재하지 않는 여행입니다.';
      } else if (errorStr.contains('권한')) {
        errorMsg = '참가 권한이 없습니다.';
      }

      _showErrorAndGoHome(errorMsg);
    }
  }

  /// 에러 메시지를 표시하고 홈으로 이동
  void _showErrorAndGoHome(String message) {
    if (!mounted) return;

    // 에러 스낵바 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Color(0xFFE25141),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(5.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        elevation: 0,
      ),
    );

    // 1초 후 홈으로 이동
    Future.delayed(Duration(seconds: 1), () {
      if (!mounted) return;
      final router = GoRouter.of(context);
      final navigator = Navigator.of(context);

      if (navigator.canPop()) {
        navigator.pop();
      } else {
        router.go('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripProvider);

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 16.sp),
          onPressed: () => context.go('/'),
        ),
      ),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 130.h),
            // 초대 아이콘 + 배경 원형 디자인
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF8287FF).withOpacity(0.1),
                    const Color(0xFF8287FF).withOpacity(0.05),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 90.w,
                  height: 90.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8287FF).withOpacity(0.15),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'asset/icon/share.svg',
                      width: 40.w,
                      height: 40.h,
                      colorFilter: ColorFilter.mode(
                        const Color(0xFF8287FF),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // 제목 - 중앙 정렬
            Text(
              '여행 초대',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF313131),
                fontSize: 24.sp,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                height: 1.40,
                letterSpacing: -0.60,
              ),
            ),
            SizedBox(height: 12.h),
            // 설명 - 중앙 정렬
            Text(
              '여행에 초대되었습니다.\n참가하시겠습니까?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFF7D7D7D),
                fontSize: 15.sp,
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                height: 1.5,
                letterSpacing: -0.42,
              ),
            ),
            SizedBox(height: 24.h),
            // 여행 이름 뱃지 디자인 (여행 이름이 있으면 표시, 없으면 Trip ID)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5FF),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF8287FF).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.tripTitle != null ? Icons.card_travel : Icons.tag,
                    size: 18.sp,
                    color: const Color(0xFF8287FF),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    widget.tripTitle ?? 'Trip ID: ${widget.tripId ?? '-'}',
                    style: TextStyle(
                      color: const Color(0xFF8287FF),
                      fontSize: 14.sp,
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.go('/'),
                    child: Container(
                      height: 52.h,
                      decoration: ShapeDecoration(
                        color: const Color(0xFFF0F0F0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '거절',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFF313131),
                            fontSize: 16.sp,
                            fontFamily: 'Pretendard',
                            fontWeight: FontWeight.w600,
                            height: 1.40,
                            letterSpacing: -0.48,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: tripState.when(
                      data: (_) => _handleInvite,
                      loading: () => null,
                      error: (_, __) => _handleInvite,
                    ),
                    child: Container(
                      height: 52.h,
                      decoration: ShapeDecoration(
                        color:
                            tripState.isLoading
                                ? const Color(0xFFD9D9D9)
                                : const Color(0xFF8287FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        shadows: [
                          BoxShadow(
                            color: const Color(0xFF8287FF).withOpacity(0.3),
                            blurRadius: 4,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: Center(
                        child: tripState.when(
                          data:
                              (_) => Text(
                                '참가하기',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                  letterSpacing: -0.48,
                                ),
                              ),
                          loading:
                              () => SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                          error:
                              (_, __) => Text(
                                '참가하기',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontFamily: 'Pretendard',
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                  letterSpacing: -0.48,
                                ),
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
