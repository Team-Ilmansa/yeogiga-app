import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// secure storage용 key
const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';
const SOCIAL_TEMP_TOKEN = 'SOCIAL_TEMP_ACCESS_TOKEN';

final storage = FlutterSecureStorage();

final emulatorIp = '192.168.0.18:3000';
final simulatorIp = '127.0.0.1:3000';

// 환경변수에서 API URL 읽기
final ip = dotenv.get('API_BASE_URL');

// 환경변수에서 카카오 리다이렉트 URI 읽기
final kakaoRedirectUri = dotenv.get('KAKAO_REDIRECT_URI');
// final kakaoRedirectUri =
//     'kakao0e2b4c6886ca5a40118dd41935b17592://login-callback';
