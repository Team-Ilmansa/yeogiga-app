import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/common/model/login_response.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return AuthRepository(baseUrl: 'https://$ip', dio: dio);
});

class AuthRepository {
  final String baseUrl;
  final Dio dio;

  AuthRepository({required this.baseUrl, required this.dio});

  //로그인
  Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    final resp = await dio.post(
      '$baseUrl/api/v1/auth/sign-in',
      options: Options(
        headers: {'device': 'MOBILE'},
        contentType: 'application/json',
      ),
      data: {'username': username, 'password': password},
    );

    return LoginResponse.fromJson(resp.data['data']);
  }

  // 토큰들 재발급
  Future<LoginResponse> token() async {
    final resp = await dio.post(
      '$baseUrl/api/v1/auth/reissue',
      options: Options(headers: {'device': 'MOBILE', 'refreshToken': 'true'}),
    );

    return LoginResponse.fromJson(resp.data['data']);
  }
}
