# 여기가 (Yeogiga) 🌏

[![Flutter](https://img.shields.io/badge/Flutter-3.35.4-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2-0175C2?logo=dart)](https://dart.dev)
[![Version](https://img.shields.io/badge/version-1.0.0+3-green)](https://github.com)

**그룹 여행을 더 쉽고 재미있게!** 일정 관리부터 비용 정산, 추억 공유까지 한 번에.

여기가는 친구, 동료, 가족과 함께하는 여행의 모든 과정을 체계적으로 관리하는 종합 여행 동반자 앱입니다.

## 📊 프로젝트 통계

- **총 코드 라인**: 27,834 줄
- **Dart 파일**: 174개
- **기능 모듈**: 11개 독립 모듈
- **API 엔드포인트**: 65개
- **화면 수**: 24개
- **상태 관리 Provider**: 58개 (StateNotifier 18개, Future 15개, Provider 25개)

## 📱 주요 기능

### 🗓 일정 조율 (When2Meet)
- **팀원 가능 날짜 입력**: 각자 여행 가능한 날짜 범위 선택
- **시각적 겹침 표시**: 여러 명의 일정이 겹치는 날짜를 색상 농도로 표시
- **최적 날짜 선택**: 모두가 가능한 날짜를 한눈에 파악

### 🗺 일정 관리 (3단계 워크플로우)
1. **제안 단계 (Pending)**: 멤버들이 가고 싶은 장소를 자유롭게 제안
2. **확정 단계 (Confirmed)**: 리더가 최종 일정 확정 및 순서 설정
3. **완료 단계 (Completed)**: 방문 완료 체크 및 사진 자동 매칭

- **네이버 지도 연동**: 장소 검색 및 상세 정보 제공
- **드래그 앤 드롭**: 직관적인 일정 순서 변경

### 📸 GPS 기반 사진 자동 매칭
- **EXIF 메타데이터 분석**: 사진의 GPS 좌표 자동 추출
- **100m 반경 자동 매칭**: 확정된 장소와 사진을 자동으로 연결
- **장소별 앨범**: 방문한 장소마다 사진이 자동으로 정리
- **즐겨찾기**: 마음에 드는 사진에 별표 표시
- **재매칭 기능**: 일정 수정 후 사진 위치 재계산

### 📍 실시간 위치 추적
- **FCM 백그라운드 핸들러**: 앱이 비활성 상태여도 5분마다 위치 자동 전송
- **실시간 지도**: 여행 중 멤버들의 현재 위치 표시
- **경로 기록**: 방장의 이동 경로 자동 저장
- **여행 복기**: 완료된 여행의 전체 경로를 지도에 표시

### 💰 정산 관리
- **1/n 자동 계산**: 참여 인원에 따라 비용 자동 분할
- **일자별 정리**: 여행 날짜별로 정산 내역 그룹화
- **체크리스트**: 각 멤버의 정산 완료 여부 추적
- **정산 타입**: 더치페이(Dutch Pay) 및 커스텀 분담 지원

### 🔔 공지사항 및 집결지
- **리더 공지사항**: 전체 멤버에게 중요 메시지 전달 (완료 체크)
- **집결지 (Ping)**: 만날 장소와 시간 공유 (도착 확인)

### 🔗 딥링크 초대
- **URL 스킴**: `yeogiga://trip/invite/:tripId`
- **원클릭 참가**: 링크 클릭만으로 여행 자동 참가
- **인증 후 복귀**: 비로그인 시 로그인 후 자동으로 원래 초대 링크로 이동

## 🛠 기술 스택

### 핵심 프레임워크
- **Flutter**: 3.35.4 (크로스플랫폼 UI)
- **Dart**: 3.9.2

### 상태 관리
- **flutter_riverpod** 2.6.1
  - StateNotifierProvider: 복잡한 비즈니스 로직
  - FutureProvider: 비동기 데이터 페칭
  - Provider: 의존성 주입

### 네트워킹
- **dio** 5.8.0: HTTP 클라이언트
- **retrofit** 4.4.2: 타입 안전 REST API 클라이언트
- **json_serializable**: JSON 직렬화

### 라우팅
- **go_router** 7.0.0: 선언적 라우팅 및 딥링크

### 외부 서비스
- **Firebase**
  - `firebase_core`: 초기화
  - `firebase_messaging`: FCM 푸시 알림
- **Kakao**
  - `kakao_flutter_sdk_user`: 소셜 로그인
  - `kakao_flutter_sdk_auth`: 인증
- **Naver**
  - `flutter_naver_map`: 지도 SDK
  - Naver Place Search API: 장소 검색

### 위치 및 미디어
- **geolocator**: GPS 위치 (실시간 추적)
- **file_picker**: 파일 선택
- **exif**: EXIF 메타데이터 (GPS 좌표 추출)
- **image_gallery_saver_plus**: 갤러리 저장
- **share_plus**: 공유 기능

### 보안
- **flutter_secure_storage**: JWT 토큰 암호화 저장

### UI/UX
- **flutter_screenutil**: 반응형 디자인 (393×852 기준)
- **flutter_svg**: SVG 아이콘
- **skeletons**: 로딩 스켈레톤
- **liquid_pull_to_refresh**: 물방울 효과 새로고침
- **flutter_slidable**: 스와이프 제스처

## 🏗 아키텍처

### Feature-Based 모듈 구조

11개의 독립적인 기능 모듈로 구성되어 있으며, 각 모듈은 Model-Repository-Provider-View 계층으로 명확히 분리되어 있습니다.

```
lib/
├── common/              # 공통 컴포넌트, 상수, 유틸리티 (41개 파일)
│   ├── component/       # 재사용 UI 컴포넌트
│   ├── const/          # 상수 (색상, API URL)
│   ├── dio/            # CustomInterceptor (JWT 자동 갱신)
│   ├── provider/       # 핵심 Provider (Dio, GoRouter)
│   └── service/        # FCM 백그라운드 핸들러
│
├── trip/                # 여행 생성/관리/초대 (31개 파일)
├── main_trip/           # 홈 화면 (4개 파일)
├── trip_list/           # 여행 목록 (3개 파일)
├── schedule/            # 일정 관리 (14개 파일)
├── settlement/          # 비용 정산 (10개 파일)
├── trip_image/          # 사진 관리 (10개 파일)
├── user/                # 사용자 인증 (15개 파일)
├── notice/              # 공지사항/집결지 (10개 파일)
├── naver/               # 네이버 API (3개 파일)
└── w2m/                 # When2Meet (6개 파일)
```

각 기능 모듈은 다음 구조를 따릅니다:
- `model/` - 데이터 모델 (@JsonSerializable)
- `repository/` - API 통신 레이어 (Retrofit/Dio)
- `provider/` - Riverpod 상태 관리
- `view/` or `screen/` - UI 화면
- `component/` - 재사용 가능한 UI 컴포넌트

### 상태 관리 패턴

**Riverpod 3가지 주요 패턴**:

```dart
// 1. StateNotifierProvider - 복잡한 상태 관리
final userMeProvider = StateNotifierProvider<UserMeStateNotifier, UserModelBase?>

// 2. FutureProvider - 비동기 데이터 페칭 (auto-dispose)
final mainTripFutureProvider = FutureProvider.autoDispose<MainTripModel?>

// 3. Provider - 의존성 주입
final dioProvider = Provider<Dio>
```

**주요 패턴**:
- `AsyncValue<T>`: loading/error/data 자동 처리
- `.when()`: 상태별 UI 분기
- `ref.watch()`: build 메서드에서 상태 구독
- `ref.read()`: 이벤트 핸들러에서 상태 읽기
- **Optimistic UI**: 네트워크 응답 전 UI 즉시 업데이트, 실패 시 롤백

### API 통신 레이어

**2가지 접근 방식**:

#### (1) Retrofit - 단순 CRUD
```dart
@RestApi()
abstract class UserMeRepository {
  @GET('/users/my')
  @Headers({'accessToken': 'true'})  // 자동 토큰 주입
  Future<UserResponseModel> getMe();
}
```

#### (2) 수동 Dio - 복잡한 로직
```dart
Future<PostTripResponse> postTrip({required String title}) async {
  final response = await dio.post(
    '$baseUrl/trip',
    options: Options(headers: {"accessToken": 'true'}),
    data: {"title": title},
  );
  return PostTripResponse.fromJson(response.data);
}
```

**CustomInterceptor 기능**:
- ✅ JWT 토큰 자동 주입 (`'accessToken': 'true'` 헤더 감지)
- ✅ 401 에러 시 Refresh Token으로 자동 재발급
- ✅ 원본 요청 자동 재시도 (새 토큰 사용)
- ✅ Refresh Token 만료 시 자동 로그아웃

### 라우팅 및 딥링크

**GoRouter 주요 기능**:
- 인증 상태 기반 route guard (`authProvider.redirectLogic`)
- 비인증 사용자의 딥링크 URL 보존 (로그인 후 복귀)
- 커스텀 페이지 전환 애니메이션 (fade + slide, 150ms)
- Route observer로 생명주기 관리

**딥링크 처리 흐름**:
1. `yeogiga://trip/invite/:tripId` 클릭
2. 비로그인 → `/login?redirect=%2Ftrip%2Finvite%2F123`
3. 로그인 성공 → 자동으로 `/trip/invite/123`로 이동
4. `TripInviteHandler`에서 자동으로 여행 참가 API 호출
5. 성공 시 여행 상세 화면으로 이동

## 🚀 시작하기

### 필수 요구사항

- **Flutter SDK**: 3.7.0 이상
- **Dart SDK**: 3.9.0 이상
- **iOS**: Xcode 14 이상, CocoaPods
- **Android**: Android Studio, Gradle 7.0+

### 설치 방법

1. **저장소 클론**
   ```bash
   git clone [repository-url]
   cd yeogiga-app
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **환경 변수 설정**

   `.env.example` 파일을 복사하여 `.env` 파일 생성:
   ```bash
   cp .env.example .env
   ```

   그 후 실제 API 키 값들을 입력:
   ```env
   # API 서버 (프로덕션)
   API_BASE_URL=https://api.yeogiga.com/api/v1

   # 네이버 지도
   NAVER_MAP_API_CLIENT_ID=your_naver_map_key

   # 네이버 장소 검색
   NAVER_PLACE_SEARCH_CLIENT_ID=your_naver_client_id
   NAVER_PLACE_SEARCH_CLIENT_SECRET=your_naver_client_secret

   # 카카오 로그인
   KAKAO_NATIVE_APP_KEY=your_kakao_key
   ```

   **로컬 개발 시 API 서버 변경**:
   ```env
   # Android Emulator (로컬 네트워크 IP 필요)
   API_BASE_URL=http://192.168.0.18:3000/api/v1

   # iOS Simulator
   API_BASE_URL=http://127.0.0.1:3000/api/v1
   ```

4. **코드 생성**

   JSON 직렬화 및 Retrofit API 클라이언트 생성:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

   **중요**: 모델이나 Repository를 수정할 때마다 이 명령어를 실행해야 합니다.

   개발 중 자동 생성 (watch 모드):
   ```bash
   dart run build_runner watch --delete-conflicting-outputs
   ```

5. **앱 실행**
   ```bash
   # 기본 실행
   flutter run

   # 특정 디바이스 선택
   flutter devices
   flutter run -d <device-id>
   ```

## 🔧 개발 명령어

### 코드 품질
```bash
# 정적 분석
flutter analyze

# 코드 포맷팅
dart format .

# 테스트 실행
flutter test

# 테스트 커버리지
flutter test --coverage
```

### 빌드
```bash
# Android APK
flutter build apk --release

# Android App Bundle (Google Play용)
flutter build appbundle --release

# iOS
flutter build ios --release
```

### 클린 빌드
```bash
# 빌드 캐시 삭제 및 재설치
flutter clean && flutter pub get

# 전체 재빌드 (코드 생성 포함)
flutter clean && flutter pub get && dart run build_runner build --delete-conflicting-outputs
```

### 아이콘 및 스플래시 스크린
```bash
# 앱 아이콘 생성
flutter pub run flutter_launcher_icons

# 스플래시 스크린 생성
flutter pub run flutter_native_splash:create
```

## 🔐 인증 및 보안

### 인증 흐름
1. **카카오 소셜 로그인** → 임시 토큰 발급
2. **닉네임 설정** (신규 사용자)
3. **정식 JWT 토큰 발급** (Access + Refresh Token)
4. **자동 토큰 갱신** (401 에러 시 Refresh Token으로 재발급)

### 보안 저장소
- **flutter_secure_storage** 사용
  - iOS: Keychain
  - Android: EncryptedSharedPreferences
- 저장 항목: `ACCESS_TOKEN`, `REFRESH_TOKEN`

### 토큰 자동 갱신 메커니즘
```dart
// CustomInterceptor에서 자동 처리
onError(DioException err) {
  if (err.response?.statusCode == 401) {
    // 1. Refresh Token으로 새 토큰 발급
    // 2. Secure Storage에 저장
    // 3. 원본 요청 헤더 업데이트
    // 4. 원본 요청 재시도
  }
}
```

## 🔔 FCM 백그라운드 위치 추적

### 동작 원리
1. 서버에서 여행 진행 중인 사용자에게 5분마다 FCM 데이터 메시지 전송
2. `@pragma('vm:entry-point')` 백그라운드 핸들러 실행 (별도 isolate)
3. GPS 위치 획득 (`geolocator`)
4. 여행 시작일 기준 현재 일차(day) 계산
5. 2개 API 동시 호출:
   - `/trip/:tripId/members/location` (멤버 위치)
   - `/trip/:tripId/days/:day/routes` (호스트 경로)

### 권한 요구사항
- **Android**: `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`
- **iOS**: `NSLocationAlwaysUsageDescription`
- 사용자 설정: **"항상 허용"** 위치 권한 필요

## 🎨 디자인 시스템

### 타이포그래피
- **폰트**: Pretendard (9가지 Weight: 100~900)
- **기본 크기**: 14sp ~ 25sp

### 반응형 디자인
**디자인 기준**: 393×852 (iPhone 13/14 기준)

```dart
ScreenUtilInit(designSize: const Size(393, 852))

// 사용 예시
Text('Hello', style: TextStyle(fontSize: 16.sp))  // 화면 비례 폰트
Container(width: 100.w, height: 50.h)              // 비례 너비/높이
SizedBox(height: 20.h)                              // 비례 간격
BorderRadius.circular(12.r)                         // 비례 반경
```

### 재사용 컴포넌트
- `ConfirmationDialog`: 확인/취소 다이얼로그 (삭제, 로그아웃 등)
- `CustomTextFormField`: 통일된 텍스트 입력 필드
- `PrimaryButton`: 메인 액션 버튼
- `SettingTripCard` / `TripCard`: 여행 카드 UI
- `DaySelector`: 일차 선택 컴포넌트

### 아이콘
- SVG 형식 (22개 커스텀 아이콘)
- 위치: `asset/icon/`

## 🚢 CI/CD

### Codemagic 자동 배포

**트리거**: `main` 브랜치 push 시 자동 실행

**빌드 파이프라인**:
1. ✅ Android Keystore 디코드
2. ✅ Flutter 의존성 설치 (`flutter pub get`)
3. ✅ 정적 분석 (`flutter analyze`)
4. ✅ 테스트 실행 (`flutter test`)
5. ✅ AAB 빌드 (`flutter build appbundle --release`)
6. ✅ Google Play Internal Test Track 자동 업로드

**환경 변수** (Codemagic 설정):
- `CM_KEYSTORE`: Base64 인코딩된 Keystore
- `CM_KEYSTORE_PASSWORD`, `CM_KEY_PASSWORD`, `CM_KEY_ALIAS`
- `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`: Google Play 인증 JSON

**버전 관리**:
- Format: `major.minor.patch+buildNumber`
- `pubspec.yaml`에서 관리
- 현재 버전: **1.0.0+3**

## 🌿 브랜치 전략

- **main**: 프로덕션 브랜치 (안정 버전)
- **Feature(\*)**: 기능별 브랜치
  - 예: `Feature(IL-362)-딥링크(여행초대)`
  - 예: `Feature-사진-크게보기-UI-및-로직-구현`

## 📝 커밋 규칙

```
Feature: 새로운 기능 추가
UI: UI/UX 개선
Fix: 버그 수정
Refactor: 코드 리팩토링
Docs: 문서 수정
Test: 테스트 추가/수정
Chore: 빌드 설정, 의존성 업데이트
```

## 💡 특별한 구현 사항

### 1. GPS 사진 자동 매칭 알고리즘
```dart
// EXIF 메타데이터에서 GPS 좌표 추출
final exifData = await readExifFromBytes(imageBytes);
final latitude = exifData['GPS GPSLatitude'];
final longitude = exifData['GPS GPSLongitude'];

// 확정된 장소와 거리 계산 (100m 반경 내 자동 매칭)
final distance = Geolocator.distanceBetween(
  photoLat, photoLng, placeLat, placeLng
);
if (distance <= 100) {
  // 자동 매칭
}
```

### 2. Optimistic UI 업데이트
```dart
// 즉시 UI 반영 (네트워크 응답 대기 안함)
state = AsyncValue.data(updatedState);

// 서버 요청
final success = await repository.update(...);

// 실패 시 롤백
if (!success) {
  state = previousState;
}
```

### 3. JWT 자동 갱신 (Seamless UX)
사용자는 토큰 만료를 전혀 인지하지 못함. 모든 API 요청에 자동 적용.

### 4. 딥링크 URL 보존
비로그인 사용자가 초대 링크 클릭 → 로그인 후 자동으로 원래 초대 링크로 복귀

## 🐛 알려진 이슈

- iOS 시뮬레이터에서 네이버 지도 로딩이 느릴 수 있습니다 (실제 기기에서는 정상)
- FCM 백그라운드 핸들러는 위치 권한이 "항상 허용"이어야 정상 동작합니다
- Android Emulator에서 로컬 API 서버 접속 시 `10.0.2.2` 또는 로컬 네트워크 IP 사용 필요

## 🤝 기여하기

1. 기능 브랜치 생성 (`Feature(ISSUE-번호)-기능명`)
2. 변경사항 커밋
3. 브랜치 푸시
4. Pull Request 생성 (템플릿 참조: `.github/PULL_REQUEST_TEMPLATE.md`)

## 📚 추가 문서

- **CLAUDE.md**: 프로젝트 가이드 (아키텍처, 패턴, 주의사항)
- **CI.md**: CI 파이프라인 상세 문서
- **CD.md**: CD 배포 프로세스 문서

## 📄 라이선스

Private project - All rights reserved

## 👥 팀

**Team Ilmansa**

---

**버전**: 1.0.0+3
**마지막 업데이트**: 2025년 1월

**Made with ❤️ using Flutter**
