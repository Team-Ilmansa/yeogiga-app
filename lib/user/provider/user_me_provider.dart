import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/secure_storage/secure_storage.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/repository/auth_repository.dart';
import 'package:yeogiga/user/repository/user_me_repository.dart';
import 'package:yeogiga/user/repository/fcm_token_repository.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:yeogiga/common/service/fcm_token_manager.dart';

final userMeProvider =
    StateNotifierProvider<UserMeStateNotifier, UserModelBase?>((ref) {
      final authRepository = ref.watch(authRepositoryProvider);
      final userMeRepository = ref.watch(userMeRepositoryProvider);
      final storage = ref.watch(secureStorageProvider);

      return UserMeStateNotifier(
        authRepository: authRepository,
        repository: userMeRepository,
        storage: storage,
        ref: ref,
      );
    });

class UserMeStateNotifier extends StateNotifier<UserModelBase?> {
  final AuthRepository authRepository;
  final UserMeRepository repository;
  final FlutterSecureStorage storage;
  final Ref ref;

  UserMeStateNotifier({
    required this.authRepository,
    required this.repository,
    required this.storage,
    required this.ref,
  }) : super(UserModelLoading()) {
    // 내 정보 가져오기
    getMe();
  }

  //일단 내 정보 가져오기
  Future<void> getMe() async {
    ////
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    //토큰이 없을 때는 state가 null
    if (refreshToken == null || accessToken == null) {
      state = null;
      return;
    }
    ////

    try {
      final resp = await repository.getMe();
      state = resp;
    } on DioException catch (e) {
      state = UserModelError(message: '유저 정보 불러오기 실패');
    }
  }

  //로그인하기
  Future<UserModelBase> login({
    required String username,
    required String password,
  }) async {
    try {
      print('login start');
      state = UserModelLoading();

      final resp = await authRepository.login(
        username: username,
        password: password,
      );

      // code와 data로 성공/실패 판단
      if (resp.code != 200 || resp.data == null) {
        state = UserModelError(message: resp.message);
        return state!;
      }

      await storage.write(
        key: REFRESH_TOKEN_KEY,
        value: resp.data!.refreshToken,
      );
      await storage.write(key: ACCESS_TOKEN_KEY, value: resp.data!.accessToken);

      // 로그인 성공 시 FCM 토큰 등록
      await registerFcmToken(ref);

      print('start get me');
      final userResp = await repository.getMe();
      state = userResp;
      print('login end');
      return userResp;
    } catch (e) {
      state = UserModelError(message: '로그인에 실패했습니다.');
      return state!;
    }
  }

  //소셜 로그인하기
  Future<UserModelBase> socialLogin({
    required Dio dio,
    required OAuthToken token,
    required String platform,
  }) async {
    try {
      print('Social Login Start');

      state = UserModelLoading();

      final response = await dio.post(
        'https://$ip/api/v1/oauth/sign-in/$platform/mobile',
        data: {
          "accessToken": token.accessToken, // 카카오 로그인에서 받은 accessToken
        },
      );

      print('response: $response');

      if (response.data['code'] != 200 || response.data == null) {
        state = UserModelError(message: '$platform 인증에 실패했습니다.');
        return state!;
      }

      //shouldSignUp이 true이면 guest
      if (response.data['data']['shouldSignup'] == true) {
        final tempToken = response.data['data']['token']['accessToken'] as String?;
        if (tempToken != null) {
          await storage.write(key: SOCIAL_TEMP_TOKEN, value: tempToken);
        }
        state = UserModelGuest();
        return state!;
      }

      // shouldSignup이 false일 때만 토큰 추출
      final accessToken = response.data['data']['token']['accessToken'] as String?;
      final refreshToken = response.data['data']['token']['refreshToken'] as String?;
      
      if (accessToken == null || refreshToken == null) {
        state = UserModelError(message: '토큰 정보가 올바르지 않습니다.');
        return state!;
      }

      //shouldSignup이 false이면 그대로 로그인로직 실행.
      await storage.write(key: REFRESH_TOKEN_KEY, value: refreshToken);
      await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

      await registerFcmToken(ref);

      final userResp = await repository.getMe();
      state = userResp;
      return state!;
      // TODO: 토큰 저장, get me 실행, userGuestModel 만들기, shouldSignUp 값 따라 userGuestModel해버리기, 리다이렉트 설정, fcm 토큰 등록, 닉네임 페이지 만들기
    } on Exception catch (e) {
      // TODO:
      state = UserModelError(message: '로그인에 실패했습니다.');
      return state!;
    }
  }

  //소셜 로그인 닉네임 설정 및 로그인하기
  Future<UserModelBase> setGuestNickname({
    required Dio dio,
    required String nickname,
  }) async {
    //TODO: 닉네임 설정, 임시 토큰 이용, 토큰 새로 저장, getme 실행, 상태 변경

    try {
      final response = await dio.put(
        'https://$ip/api/v1/oauth/register',
        options: Options(headers: {'accessToken': 'temp', 'device': 'MOBILE'}),
        data: {'nickname': nickname},
      );

      if (response.data['code'] != 200 && response.data['data'] == null) {
        throw Exception();
      }

      final accessToken = response.data['data']['accessToken'];
      final refreshToken = response.data['data']['refreshToken'];

      storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);
      storage.write(key: REFRESH_TOKEN_KEY, value: refreshToken);

      // 성공 시 FCM 토큰 등록 및 getMe()
      await registerFcmToken(ref);

      final userResponse = await repository.getMe();
      state = userResponse;
      return userResponse;
    } on DioException catch (e) {
      String errorMessage = '로그인 정보에 문제가 생겼습니다.';

      if (e.response?.data != null) {
        final responseData = e.response!.data;
        final code = responseData['code'];

        // 서버에서 온 에러 메시지 처리
        if (code == 'G002' && responseData['errors']?['nickname'] != null) {
          errorMessage = responseData['errors']['nickname'];
        } else if (code == 'A000' && responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else if (code == 'A012' && responseData['message'] != null) {
          errorMessage = responseData['message'];
        } else if (responseData['message'] != null) {
          errorMessage = responseData['message'];
        }
      }
      return UserModelError(message: errorMessage);
    } catch (e) {
      return UserModelError(message: '네트워크 오류가 발생했습니다.');
    }
  }

  //로그아웃 하기
  Future<void> logout() async {
    state = null;

    // FCM 토큰 삭제 (서버/기기 모두)
    try {
      final fcmRepo = ref.read(fcmTokenRepositoryProvider);
      await fcmRepo.deleteFcmToken(); // 서버에서 삭제
      await FirebaseMessaging.instance.deleteToken(); // 기기에서 삭제
    } catch (e) {
      // 에러 로깅
    }

    await Future.wait([
      storage.delete(key: REFRESH_TOKEN_KEY),
      storage.delete(key: ACCESS_TOKEN_KEY),
    ]);
  }
}
