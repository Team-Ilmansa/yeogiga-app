import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/main_trip/view/home_screen.dart';
import 'package:yeogiga/trip/model/trip_model.dart';
import 'package:yeogiga/trip/provider/trip_provider.dart';
import 'package:yeogiga/user/view/my_page.dart';
import 'package:yeogiga/trip/component/trip_name_dialog.dart';

class ScreenWrapper extends ConsumerStatefulWidget {
  static String get routeName => 'screenWrapper';

  const ScreenWrapper({super.key});

  @override
  ConsumerState<ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends ConsumerState<ScreenWrapper> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,

      // 중앙 FAB
      floatingActionButton: Transform.translate(
        offset: Offset(0, 54.h), // 아래로 18px 이동
        child: SizedBox(
          width: 240.w,
          height: 240.h,
          child: FloatingActionButton(
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
                        //혹시나 해서 실패했을 경우 만듬
                        if (trip is! SettingTripModel) {
                          GoRouter.of(context).pop(); // 기존 다이얼로그 닫기
                          await showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder:
                                (context) => Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: SizedBox(
                                    height: 450.h,
                                    child: Center(
                                      child: Text(
                                        '여행 생성에 실패했어요! ㅠㅠ',
                                        style: TextStyle(
                                          fontSize: 60.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                          );
                        } else {
                          GoRouter.of(
                            context,
                          ).pushReplacement('/dateRangePicker');
                        }
                      },
                    ),
              );
            },
            backgroundColor: const Color(0xFF8287FF),
            shape: const CircleBorder(),
            elevation: 0,
            child: Icon(Icons.add, size: 120.sp, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 곡선 하단 바
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(60.r),
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6.r)],
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60.r),
          child: BottomAppBar(
            elevation: 0, // Material 그림자 제거, 커스텀 그림자만 사용
            color: Colors.white,
            clipBehavior: Clip.antiAlias,
            child: SizedBox(
              height: 210.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTabButton(0, 'asset/icon/home.svg', '홈'),
                  SizedBox(width: 240.w), // FAB와 동일한 공간 확보
                  _buildTabButton(1, 'asset/icon/user-02.svg', '마이페이지'),
                ],
              ),
            ),
          ),
        ),
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: const [HomeScreen(), MyPage()],
      ),
    );
  }

  // 하단 바 버튼 UI
  Widget _buildTabButton(int index, String assetPath, String title) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 24.h, bottom: 0.0),
            child: SvgPicture.asset(
              assetPath,
              width: 84.w,
              height: 84.h,
              color: isSelected ? const Color(0xFF8287FF) : Colors.grey,
            ),
          ),
          SizedBox(height: 9.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 36.sp,
              letterSpacing: -0.3,
              color:
                  isSelected
                      ? const Color(0xFF8287FF)
                      : const Color(0xffc6c6c6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
