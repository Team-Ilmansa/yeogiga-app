import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/component/custom_text_form_field.dart';
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

  bool? usernameAvailable;
  bool? nicknameAvailable;
  Timer? _nicknameDebounce;

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
            const SizedBox(height: 48),
            const Text(
              '로그인에 사용할\n이메일을 입력해주세요',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 12),
            const Text(
              '입력하신 이메일로 회원여부 확인 및 서비스 가입을 도와드릴게요',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 32),
          ],
        ),
        //이메일 입력칸
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '이메일',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              controller: _emailController,
              hintText: '이메일을 입력해주세요',
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
          ],
        ),
        //이메일 확인 입력칸
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '이메일 확인',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: CustomTextFormField(
                    controller: _emailVerifyController,
                    hintText: '인증번호 6자리를 입력해주세요',
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed:
                      _emailVerifyController.text.length == 6 ? () {} : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _emailVerifyController.text.length == 6
                            ? const Color(0xff8287ff)
                            : Colors.grey[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('재전송', style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
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
          children: [
            const SizedBox(height: 48),
            const Text(
              '아이디와 비밀번호를\n설정해주세요',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '영문, 숫자, 특수기호 포함 8~20자이내로 설정할 수 있어요',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 32),
          ],
        ),
        // 아이디 입력 및 버튼
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '아이디',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF6F6F6),
                      borderRadius: BorderRadius.circular(12),
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
                const SizedBox(width: 8),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('중복확인', style: TextStyle(fontSize: 15)),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4.0),
              child: SizedBox(
                width: double.infinity,
                height: 20,
                child:
                    usernameAvailable != null
                        ? usernameAvailable == true
                            ? Text(
                              '사용 가능한 아이디에요',
                              style: TextStyle(
                                color: Color(0xff8287ff),
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.end,
                            )
                            : Text(
                              '이미 사용중인 아이디에요',
                              style: TextStyle(color: Colors.red, fontSize: 13),
                              textAlign: TextAlign.end,
                            )
                        : null,
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),

        // 비밀번호
        const Text(
          '비밀번호',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(12),
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
        const SizedBox(height: 24),
        // 비밀번호 확인
        const Text(
          '비밀번호 확인',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(12),
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
          const Padding(
            padding: EdgeInsets.only(top: 8.0, left: 4.0),
            child: Text(
              '비밀번호가 일치하지 않아요',
              style: TextStyle(color: Colors.red, fontSize: 13),
            ),
          ),
        const SizedBox(height: 24),
      ],
    ),

    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // 3. 약관 동의
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 48),
        const Text(
          '서비스 이용약관에\n동의해주세요',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          '정확한 데이터 조회와 더 원활한 서비스 이용을 위해 꼭 필요해요',
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
      ],
    ),

    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
    // 4. 닉네임 입력
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 48),
        const Text(
          '서비스에서 사용할\n닉네임을 입력해주세요',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          '가입 후 언제든지 수정이 가능해요',
          style: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        const SizedBox(height: 32),
        const Text(
          '닉네임',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
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
          padding: const EdgeInsets.only(top: 8.0, left: 4.0),
          child: SizedBox(
            width: double.infinity,
            height: 20,
            child:
                nicknameAvailable != null
                    ? nicknameAvailable == true
                        ? Text(
                          '사용 가능한 닉네임이에요',
                          style: TextStyle(
                            color: Color(0xff8287ff),
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.end,
                        )
                        : Text(
                          '이미 사용중인 닉네임이에요',
                          style: TextStyle(color: Colors.red, fontSize: 13),
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
              const SizedBox(height: 48),
              Text(
                '${_usernameController.text}님\n여기가 가입을 축하드려요!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '여기가와 함께 더 체계적인 단체여행을 즐겨봐요',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
            ],
          );
        } else if (_registerResult != null) {
          // 실패
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const Text(
                '회원가입을 다시 진행해주세요 ㅠㅠ',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (_registerResult!.message != null)
                Text(
                  _registerResult!.message!,
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
              if (_registerResult!.errors != null)
                ..._registerResult!.errors!.entries.map(
                  (e) => Text(
                    '${e.key}: ${e.value}',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ),
            ],
          );
        } else {
          // 기본 성공 화면 (혹시나)
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              const Text(
                '구이님\n여기가 가입을 축하드려요!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                '여기가와 함께 더 체계적인 단체여행을 즐겨봐요',
                style: TextStyle(color: Colors.black54, fontSize: 14),
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
          _emailVerifyController.text.length == 6;
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
                ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      currentStep--;
                    });
                  },
                )
                : null,
      ),
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 12),
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        kToolbarHeight -
                        150, // 버튼/인디케이터 높이만큼 여유
                    child: steps[currentStep],
                  ),
                  const SizedBox(height: 20),
                  // 페이지 인디케이터 (동그라미)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      stepCount - 1,
                      (idx) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),

      // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
      // ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          MediaQuery.of(context).viewInsets.bottom + 20,
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
                              final repo = ref.read(registerRepositoryProvider);
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child:
                      _isRegistering
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                          : Text(
                            currentStep == 3 ? '가입 완료' : '다음 단계로',
                            style: const TextStyle(
                              fontSize: 16,
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
      ),
    );
  }
}
