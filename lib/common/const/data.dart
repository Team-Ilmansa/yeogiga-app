import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// secure storage용 key
const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';

final storage = FlutterSecureStorage();

final emulatorIp = '192.168.0.18:3000';
final simulatorIp = '127.0.0.1:3000';

// final ip = Platform.isIOS ? simulatorIp : emulatorIp;
final ip = 'api.yeogiga.com';

final kakaoRedirectUri = 'http://yeogiga.com/oauth/kakao/callback';
// final kakaoRedirectUri =
//     'kakao0e2b4c6886ca5a40118dd41935b17592://login-callback';
