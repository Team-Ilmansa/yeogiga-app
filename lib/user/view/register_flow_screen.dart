import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:yeogiga/common/component/bottom_app_bar_layout.dart';
import 'package:yeogiga/common/component/custom_text_form_field.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/user/repository/register_repository.dart';
import 'package:yeogiga/user/model/register_response.dart';

class RegisterFlowScreen extends ConsumerStatefulWidget {
  static String get routeName => 'register';
  const RegisterFlowScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterFlowScreen> createState() => _RegisterFlowScreenState();
}

class _RegisterFlowScreenState extends ConsumerState<RegisterFlowScreen> {
  int currentStep = 0;

  bool emailSent = false;
  String? emailErrorText;
  String? emailVerifyInfoText;
  String? emailVerifyErrorText;

  bool? usernameAvailable;
  bool? nicknameAvailable;
  Timer? _nicknameDebounce;
  bool isEmailVerified = false;

  final _emailController = TextEditingController();
  final _emailVerifyController = TextEditingController();
  final _usernameController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwCheckController = TextEditingController();
  final _nicknameController = TextEditingController();

  // 회원가입 결과 및 로딩 상태
  RegisterResponse? _registerResult;
  bool _isRegistering = false;

  @override
  void dispose() {
    _nicknameDebounce?.cancel();
    _nicknameController.dispose();
    super.dispose();
  }

