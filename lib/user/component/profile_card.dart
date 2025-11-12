import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';
import 'package:yeogiga/common/utils/profile_placeholder_util.dart';

class ProfileCard extends ConsumerWidget {
  final VoidCallback? onManageProfile;

  const ProfileCard({super.key, this.onManageProfile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userMeProvider);
    final user =
        userState is UserResponseModel
            ? userState.data
            : userState is UserModel
            ? userState
            : null;
    final isSocialLogin =
        user != null && (user.username == null || user.username!.isEmpty);
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
            user != null && user.imageUrl != null
                ? ClipOval(
                  child: Image.network(
                    user.imageUrl!,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                  ),
                )
                : buildProfileAvatarPlaceholder(
                  nickname: user?.nickname ?? '사용자',
                  size: 80.w,
                ),
            SizedBox(width: 16.w),
            Flexible(
              fit: FlexFit.loose,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (isSocialLogin)
                          Padding(
                            padding: EdgeInsets.only(right: 6.w),
                            child: Image.asset(
                              'asset/img/oauth/kakao.png',
                              width: 20.w,
                              height: 20.w,
                            ),
                          ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${user?.nickname ?? '사용자'} ',
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
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        if (user?.email != null)
                          Expanded(
                            child: Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.4,
                                letterSpacing: -0.3,
                                color: Color(0xff7d7d7d),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        GestureDetector(
                          onTap: onManageProfile,
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
            ),
          ],
        ),
      ),
    );
  }
}
