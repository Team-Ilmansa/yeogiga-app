import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/common/component/custom_text_form_field.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';

class NicknameSetupScreen extends ConsumerStatefulWidget {
  static String get routeName => 'nickname';

  const NicknameSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NicknameSetupScreen> createState() => _NicknameSetupScreenState();
}

class _NicknameSetupScreenState extends ConsumerState<NicknameSetupScreen> {
  String? errorMessage;
  final TextEditingController _nicknameController = TextEditingController();

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userMeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // UserModelGuest 상태를 null로 변경해서 로그인 화면으로 이동
            ref.read(userMeProvider.notifier).logout();
          },
        ),
      ),
      
      // 닉네임 설정 버튼
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(72.r),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, -2),
              blurRadius: 1,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            36.w,
            36.h,
            36.w,
            MediaQuery.of(context).viewInsets.bottom + 75.h,
          ),
          child: ElevatedButton(
            onPressed: state is UserModelLoading || _nicknameController.text.isEmpty
                ? null
                : () async {
                    final result = await ref
                        .read(userMeProvider.notifier)
                        .setGuestNickname(
                          dio: ref.watch(dioProvider),
                          nickname: _nicknameController.text.trim(),
                        );
                    setState(() {
                      if (result is UserModelError) {
                        errorMessage = result.message;
                      } else {
                        errorMessage = null;
                      }
                    });
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff8287ff),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(36.r),
              ),
              elevation: 0,
            ),
            child: Text(
              '시작하기',
              style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w500),
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
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 240.h),
                  
                  // 로고
                  Logo(),
                  SizedBox(height: 120.h),

                  // 안내 텍스트
                  Text(
                    '여기가에서 사용할\n닉네임을 설정해주세요',
                    style: TextStyle(
                      fontSize: 60.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 96.h),

                  // 닉네임 입력 필드
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '닉네임',
                        style: TextStyle(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      CustomTextFormField(
                        controller: _nicknameController,
                        onChanged: (String value) {
                          setState(() {
                            errorMessage = null;
                          });
                        },
                        hintText: '닉네임을 입력해주세요',
                      ),
                      // 에러 메시지 출력
                      Padding(
                        padding: EdgeInsets.only(top: 24.h, left: 12.w),
                        child: SizedBox(
                          width: double.infinity,
                          height: 60.h,
                          child: errorMessage != null
                              ? Text(
                                  errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 39.sp,
                                  ),
                                  textAlign: TextAlign.end,
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 200.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'asset/img/logo/splash_logo.png',
          width: 600.w,
          height: 300.h,
        ),
      ],
    );
  }
}