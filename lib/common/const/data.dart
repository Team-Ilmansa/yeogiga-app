import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// secure storage용 key
const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';
const SOCIAL_TEMP_TOKEN = 'SOCIAL_TEMP_TOKEN';

final storage = FlutterSecureStorage();

// .env에서 API Base URL 로드
// 프로덕션: https://api.yeogiga.com/api/v1
// 로컬 개발 시 .env 파일에서 변경 가능
final baseUrl = dotenv.get('API_BASE_URL', fallback: 'https://api.yeogiga.com/api/v1');
