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
          borderRadius: BorderRadius.circular(72.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              spreadRadius: 0,
              blurRadius: 24,
              offset: const Offset(0, -12),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
          36.w,
          36.h,
          36.w,
          MediaQuery.of(context).viewInsets.bottom + 75.h,
        ),
        child: ElevatedButton(
          onPressed: () async {
            // 계정 복구 API 호출
            final success = await ref.read(userMeProvider.notifier).restoreAccount();
            
            if (success) {
              _showRecoverySuccessDialog(context);
            } else {
              _showRecoveryFailDialog(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff8287ff),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 48.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(36.r),
            ),
            elevation: 0,
          ),
          child: Text(
            '계정 복구하기',
            style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w500),
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
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 뒤로가기 버튼
                  Padding(
                    padding: EdgeInsets.only(top: 24.h),
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 60.sp,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 60.h),
                  
                  // 제목
                  Text(
                    '계정을\n복구하시겠어요?',
                    style: TextStyle(
                      fontSize: 96.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.2,
                    ),
                  ),
                  
                  SizedBox(height: 60.h),
                  
                  // 안내 메시지
                  Text(
                    '탈퇴한 계정으로 일주일 이내에 재로그인시 계정 복구가 가능합니다.\n복구를 원하지 않으시다면 뒤로가기를 눌러주세요.',
                    style: TextStyle(
                      fontSize: 42.sp,
                      color: Colors.black87,
                      height: 1.6,
                      letterSpacing: -0.3,
                    ),
                  ),
                  
                  SizedBox(height: 48.h),
                  
                  // 마감일 안내 (빨간색)
                  Text(
                    '${userData.deletionExpiration} 오전 00:00이후에는 복구가 불가능합니다',
                    style: TextStyle(
                      fontSize: 42.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.3,
                    ),
                  ),
                  
                  SizedBox(height: 180.h),
                  
                  // 중앙 프로필 이미지 영역
                  Center(
                    child: Column(
                      children: [
                        // 프로필 이미지 (회색 원형)
                        Container(
                          width: 300.w,
                          height: 300.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[300],
                          ),
                          child: userData.imageUrl != null
                              ? ClipOval(
                                  child: Image.network(
                                    userData.imageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 150.sp,
                                  color: Colors.grey[600],
                                ),
                        ),
                        
                        SizedBox(height: 48.h),
                        
                        // 닉네임
                        Text(
                          '${nickname}님',
                          style: TextStyle(
                            fontSize: 72.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 450.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showRecoverySuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          '계정 복구 완료',
          style: TextStyle(fontSize: 54.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          '계정이 성공적으로 복구되었습니다.\n다시 로그인해주세요.',
          style: TextStyle(fontSize: 42.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login');
            },
            child: Text(
              '확인',
              style: TextStyle(
                fontSize: 42.sp,
                color: Color(0xff8287ff),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRecoveryFailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '계정 복구 실패',
          style: TextStyle(fontSize: 54.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          '계정 복구에 실패했습니다.\n잠시 후 다시 시도해주세요.',
          style: TextStyle(fontSize: 42.sp),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              '확인',
              style: TextStyle(
                fontSize: 42.sp,
                color: Color(0xff8287ff),
              ),
            ),
          ),
        ],
      ),
    );
  }
}