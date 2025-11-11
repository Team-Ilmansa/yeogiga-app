import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/secure_storage/secure_storage.dart';
import 'package:yeogiga/user/model/user_model.dart';
import 'package:yeogiga/user/repository/auth_repository.dart';
import 'package:yeogiga/user/repository/user_me_repository.dart';
import 'package:yeogiga/user/repository/fcm_token_repository.dart';
import 'package:yeogiga/common/model/login_response.dart';

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
      if (resp is UserResponseModel && resp.data != null) {
        await registerFcmToken(ref);
      }
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

      // 디버깅용 로그 추가
      print('로그인 응답: ${resp.code} / ${resp.message} / ${resp.data}');
      print('코드 타입: ${resp.code.runtimeType}');

      // U003: 탈퇴한 사용자 - 복구 페이지로 리다이렉트  
      if (resp.code.toString() == "U003") {
        final deletedData = UserDeletedData.fromJson(resp.data as Map<String, dynamic>);
        state = UserDeleteModel(
          code: resp.code.toString(),
          message: resp.message,
          data: deletedData,
        );
        return state!;
      }

      // code와 data로 성공/실패 판단
      if (resp.code != 200 || resp.data == null) {
        state = UserModelError(message: resp.message);
        return state!;
      }

      final loginData = LoginResponse.fromJson(resp.data as Map<String, dynamic>);
      await storage.write(
        key: REFRESH_TOKEN_KEY,
        value: loginData.refreshToken,
      );
      await storage.write(key: ACCESS_TOKEN_KEY, value: loginData.accessToken);

      print('start get me');
      final userResp = await repository.getMe();
      state = userResp;
      print('login end');
      return userResp;
    } on DioException catch (e) {
      // 서버 에러 응답에서 U003 코드 확인
      if (e.response?.data != null) {
        final responseData = e.response!.data;
        print('DioException 응답: $responseData');
        
        if (responseData is Map<String, dynamic> && responseData['code'] == 'U003') {
          final deletedData = UserDeletedData.fromJson(responseData['data'] as Map<String, dynamic>);
          state = UserDeleteModel(
            code: responseData['code'].toString(),
            message: responseData['message'] ?? '이미 회원탈퇴한 사용자입니다.',
            data: deletedData,
          );
          return state!;
        }
      }
      
      state = UserModelError(message: '로그인에 실패했습니다.');
      return state!;
    } catch (e) {
      state = UserModelError(message: '로그인에 실패했습니다.');
      return state!;
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
        '$baseUrl/oauth/sign-in/$platform/mobile',
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

      final userResp = await repository.getMe();
      state = userResp;
      return state!;
    } on Exception catch (e) {
      state = UserModelError(message: '로그인에 실패했습니다.');
      return state!;
    }
  }

  //소셜 로그인 닉네임 설정 및 로그인하기
  Future<UserModelBase> setGuestNickname({
    required Dio dio,
    required String nickname,
  }) async {
    try {
      final response = await dio.put(
        '$baseUrl/oauth/register',
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

  // 계정 복구하기
  Future<bool> restoreAccount() async {
    final currentState = state;
    if (currentState is! UserDeleteModel) {
      return false;
    }

    try {
      final response = await authRepository.restore(
        userId: currentState.data.userId,
      );

      if (response['code'] == 200) {
        // 복구 성공 시 state는 그대로 두고 성공만 반환
        // 다이얼로그에서 확인 버튼을 누를 때 state를 변경
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // 프로필 이미지 수정 (optimistic UI)
  Future<String?> updateProfileImage(File image) async {
    try {
      final previousUrl = _currentImageUrl;
      final response = await repository.updateProfileImage(image: image);
      if (_isSuccessCode(response.code)) {
        _evictImageCache(previousUrl);
        await _waitAndRefreshUser();
        return null;
      }
      return response.message;
    } on DioException catch (e) {
      return _extractErrorMessage(
        e,
        fallback: '프로필 사진을 수정할 수 없습니다.',
      );
    } catch (_) {
      return '프로필 사진을 수정할 수 없습니다.';
    }
  }

  // 닉네임 수정 (optimistic UI)
  Future<String?> updateNickname(String nickname) async {
    try {
      final trimmed = nickname.trim();
      final response = await repository.updateNickname(
        body: {'nickname': trimmed},
      );

      if (_isSuccessCode(response.code)) {
        await _refreshUser();
        return null;
      }
      return response.message;
    } on DioException catch (e) {
      return _extractErrorMessage(
        e,
        fallback: '닉네임을 수정할 수 없습니다.',
      );
    } catch (_) {
      return '닉네임을 수정할 수 없습니다.';
    }
  }

  bool _isSuccessCode(dynamic code) => code.toString() == '200';

  String? get _currentImageUrl {
    final currentState = state;
    if (currentState is UserResponseModel) {
      return currentState.data?.imageUrl;
    } else if (currentState is UserModel) {
      return currentState.imageUrl;
    }
    return null;
  }

  void _evictImageCache(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;
    PaintingBinding.instance.imageCache
        .evict(NetworkImage(imageUrl));
  }

  Future<void> _waitAndRefreshUser() async {
    await _refreshUser(attempts: 3);
  }

  Future<void> _refreshUser({int attempts = 1}) async {
    try {
      final refreshed = await repository.getMe();
      final imageUrl = refreshed.data?.imageUrl;
      final isReady = await _waitForImageAvailability(imageUrl);
      if (!isReady && attempts > 1) {
        await Future.delayed(const Duration(milliseconds: 500));
        return _refreshUser(attempts: attempts - 1);
      }
      if (isReady) {
        _evictImageCache(imageUrl);
      }
      state = refreshed;
    } catch (_) {
      // ignore - keep previous state on failure
    }
  }

  Future<bool> _waitForImageAvailability(String? url) async {
    if (url == null || url.isEmpty) {
      return true;
    }

    const maxAttempts = 5;
    const delay = Duration(milliseconds: 400);
    final client = HttpClient();

    try {
      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        try {
          final request = await client.headUrl(Uri.parse(url));
          final response = await request.close();
          await response.drain();
          if (response.statusCode == 200) {
            return true;
          }
        } catch (_) {
          // swallow and retry
        }
        await Future.delayed(delay);
      }
    } finally {
      client.close(force: true);
    }

    return false;
  }

  String _extractErrorMessage(
    DioException exception, {
    required String fallback,
  }) {
    final data = exception.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }

      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        for (final value in errors.values) {
          if (value is String && value.isNotEmpty) {
            return value;
          }
          if (value is List && value.isNotEmpty) {
            final first = value.first;
            if (first is String && first.isNotEmpty) {
              return first;
            }
          }
        }
      }
    }
    return fallback;
  }

}
