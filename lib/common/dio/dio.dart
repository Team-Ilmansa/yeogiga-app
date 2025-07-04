import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yeogiga/common/const/data.dart';
import 'package:yeogiga/common/secure_storage/secure_storage.dart';
import 'package:yeogiga/user/provider/user_me_provider.dart';

// 디오 항상 살아있도록
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();

  final storage = ref.watch(secureStorageProvider);

  // 만든 인터셉터 넣어줌.
  dio.interceptors.add(CustomInterceptor(storage: storage, ref: ref));

  return dio;
});

// dio보낼때 인터셉터
class CustomInterceptor extends Interceptor {
  final FlutterSecureStorage storage;
  final Ref ref;

  CustomInterceptor({required this.storage, required this.ref});

  // 1) 요청을 보낼때
  // 요청이 보내질때마다
  // 만약에 요청의 Header에 accessToken: true라는 값이 있다면
  // 실제 토큰을 가져와서 (storage에서) authorization: bearer $token으로
  // 헤더를 변경한다.
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('[REQ] [${options.method}] ${options.uri}');

    if (options.headers['accessToken'] == 'true') {
      // 헤더 삭제
      options.headers.remove('accessToken');

      final token = await storage.read(key: ACCESS_TOKEN_KEY);

      // 실제 토큰으로 대체
      options.headers.addAll({'Authorization': 'Bearer $token'});
    }

    if (options.headers['refreshToken'] == 'true') {
      // 헤더 삭제
      options.headers.remove('refreshToken');

      final token = await storage.read(key: REFRESH_TOKEN_KEY);

      // 실제 토큰으로 대체
      options.headers.addAll({'refreshToken': '$token'});
    }

    return super.onRequest(options, handler);
  }

  // 2) 응답을 받을때
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      '[RES] [${response.requestOptions.method}] ${response.requestOptions.uri}',
    );

    return super.onResponse(response, handler);
  }

  // 3) 에러가 났을때
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 401에러가 났을때 (status code)
    // 토큰을 재발급 받는 시도를하고 토큰이 재발급되면
    // 다시 새로운 토큰으로 요청을한다.
    print('[ERR] [${err.requestOptions.method}] ${err.requestOptions.uri}');

    print('[DioException] status: ${err.response?.statusCode}');
    print('[DioException] headers: ${err.response?.headers}');
    print('[DioException] data: ${err.response?.data}');

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    // refreshToken 아예 없으면
    // 당연히 에러를 던진다
    if (refreshToken == null) {
      // 에러를 던질때는 handler.reject를 사용한다.
      return handler.reject(err);
    }
    print(1);

    final isStatus401 = err.response?.statusCode == 401;
    final isPathRefresh = err.requestOptions.path == '/api/v1/auth/reissue';

    //중간에 토큰 날아갔을 때 대처
    if (isStatus401 && !isPathRefresh) {
      final dio = Dio();

      print(3);
      try {
        final resp = await dio.get(
          'https://$ip/api/v1/auth/reissue',
          options: Options(
            headers: {'device': 'MOBILE', 'refreshToken': refreshToken},
          ),
        );
        print(2);

        final newAccessToken = resp.data['data']['accessToken'];
        final newRefreshToken = resp.data['data']['refreshToken'];

        final options = err.requestOptions;

        // 토큰 변경하기
        options.headers.addAll({
          'device': 'MOBILE',
          'Authorization': 'Bearer $newAccessToken',
        });

        await storage.write(key: ACCESS_TOKEN_KEY, value: newAccessToken);
        //앱을 아예 사용안해서, refresh토큰까지 만료되어야 logout 되도록.
        await storage.write(key: REFRESH_TOKEN_KEY, value: newRefreshToken);

        // 요청 재전송
        final response = await dio.fetch(options);

        return handler.resolve(response);
      } on DioException catch (e) {
        // circular dependency error
        // A, B
        // A -> B의 친구
        // B -> A의 친구
        // A는 B의 친구구나
        // A -> B -> A -> B -> A -> B
        // ump -> dio -> ump -> dio
        ref.read(userMeProvider.notifier).logout();

        return handler.reject(e);
      }
    }

    // onError에서 처리하고 싶지 않은 것들은 여기에 하나씩 추가
    final path = err.requestOptions.path;
    if (path == '/api/v1/auth/dup-check/username' ||
        path == '/api/v1/auth/dup-check/nickname' ||
        path == '/api/v1/auth/sign-up' ||
        path == '/api/v1/users' ||
        path == '/api/v1/trip' ||
        path.startsWith('/api/v1/trip/')) {
      //TODO: 응답 전체 출력 (디버깅용)

      return handler.reject(err);
    }

    // 아래에서부터 statusCode에 따라 원하는 처리 입력
    // if (condition) {}

    return handler.reject(err);
  }
}
