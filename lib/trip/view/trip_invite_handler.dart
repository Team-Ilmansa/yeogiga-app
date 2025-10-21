import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';

/// 딥링크로 여행 초대 링크를 클릭했을 때 처리하는 화면
/// 자동으로 joinTrip() API를 호출하고 결과에 따라 화면 이동
class TripInviteHandler extends ConsumerStatefulWidget {
  final int? tripId;

  const TripInviteHandler({super.key, this.tripId});

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
    // 로딩 화면 표시
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '여행 초대',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF313131),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              '여행 ID ${widget.tripId ?? '-'}에 초대되었습니다.\n참가하시겠습니까?',
              style: TextStyle(
                fontSize: 15.sp,
                color: const Color(0xFF505050),
                height: 1.5,
              ),
            ),
            SizedBox(height: 28.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/'),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFBDBDBD)),
                      foregroundColor: const Color(0xFF505050),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: const Text('거절'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleInvite,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8287FF),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      '참가하기',
                      style: TextStyle(
                        fontSize: 16.sp,
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
    );
  }
}
