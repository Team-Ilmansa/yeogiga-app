import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'dart:math'; // Added dart:math import for asin function
import 'package:yeogiga/main_trip/view/home_screen.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/user/view/my_page.dart';
import 'package:yeogiga/trip/component/create_trip/trip_name_dialog.dart';
import 'package:yeogiga/trip_list/provider/trip_list_provider.dart';
import 'package:yeogiga/main_trip/provider/main_trip_provider.dart';
import 'package:yeogiga/w2m/provider/user_w2m_provider.dart';
import 'package:yeogiga/schedule/provider/confirm_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/pending_schedule_provider.dart';
import 'package:yeogiga/schedule/provider/completed_schedule_provider.dart';

class ScreenWrapper extends ConsumerStatefulWidget {
  static String get routeName => 'screenWrapper';

  const ScreenWrapper({super.key});

  @override
  ConsumerState<ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends ConsumerState<ScreenWrapper> {
  int _selectedIndex = 0;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // ScreenWrapper 진입 시, 로그인/유저정보(mainTripFutureProvider, userMeProvider) 제외 모든 provider refresh
    Future.microtask(() {
      ref.refresh(tripProvider);
      ref.refresh(tripListProvider);
      ref.refresh(userW2mProvider);
      ref.refresh(confirmScheduleProvider);
      ref.refresh(pendingScheduleProvider);
      ref.refresh(completedScheduleProvider);
      ref.refresh(mainTripFutureProvider);
      // 필요시 추가 provider도 여기에!
    });

    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,

      bottomNavigationBar: Container(
        height: 90.h,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 90.h),
              painter: ConvexBottomBarPainter(),
            ),
            Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    0,
                    'asset/icon/home.svg',
                    '홈',
                    refresh: () => ref.refresh(mainTripFutureProvider),
                  ),
                ),
                Container(
                  width: 100.w,
                  height: 90.h,
                  alignment: Alignment.center,
                  child: Container(
                    width: 80.w,
                    height: 80.h,
                    transform: Matrix4.translationValues(0, -15.h, 0),
                    child: ElevatedButton(
                      onPressed: () async {
                        final nameController = TextEditingController();
                        await showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder:
                              (context) => TripNameDialog(
                                nameController: nameController,
                                onConfirm: () async {
                                  TripBaseModel trip = await ref
                                      .read(tripProvider.notifier)
                                      .postTrip(title: nameController.text);
                                  if (trip is! SettingTripModel) {
                                    if (!mounted) return;
                                    GoRouter.of(context).pop();
                                    await showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder:
                                          (context) => Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(18),
                                            ),
                                            child: SizedBox(
                                              height: 134.h,
                                              child: Center(
                                                child: Text(
                                                  '여행 생성에 실패했어요! ㅠㅠ',
                                                  style: TextStyle(
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                    );
                                  } else {
                                    if (!mounted) return;
                                    Navigator.of(context).pop();
                                    GoRouter.of(
                                      context,
                                    ).push('/dateRangePicker');
                                  }
                                },
                              ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8287FF),
                        elevation: 0,
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      child: Icon(Icons.add, size: 40.sp, color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    1,
                    'asset/icon/user-02.svg',
                    '마이페이지',
                    refresh:
                        () =>
                            ref
                                .read(tripListProvider.notifier)
                                .fetchAndSetTrips(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const [HomeScreen(), MyPage()],
      ),
    );
  }

  Widget _buildTabButton(
    int index,
    String assetPath,
    String title, {
    VoidCallback? refresh,
  }) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _selectedIndex = index);
        _pageController.animateToPage(
          index,
          duration: Duration(milliseconds: 300),
          curve: Curves.ease,
        );
        if (refresh != null) refresh();
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetPath,
              width: 32.w,
              height: 32.h,
              color:
                  isSelected
                      ? const Color(0xFF8287FF)
                      : const Color(0xFFB8B8B8),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                letterSpacing: -0.1,
                color:
                    isSelected
                        ? const Color(0xFF8287FF)
                        : const Color(0xFFB8B8B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConvexBottomBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    print(
      "[v0] Painting convex bottom bar with size: ${size.width} x ${size.height}",
    );

    final bottomBarShadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.2)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    final semicircleShadowPaint =
        Paint()
          ..color = Colors.black.withOpacity(0.12)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final path = Path();

    final centerX = size.width / 2;
    final radius = 50.w;
    final cornerRadius = 30.r;
    final semicircleCenterY = 30.h; // 15.h + 10.h + 5.h = 30.h

    final connectionOffset = sqrt(
      (radius * radius - semicircleCenterY * semicircleCenterY).abs(),
    );

    // Start from bottom left
    path.moveTo(0, size.height);

    // Left side up to corner
    path.lineTo(0, cornerRadius);

    // Left top corner
    path.quadraticBezierTo(0, 0, cornerRadius, 0);

    // Left side to semicircle start
    path.lineTo(centerX - connectionOffset, 0);

    path.arcTo(
      Rect.fromCircle(
        center: Offset(centerX, semicircleCenterY),
        radius: radius,
      ),
      pi +
          asin(
            semicircleCenterY / radius,
          ), // Start angle adjusted for connection point
      pi -
          2 *
              asin(
                semicircleCenterY / radius,
              ), // Sweep angle adjusted for visible portion
      false,
    );

    // Right side from semicircle
    path.lineTo(size.width - cornerRadius, 0);

    // Right top corner
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);

    // Right side down
    path.lineTo(size.width, size.height);

    // Bottom line
    path.lineTo(0, size.height);

    // Close path
    path.close();

    final semicircleShadowPath = Path();
    semicircleShadowPath.moveTo(centerX - connectionOffset, 0);
    semicircleShadowPath.arcTo(
      Rect.fromCircle(
        center: Offset(centerX, semicircleCenterY),
        radius: radius,
      ),
      pi + asin(semicircleCenterY / radius),
      pi - 2 * asin(semicircleCenterY / radius),
      false,
    );
    semicircleShadowPath.lineTo(centerX - connectionOffset, 0);
    semicircleShadowPath.close();

    // Shadow path (same as main path)
    final bottomBarShadowPath = Path.from(path);

    canvas.save();
    canvas.translate(0, 0.5);
    canvas.drawPath(bottomBarShadowPath, bottomBarShadowPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(0, -0.5);
    canvas.drawPath(semicircleShadowPath, semicircleShadowPaint);
    canvas.restore();

    canvas.drawPath(path, paint);

    print("[v0] Fixed path connection points to prevent tilting");
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
