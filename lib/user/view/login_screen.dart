import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
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
            // 키보드 높이만큼 여백 추가
            MediaQuery.of(context).viewInsets.bottom + 75.h,
          ),

          child: ElevatedButton(
            onPressed:
                state is UserModelLoading
                    ? null
                    : () async {
                      //TODO: await하는 동안 버튼 비활성화 안되나?
                      final user = await ref
                          .read(userMeProvider.notifier)
                          .login(username: username, password: password);
                      setState(() {
                        loginFailed = user is UserModelError;
                      });
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  (username.isNotEmpty && password.isNotEmpty)
                      ? const Color(0xff8287ff)
                      : Colors.grey[400],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(36.r),
              ),
              elevation: 0,
            ),
            child: Text(
              '로그인하기',
              style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w500),
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
              padding: EdgeInsets.symmetric(horizontal: 48.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 240.h),
                  Logo(),
                  SizedBox(height: 120.h),

                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

                  // 아이디 입력 필드
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '아이디',
                        style: TextStyle(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 24.h),
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
                  SizedBox(height: 75.h),

                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

                  // 비밀번호 입력 필드
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '비밀번호',
                        style: TextStyle(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 24.h),
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
                        padding: EdgeInsets.only(top: 24.h, left: 12.w),
                        child: SizedBox(
                          width: double.infinity,
                          height: 60.h,
                          child:
                              loginFailed
                                  ? Text(
                                    '아이디와 비밀번호를 정확히 입력해 주세요.',
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
                  // SizedBox(height: 60.h),

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
                            fontSize: 42.sp,
                          ),
                        ),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 42.sp,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          '비밀번호 찾기',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 42.sp,
                          ),
                        ),
                      ),
                      Text(
                        '|',
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 42.sp,
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
                            fontSize: 42.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 450.h),

                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

                  // SNS 로그인 섹션
                  Center(
                    child: Text(
                      'SNS계정으로 간편로그인하기',
                      style: TextStyle(
                        fontSize: 36.sp,
                        color: Colors.black54,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  SizedBox(height: 48.h),

                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
                  // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

                  // SNS 로그인 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 카카오톡 로그인 버튼
                      GestureDetector(
                        onTap: () async {
                          final dio = ref.watch(dioProvider);
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

                            // final response = await dio.post(
                            //   //TODO: 변경 필요.
                            //   'https://$ip/api/v1/oauth/sign-in/kakao',
                            //   data: {
                            //     "code":
                            //         token
                            //             .accessToken, // 카카오 로그인에서 받은 accessToken
                            //   },
                            //   options: Options(headers: {"device": "MOBILE"}),
                            // );

                            // if (response != null) {
                            //   // 저장 후 페이지 이동
                            //   Navigator.pushNamedAndRemoveUntil(
                            //     context,
                            //     '/',
                            //     (route) => false,
                            //   );
                            // }
                          } on DioException catch (e) {
                            print('카카오톡 회원가입 실패: ${e.response}');
                          } catch (i) {
                            print('카카오톡 회원가입 실패: ${i}');
                          }
                        },
                        child: Center(
                          child: Image.asset('asset/img/oauth/kakao.png'),
                        ),
                      ),
                      SizedBox(width: 45.w),

                      // 네이버 로그인 버튼
                      GestureDetector(
                        onTap: () {
                          // TODO: 네이버 로그인 로직
                        },
                        child: Center(
                          child: Image.asset('asset/img/oauth/naver.png'),
                        ),
                      ),
                      SizedBox(width: 45.w),

                      // 애플 로그인 버튼
                      GestureDetector(
                        onTap: () {
                          // TODO: 애플 로그인 로직
                        },
                        child: Center(
                          child: Image.asset('asset/img/oauth/apple.png'),
                        ),
                      ),
                    ],
                  ),

                  // SizedBox(height: 100.h),
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