  List<Widget> get steps => [
    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // 1. 이메일 입력
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //이메일 알림말
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 43.h),
            Text(
              '로그인에 사용할\n이메일을 입력해주세요',
              style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 11.h),
            Text(
              '입력하신 이메일로 회원여부 확인 및 서비스 가입을 도와드릴게요',
              style: TextStyle(color: Colors.black54, fontSize: 12.sp),
            ),
            SizedBox(height: 29.h),
          ],
        ),
        //이메일 입력칸
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '이메일',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 7.h),
            CustomTextFormField(
              controller: _emailController,
              enabled: !emailSent && _emailVerifyController.text.isEmpty,
              hintText: '이메일을 입력해주세요',
              onChanged: (_) => setState(() {}),
            ),
            if (emailErrorText != null)
              SizedBox(
                height: 16.h,
                child: Padding(
                  padding: EdgeInsets.only(top: 4.h, right: 4.w),
                  child: Text(
                    emailErrorText!,
                    style: TextStyle(color: Colors.red, fontSize: 9.sp),
                    textAlign: TextAlign.right, // 오른쪽 정렬
                  ),
                ),
              )
            else
              SizedBox(height: 16.h),

            SizedBox(height: 12.h),
          ],
        ),
        //이메일 확인 입력칸
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '이메일 확인',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 7.h),
            CustomSettlementTextFormField(
              controller: _emailVerifyController,
              enabled: _emailController.text.isNotEmpty && !isEmailVerified,
              hintText: '인증번호 6자리를 입력해주세요',
              onChanged: (value) => setState(() {}),
              suffix: Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                child: ElevatedButton(
                  onPressed: () async {
                    final dio = ref.watch(dioProvider);

                    if (_emailVerifyController.text.length == 6) {
                      // 이메일 코드 검증
                      try {
                        final response = await dio.post(
                          '$baseUrl/auth/email-verification/verify',
                          data: {
                            "email": _emailController.text,
                            "code": _emailVerifyController.text,
                          },
                        );
                        if (response.data['code'] == 200) {
                          isEmailVerified = true;
                          emailVerifyInfoText = '인증에 성공하였습니다.';
                          emailVerifyErrorText = null;
                          emailErrorText = null;
                        }
                      } on DioException catch (e) {
                        // TODO: 이메일 인증 실패!
                        if (e.response != null && e.response?.data != null) {
                          final data = e.response!.data;
                          // message 또는 errors 파싱
                          if (data['message'] != null) {
                            emailVerifyErrorText = data['message'];
                          } else if (data['errors'] != null) {
                            final errors = data['errors'];
                            if (errors['code'] != null) {
                              emailVerifyErrorText = errors['code'];
                            } else if (errors['email'] != null) {
                              emailVerifyErrorText = errors['email'];
                            }
                          } else {
                            emailVerifyErrorText = "알 수 없는 오류가 발생했습니다.";
                          }
                        } else {
                          // 서버 응답 자체가 없을 때(네트워크 등)
                          emailVerifyErrorText = "네트워크 오류가 발생했습니다.";
                        }
                        emailVerifyInfoText = null;
                      }
                    } else {
                      // 이메일 코드 보내깅
                      try {
                        final response = await dio.post(
                          '$baseUrl/auth/email-verification/request',
                          data: {"email": _emailController.text},
                        );
                        if (response.data['code'] == 200) {
                          emailSent = true;
                          emailVerifyInfoText = '인증코드를 전송했습니다.';
                          emailVerifyErrorText = null;
                          emailErrorText = null;
                        }
                      } on DioException catch (e) {
                        // TODO: 이메일 코드 보내기 실패!
                        if (e.response != null && e.response?.data != null) {
                          final data = e.response!.data;
                          if (data['code'] == 'A016') {
                            emailVerifyErrorText = data['message'];
                          } else if (data['message'] != null) {
                            emailErrorText = data['message'];
                          } else if (data['errors'] != null) {
                            final errors = data['errors'];
                            if (errors['code'] != null) {
                              emailErrorText = errors['code'];
                            } else if (errors['email'] != null) {
                              emailErrorText = errors['email'];
                            }
                          } else {
                            emailVerifyErrorText = "알 수 없는 오류가 발생했습니다.";
                          }
                        } else {
                          emailVerifyErrorText = "네트워크 오류가 발생했습니다.";
                        }
                        emailVerifyInfoText = null;
                      }
                    }

                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8287ff),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                    minimumSize: Size.zero,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    _emailVerifyController.text.length == 6
                        ? '확인'
                        : emailSent
                        ? '재전송'
                        : '전송',
                    style: TextStyle(fontSize: 11.sp),
                  ),
                ),
              ),
            ),
            if (emailVerifyErrorText != null)
              Padding(
                padding: EdgeInsets.only(top: 4.h, right: 4.w),
                child: Text(
                  emailVerifyErrorText!,
                  style: TextStyle(color: Colors.red, fontSize: 9.sp),
                  textAlign: TextAlign.right, // 오른쪽 정렬
                ),
              )
            else if (emailVerifyInfoText != null)
              Padding(
                padding: EdgeInsets.only(top: 4.h, right: 4.w),
                child: Text(
                  emailVerifyInfoText!,
                  style: TextStyle(color: Colors.blue, fontSize: 9.sp),
                  textAlign: TextAlign.right, // 오른쪽 정렬
                ),
              )
            else
              SizedBox(height: 7.h),
          ],
        ),
      ],
    ),

    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // 2. 아이디, 비밀번호 입력
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 머릿말
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 43.h),
            Text(
              '아이디와 비밀번호를\n설정해주세요',
              style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 7.h),
            Text(
              '영문, 숫자, 특수기호 포함 8~20자이내로 설정할 수 있어요',
              style: TextStyle(color: Colors.black54, fontSize: 12.sp),
            ),
            SizedBox(height: 29.h),
          ],
        ),
        // 아이디 입력 및 버튼
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '아이디',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 7.h),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    child: CustomTextFormField(
                      controller: _usernameController,
                      hintText: '아이디를 입력해주세요',
                      onChanged: (_) {
                        setState(() {
                          usernameAvailable = null;
                        });
                      },
                      autofocus: false,
                      obscureText: false,
                      errorText: null,
                    ),
                  ),
                ),
                SizedBox(width: 7.w),
                ElevatedButton(
                  onPressed:
                      _usernameController.text.isNotEmpty
                          ? () async {
                            usernameAvailable = await ref
                                .read(registerRepositoryProvider)
                                .checkUsernameAvailable(
                                  _usernameController.text,
                                );
                            setState(() {});
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _usernameController.text.isNotEmpty
                            ? const Color(0xff8287ff)
                            : Colors.grey[400],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text('중복확인', style: TextStyle(fontSize: 13.sp)),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 7.h, left: 4.w),
              child: SizedBox(
                width: double.infinity,
                height: 18.h,
                child:
                    usernameAvailable != null
                        ? usernameAvailable == true
                            ? Text(
                              '사용 가능한 아이디에요',
                              style: TextStyle(
                                color: Color(0xff8287ff),
                                fontSize: 12.sp,
                              ),
                              textAlign: TextAlign.end,
                            )
                            : Text(
                              '이미 사용중인 아이디에요',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.sp,
                              ),
                              textAlign: TextAlign.end,
                            )
                        : null,
              ),
            ),
            SizedBox(height: 25.h),
          ],
        ),

        // 비밀번호
        Text(
          '비밀번호',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 7.h),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              CustomTextFormField(
                controller: _pwController,
                hintText: '비밀번호를 입력해주세요',
                obscureText: true,
                onChanged: (_) => setState(() {}),
                autofocus: false,
                errorText: null,
              ),
            ],
          ),
        ),
        SizedBox(height: 21.h),
        // 비밀번호 확인
        Text(
          '비밀번호 확인',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 7.h),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: CustomTextFormField(
            controller: _pwCheckController,
            hintText: '비밀번호를 입력해주세요',
            obscureText: true,
            onChanged: (_) => setState(() {}),
            autofocus: false,
            errorText: null,
          ),
        ),
        if (_pwCheckController.text.isNotEmpty &&
            _pwController.text != _pwCheckController.text)
          Padding(
            padding: EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              '비밀번호가 일치하지 않아요',
              style: TextStyle(color: Colors.red, fontSize: 12.sp),
            ),
          ),
        SizedBox(height: 21.h),
      ],
    ),

    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // 3. 약관 동의
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 43.h),
        Text(
          '서비스 이용약관에\n동의해주세요',
          style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 11.h),
        Text(
          '정확한 데이터 조회와 더 원활한 서비스 이용을 위해 꼭 필요해요',
          style: TextStyle(color: Colors.black54, fontSize: 12.sp),
        ),
      ],
    ),

    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // 4. 닉네임 입력
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 43.h),
        Text(
          '서비스에서 사용할\n닉네임을 입력해주세요',
          style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 11.h),
        Text(
          '가입 후 언제든지 수정이 가능해요',
          style: TextStyle(color: Colors.black54, fontSize: 12.sp),
        ),
        SizedBox(height: 29.h),
        Text(
          '닉네임',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        SizedBox(height: 7.h),
        CustomTextFormField(
          controller: _nicknameController,
          hintText: '닉네임을 입력해주세요',
          onChanged: (value) {
            setState(() {
              nicknameAvailable = null;
            });
            if (_nicknameDebounce?.isActive ?? false)
              _nicknameDebounce!.cancel();
            _nicknameDebounce = Timer(
              const Duration(milliseconds: 500),
              () async {
                final isAvailable = await ref
                    .read(registerRepositoryProvider)
                    .checkNicknameAvailable(value);
                setState(() {
                  nicknameAvailable = isAvailable;
                });
              },
            );
          },
        ),
        Padding(
          padding: EdgeInsets.only(top: 7.h, left: 4.w),
          child: SizedBox(
            width: double.infinity,
            height: 18.h,
            child:
                nicknameAvailable != null
                    ? nicknameAvailable == true
                        ? Text(
                          '사용 가능한 닉네임이에요',
                          style: TextStyle(
                            color: Color(0xff8287ff),
                            fontSize: 12.sp,
                          ),
                          textAlign: TextAlign.end,
                        )
                        : Text(
                          '이미 사용중인 닉네임이에요',
                          style: TextStyle(color: Colors.red, fontSize: 12.sp),
                          textAlign: TextAlign.end,
                        )
                    : null,
          ),
        ),
      ],
    ),

    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // 5. 가입 완료 (동적 렌더링)
    Builder(
      builder: (context) {
        if (_registerResult != null && _registerResult!.code == 201) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 43.h),
              Text(
                '${_usernameController.text}님\n여기가 가입을 축하드려요!',
                style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 11.h),
              Text(
                '여기가와 함께 더 체계적인 단체여행을 즐겨봐요',
                style: TextStyle(color: Colors.black54, fontSize: 12.sp),
              ),
            ],
          );
        } else if (_registerResult != null) {
          // 실패
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 43.h),
              Text(
                '회원가입을 다시 진행해주세요 ㅠㅠ',
                style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 11.h),
              if (_registerResult!.message != null)
                Text(
                  _registerResult!.message!,
                  style: TextStyle(color: Colors.black54, fontSize: 12.sp),
                ),
              if (_registerResult!.errors != null)
                ..._registerResult!.errors!.entries.map(
                  (e) => Text(
                    '${e.key}: ${e.value}',
                    style: TextStyle(color: Colors.black54, fontSize: 12.sp),
                  ),
                ),
            ],
          );
        } else {
          // 기본 성공 화면 (혹시나)
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 43.h),
              Text(
                '구이님\n여기가 가입을 축하드려요!',
                style: TextStyle(fontSize: 23.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 11.h),
              Text(
                '여기가와 함께 더 체계적인 단체여행을 즐겨봐요',
                style: TextStyle(color: Colors.black54, fontSize: 12.sp),
              ),
            ],
          );
        }
      },
    ),
  ];

  int get stepCount => steps.length;

  void nextStep() {
    if (currentStep < stepCount - 1) {
      setState(() {
        currentStep++;
        // 비밀번호 스텝 진입 시 값 초기화
        if (currentStep == 1) {
          _pwController.clear();
          _pwCheckController.clear();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(registerRepositoryProvider);
    bool canProceed = false;

    if (currentStep == 0) {
      canProceed =
          _emailController.text.isNotEmpty &&
          _emailVerifyController.text.isNotEmpty &&
          _emailVerifyController.text.length == 6 &&
          isEmailVerified;
    } else if (currentStep == 1) {
      canProceed =
          _usernameController.text.isNotEmpty &&
          _pwController.text.isNotEmpty &&
          _pwCheckController.text.isNotEmpty &&
          _pwController.text == _pwCheckController.text &&
          usernameAvailable == true;
    } else if (currentStep == 2) {
      canProceed = true;
    } else if (currentStep == 3) {
      canProceed =
          _nicknameController.text.isNotEmpty && nicknameAvailable == true;
    } else if (currentStep == 4) {
      canProceed = true;
    } else {
      canProceed = true;
    }

    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading:
            currentStep > 0
                ? Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        currentStep--;
                      });
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16.sp,
                      color: Colors.black,
                    ),
                  ),
                )
                : null,
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 4),
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        kToolbarHeight -
                        134.h, // 버튼/인디케이터 높이만큼 여유
                    child: steps[currentStep],
                  ),
                  SizedBox(height: 18.h),
                  // 페이지 인디케이터 (동그라미)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      stepCount - 1,
                      (idx) => Container(
                        width: 7.w,
                        height: 7.h,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              idx <= currentStep
                                  ? const Color(0xff8287ff)
                                  : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 18.h),
                ],
              ),
            ),
          ),
        ),
      ),

      // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
      // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
      bottomNavigationBar: BottomAppBarLayout(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child:
              currentStep < stepCount - 1
                  ? ElevatedButton(
                    onPressed:
                        canProceed && !_isRegistering
                            ? () async {
                              FocusScope.of(context).unfocus();
                              if (currentStep == 3) {
                                setState(() {
                                  _isRegistering = true;
                                });
                                final repo = ref.read(
                                  registerRepositoryProvider,
                                );
                                final result = await repo.register(
                                  username: _usernameController.text,
                                  password: _pwController.text,
                                  email: _emailController.text,
                                  nickname: _nicknameController.text,
                                );
                                setState(() {
                                  _registerResult = result;
                                  _isRegistering = false;
                                  currentStep = 4;
                                });
                              } else {
                                nextStep();
                              }
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          canProceed && !_isRegistering
                              ? const Color(0xff8287ff)
                              : Colors.grey[400],
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isRegistering
                            ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.w,
                              ),
                            )
                            : Text(
                              currentStep == 3 ? '가입 완료' : '다음 단계로',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                  )
                  : ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).pop();
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
                      '확인',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
