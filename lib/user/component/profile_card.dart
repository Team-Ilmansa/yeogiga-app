import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userMeProvider);
    return Container(
      width: 361.w,
      height: 104.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 3),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child:
                  userState is UserResponseModel &&
                          userState.data != null &&
                          userState.data!.imageUrl != null
                      ? ClipOval(
                        child: Image.network(
                          userState.data!.imageUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                      : Icon(
                        Icons.person,
                        size: 45.sp,
                        color: Colors.grey[600],
                      ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${userState is UserResponseModel && userState.data != null ? userState.data!.nickname : '사용자'} ',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Text(
                        '님',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16.sp,
                          height: 1.4,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${userState is UserResponseModel && userState.data != null ? userState.data!.email : '이메일을 불러오는 중...'}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.4,
                          letterSpacing: -0.3,
                          color: Color(0xff7d7d7d),
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          // TODO: 프로필 관리로 이동
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '프로필 관리',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12.sp,
                                height: 1.5,
                                letterSpacing: -0.3,
                                color: Color(0xffc6c6c6),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12.sp,
                              color: Color(0xffc6c6c6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
