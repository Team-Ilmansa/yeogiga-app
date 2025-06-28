import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/common/secure_storage/secure_storage.dart';
import 'package:yeogiga/user/model/register_response.dart';

//프로바이더에 담기
final registerRepositoryProvider = Provider<RegisterRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final storage = ref.watch(secureStorageProvider);

  return RegisterRepository(baseUrl: 'https://$ip', dio: dio, storage: storage);
});

//api들
class RegisterRepository {
  final String baseUrl;
  final Dio dio;
  final FlutterSecureStorage storage;

  RegisterRepository({
    required this.baseUrl,
    required this.dio,
    required this.storage,
  });

  //아이디 중복
  Future<bool> checkUsernameAvailable(String username) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/auth/dup-check/username',
        queryParameters: {'value': username},
      );
      final data = response.data;
      if (data['code'] == 200) {
        return true; // 사용 가능
      } else {
        throw Exception('알 수 없는 오류: [${data['message']}]');
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      // if (data != null && data['code'] == 'A011') {
      return false; // 이미 사용 중
      // }
      // throw Exception('네트워크 오류 또는 알 수 없는 오류: ${e.message}');
    }
  }

  //닉네임 중복
  Future<bool> checkNicknameAvailable(String nickname) async {
    try {
      final response = await dio.get(
        '$baseUrl/api/v1/auth/dup-check/nickname',
        queryParameters: {'value': nickname},
      );
      final data = response.data;

      if (data['code'] == 200) {
        return true; // 사용 가능
      }
      throw Exception('알 수 없는 오류: ${data['message']}');
    } on DioException catch (e) {
      // if (data != null && data['code'] == 'A012') {
      return false;
      // }
      // throw Exception('네트워크 오류 또는 알 수 없는 오류: ${e.message}');
    }
  }

  //회원가입
  Future<RegisterResponse> register({
    required String username,
    required String password,
    required String email,
    required String nickname,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/v1/auth/sign-up',
        data: {
          "username": username,
          "password": password,
          "email": email,
          "nickname": nickname,
        },
      );

      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      return RegisterResponse.fromJson(e.response?.data);
    }
  }

  //회원탈퇴
  Future<bool> deleteUser() async {
    try {
      final response = await dio.delete(
        '$baseUrl/api/v1/users',
        options: Options(headers: {'accessToken': 'true'}),
      );

      storage.delete(key: REFRESH_TOKEN_KEY);
      storage.delete(key: ACCESS_TOKEN_KEY);

      return true;
    } on DioException catch (e) {
      return false;
    }
  }
}
