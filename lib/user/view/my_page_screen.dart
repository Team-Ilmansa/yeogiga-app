import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/user/component/profile_card.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyPageScreen> {
  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userMeProvider);

    return Container(
      color: Color(0xfffafafa),
      child: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 116.h),
                  Text(
                    '${userState is UserResponseModel && userState.data != null ? userState.data!.nickname : '사용자'}님의\n마이페이지',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ProfileCard(), //프로필 카드 부분
                  SizedBox(height: 60.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '즐겨찾기한 사진',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          height: 1.4,
                          letterSpacing: -0.3,
                          color: Color(0xff313131),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          //TODO: 어디로?
                        },
                        child: Text(
                          '더보기',
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.5,
                            letterSpacing: -0.3,
                            color: Color(0xffc6c6c6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  //TODO: 즐겨찾기한 사진 그리드 뷰
                  SizedBox(height: 60.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '지난 여행 전체보기',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp,
                          height: 1.4,
                          letterSpacing: -0.3,
                          color: Color(0xff313131),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          //TODO: 어디로?
                        },
                        child: Text(
                          '더보기',
                          style: TextStyle(
                            fontSize: 12.sp,
                            height: 1.5,
                            letterSpacing: -0.3,
                            color: Color(0xffc6c6c6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  //TODO: 지난 여행 전체보기 슬라이드 뷰
                  SizedBox(height: 20.h),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              height: 12.h,
              color: Color(0xfff0f0f0),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 66.h,
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 13.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '문의하기',
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.4,
                      letterSpacing: -0.3,
                      color: Color(0xff313131),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 66.h,
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 13.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '로그아웃',
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.4,
                      letterSpacing: -0.3,
                      color: Color(0xff313131),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 66.h,
              child: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 13.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '탈퇴하기',
                    style: TextStyle(
                      fontSize: 16.sp,
                      height: 1.4,
                      letterSpacing: -0.3,
                      color: Color(0xff313131),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }
}
