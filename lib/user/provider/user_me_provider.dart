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
    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);
    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    //토큰이 없을 때는 state가 null
    if (refreshToken == null || accessToken == null) {
      state = null;
      return;
    }

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
  }) async {
    try {
      print('Social Login Start');

      state = UserModelLoading();

      final response = await dio.post(
        'https://$ip/api/v1/oauth/sign-in/KAKAO/mobile',
        data: {
          "accessToken": token.accessToken, // 카카오 로그인에서 받은 accessToken
        },
      );

      print('response: $response');

      if (response.data['code'] != 200 || response.data == null) {
        state = UserModelError(message: '카카오 인증에 실패했습니다.');
        return state!;
      }

      String accessToken = response.data['data']['token']['accessToken'];
      String refreshToken = response.data['data']['token']['refreshToken'];

      await storage.write(key: REFRESH_TOKEN_KEY, value: refreshToken);
      await storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

      final parts = accessToken.split('.');
      if (parts.length != 3) {
        state = UserModelError(message: '잘못된 토큰 형식입니다.');
        return state!;
      }

      // final payload = parts[1];
      // String normalized = base64.normalize(payload);
      // final decoded = utf8.decode(base64Url.decode(normalized));
      // final payloadMap = jsonDecode(decoded);
      // print('payloadMap: $payloadMap');
      // final role = payloadMap['role'] as String?;
      // print('role: $role');

      // TODO: 토큰 저장, get me 실행, userGuestModel 만들기, shouldSignUp 값 따라 userGuestModel해버리기, 리다이렉트 설정, fcm 토큰 등록, 닉네임 페이지 만들기
      return UserModelError(message: '테스트 끝');
    } on Exception catch (e) {
      // TODO:
      return UserModelError(message: '테스트 끝');
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
