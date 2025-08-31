import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// secure storage용 key
const ACCESS_TOKEN_KEY = 'ACCESS_TOKEN';
const REFRESH_TOKEN_KEY = 'REFRESH_TOKEN';
const SOCIAL_TEMP_TOKEN = 'SOCIAL_TEMP_TOKEN';

final storage = FlutterSecureStorage();

final emulatorIp = '192.168.0.18:3000';
final simulatorIp = '127.0.0.1:3000';

// final ip = Platform.isIOS ? simulatorIp : emulatorIp;
final ip = 'api.yeogiga.com';
