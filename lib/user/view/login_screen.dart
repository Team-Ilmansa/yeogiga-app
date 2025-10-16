import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:yeogiga/common/component/bottom_app_bar_layout.dart';
import 'package:yeogiga/common/component/custom_text_form_field.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static String get routeName => 'login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool loginFailed = false;
  String username = '';
  String password = '';
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userMeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // 키보드 뜰 때 영역 자동 조정
      // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
      // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

      // 로그인하기 버튼 섹션
      bottomNavigationBar: BottomAppBarLayout(
        child: Padding(
          padding: EdgeInsets.only(
            // 키보드 높이만큼 여백 추가
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),

          child: ElevatedButton(
            onPressed:
                state is UserModelLoading ||
                        username.isEmpty ||
                        password.isEmpty
                    ? null
                    : () async {
                      //TODO: await하는 동안 버튼 비활성화 안되나? (이미 함)
                      final user = await ref
                          .read(userMeProvider.notifier)
                          .login(username: username, password: password);

                      // if (user is UserDeleteModel) {
                      //   if (!mounted) return;
                      //   context.go('/userRecovery');
                      //   return;
                      // }

                      setState(() {
                        loginFailed = user is UserModelError;
                      });
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff8287ff),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11.r),
              ),
              elevation: 0,
            ),
            child: Text(
              '로그인하기',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),

      // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
      // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 71.h),
                  Logo(),
                  SizedBox(height: 36.h),

                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

                  // 아이디 입력 필드
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '아이디',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.1,
                        ),
                      ),
                      SizedBox(height: 7.h),
                      CustomTextFormField(
                        controller: _idController,
                        onChanged: (String value) {
                          setState(() {
                            username = value;
                            loginFailed = false;
                          });
                        },
                        hintText: '아이디를 입력해주세요',
                      ),
                    ],
                  ),
                  SizedBox(height: 22.h),

                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

                  // 비밀번호 입력 필드
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '비밀번호',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.1,
                        ),
                      ),
                      SizedBox(height: 7.h),
                      CustomTextFormField(
                        controller: _passwordController,
                        hintText: '비밀번호를 입력해주세요.',
                        onChanged: (String value) {
                          setState(() {
                            password = value;
                            loginFailed = false;
                          });
                        },
                        obscureText: true,
                      ),
                      // 에러 메시지 출력
                      Padding(
                        padding: EdgeInsets.only(top: 7.h, left: 4.w),
                        child: SizedBox(
                          width: double.infinity,
                          height: 18.h,
                          child:
                              loginFailed
                                  ? Text(
                                    '아이디와 비밀번호를 정확히 입력해 주세요.',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12.sp,
                                    ),
                                    textAlign: TextAlign.end,
                                  )
                                  : null,
                        ),
                      ),
                    ],
                  ),
                  // SizedBox(height: 18.h),

                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

                  // 아이디 찾기, 비밀번호 찾기, 회원가입하기 링크
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          '아이디 찾기',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 12.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          '비밀번호 찾기',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 12.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/register');
                        },
                        child: Text(
                          '회원가입',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 134.h),

                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

                  // SNS 로그인 섹션
                  Center(
                    child: Text(
                      'SNS계정으로 간편로그인하기',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.black54,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

                  // SNS 로그인 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 카카오톡 로그인 버튼
                      GestureDetector(
                        onTap: () async {
                          // TODO: 카카오 로그인 로직
                          try {
                            // 휴대폰에 카카오톡이 깔려있는지 bool 값으로 반환해주는 함수
                            bool installed = await isKakaoTalkInstalled();

                            // 깔려있다면 UserApi.instance.loginWithKakaoTalk() 으로 카카오톡 오픈 후 동의
                            // 깔려있지 않다면 UserApi.instance.loginWithKakaoAccount() 으로 웹을통한 인증
                            OAuthToken token =
                                installed
                                    ? await UserApi.instance
                                        .loginWithKakaoTalk()
                                    : await UserApi.instance
                                        .loginWithKakaoAccount();

                            final user = await ref
                                .read(userMeProvider.notifier)
                                .socialLogin(
                                  dio: ref.watch(dioProvider),
                                  token: token,
                                  platform: 'KAKAO',
                                );
                            setState(() {
                              loginFailed = user is UserModelError;
                            });
                          } on DioException catch (e) {
                            print('카카오톡 회원가입 실패: ${e.response}');
                            loginFailed = true;
                          } catch (i) {
                            print('카카오톡 회원가입 실패: ${i}');
                            loginFailed = true;
                          }
                        },
                        child: Center(
                          child: Image.asset(
                            'asset/img/oauth/kakao.png',
                            width: 46.sp,
                            height: 46.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 13.w),

                      // 네이버 로그인 버튼
                      GestureDetector(
                        onTap: () {
                          // TODO: 네이버 로그인 로직
                        },
                        child: Center(
                          child: Image.asset(
                            'asset/img/oauth/naver.png',
                            width: 46.sp,
                            height: 46.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 13.w),

                      // 애플 로그인 버튼
                      GestureDetector(
                        onTap: () {
                          // TODO: 애플 로그인 로직
                        },
                        child: Center(
                          child: Image.asset(
                            'asset/img/oauth/apple.png',
                            width: 46.sp,
                            height: 46.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // SizedBox(height: 30.h),
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
          width: 179.w,
          height: 89.h,
        ),
      ],
    );
  }
}
