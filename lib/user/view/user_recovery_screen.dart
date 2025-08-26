import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';

class UserRecoveryScreen extends ConsumerWidget {
  static String get routeName => 'userRecovery';

  const UserRecoveryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userMeProvider);

    // UserDeleteModel이 아니면 로그인 화면으로 리다이렉트
    if (state is! UserDeleteModel) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userData = state.data;
    final nickname = userData.nickname;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      // 계정 복구하기 버튼 섹션
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(21.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          11.w,
          11.h,
          11.w,
          MediaQuery.of(context).viewInsets.bottom + 22.h,
        ),
        child: ElevatedButton(
          onPressed: () async {
            // 계정 복구 API 호출
            final success =
                await ref.read(userMeProvider.notifier).restoreAccount();

            if (success) {
              _showRecoverySuccessDialog(context, ref);
            } else {
              _showRecoveryFailDialog(context, ref);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff8287ff),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11.r),
            ),
            elevation: 0,
          ),
          child: Text(
            '계정 복구하기',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 뒤로가기 버튼
                  Padding(
                    padding: EdgeInsets.fromLTRB(5.w, 11.h, 0, 11.h),
                    child: GestureDetector(
                      onTap: () async {
                        await ref.read(userMeProvider.notifier).logout();
                        if (!context.mounted) return;
                        context.go('/login');
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 18.sp,
                      ),
                    ),
                  ),

                  SizedBox(height: 21.h),

                  // 제목
                  Text(
                    '계정을\n복구하시겠어요?',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  // 안내 메시지
                  Text(
                    '탈퇴한 계정으로 일주일 이내에 재로그인시 계정 복구가 가능합니다.\n복구를 원하지 않으시다면 뒤로가기를 눌러주세요.',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Color(0xff7D7D7D),
                      height: 1.4,
                      letterSpacing: -0.3,
                    ),
                  ),
                  // 마감일 안내 (빨간색)
                  Text(
                    '${userData.deletionExpiration} 오전 00:00이후에는 복구가 불가능합니다',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Color(0xffff0000),
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                      letterSpacing: -0.3,
                    ),
                  ),

                  SizedBox(height: 82.h),

                  // 중앙 프로필 이미지 영역
                  Center(
                    child: Column(
                      children: [
                        // 프로필 이미지 (회색 원형)
                        Container(
                          width: 160.w,
                          height: 160.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child:
                              userData.imageUrl != null
                                  ? ClipOval(
                                    child: Image.network(
                                      userData.imageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : Icon(
                                    Icons.person,
                                    size: 45.sp,
                                    color: Colors.grey[600],
                                  ),
                        ),

                        SizedBox(height: 20.h),

                        // 닉네임
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$nickname',
                              style: TextStyle(
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff313131),
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              '님',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff313131),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 134.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showRecoverySuccessDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 10.h),
            actionsPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            title: Text(
              '계정 복구 완료',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            content: Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                '계정이 성공적으로 복구되었습니다.\n다시 로그인해주세요.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Color(0xff7D7D7D),
                  height: 1.4,
                ),
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    // 복구 성공 시 로그아웃하여 state를 null로 변경
                    await ref.read(userMeProvider.notifier).logout();
                    if (!context.mounted) return;
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff8287ff),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  void _showRecoveryFailDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 10.h),
            actionsPadding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            title: Text(
              '계정 복구 실패',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            content: Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                '계정 복구에 실패했습니다.\n잠시 후 다시 시도해주세요.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Color(0xff7D7D7D),
                  height: 1.4,
                ),
              ),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await ref.read(userMeProvider.notifier).logout();
                    if (!context.mounted) return;
                    context.go('/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff8287ff),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
