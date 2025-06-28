import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/dio/dio.dart';
import 'package:yeogiga/common/model/login_response.dart';
import 'package:yeogiga/common/model/login_response_wrapper.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return AuthRepository(baseUrl: 'https://$ip', dio: dio);
});

class AuthRepository {
  final String baseUrl;
  final Dio dio;

  AuthRepository({required this.baseUrl, required this.dio});

  Future<LoginResponseWrapper> login({
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

    return LoginResponseWrapper.fromJson(resp.data);
  }

  Future<LoginResponse> token() async {
    final resp = await dio.post(
      '$baseUrl/api/v1/auth/reissue',
      options: Options(headers: {'device': 'MOBILE', 'refreshToken': 'true'}),
    );

    return LoginResponse.fromJson(resp.data['data']);
  }
}
