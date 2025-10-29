# 여기가 (Yeogiga) 🌏

그룹 여행을 더 쉽고 재미있게! 일정 관리부터 비용 정산, 추억 공유까지 한 번에.

## 📱 주요 기능

### 여행 관리
- **여행 생성 및 초대**: 딥링크를 통해 친구들을 여행에 간편하게 초대
- **일정 관리**: 가고 싶은 장소 제안 → 확정 일정 → 방문 완료까지 3단계 관리
- **실시간 위치 공유**: 여행 중 FCM을 통한 백그라운드 위치 추적

### 정산
- **비용 분할**: 여러 명이 함께 낸 비용을 자동으로 계산
- **일자별 정리**: 여행 날짜별로 정산 내역 정리
- **완료 여부 추적**: 누가 정산했는지, 아직 안했는지 한눈에 확인

### 사진 관리
- **위치 기반 매칭**: GPS 정보로 방문한 장소와 사진 자동 연결
- **갤러리 저장 및 공유**: 여행 사진을 쉽게 저장하고 공유
- **미매칭 사진 관리**: 수동으로 장소에 사진 할당 가능

### 일정 조율
- **When2Meet 스타일**: 팀원들의 가능한 날짜를 겹쳐서 확인
- **최적 날짜 선택**: 모두가 가능한 날짜를 시각적으로 파악

### 장소 검색
- **네이버 지도 통합**: 네이버 지도 API로 장소 검색 및 선택
- **상세 정보**: 주소, 카테고리, 전화번호 등 장소 정보 제공

## 🛠 기술 스택

- **프레임워크**: Flutter 3.35.4 / Dart 3.9.2
- **상태 관리**: Riverpod 2.6.1
- **네트워킹**: Dio + Retrofit
- **라우팅**: GoRouter 7.0.0
- **인증**: Kakao Flutter SDK
- **푸시 알림**: Firebase Cloud Messaging
- **지도**: Flutter Naver Map
- **보안 저장소**: Flutter Secure Storage

## 🚀 시작하기

### 필수 요구사항

- Flutter SDK 3.7.0 이상
- Dart SDK 3.9.0 이상
- iOS: Xcode 14 이상
- Android: Android Studio / Gradle

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
   ```
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

   **로컬 개발 시 API 서버 변경:**
   ```
   # Android Emulator
   API_BASE_URL=http://192.168.0.18:3000/api/v1

   # iOS Simulator
   API_BASE_URL=http://127.0.0.1:3000/api/v1
   ```

4. **코드 생성**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. **앱 실행**
   ```bash
   flutter run
   ```

## 📂 프로젝트 구조

```
lib/
├── common/              # 공통 컴포넌트, 상수, 유틸리티
├── trip/                # 여행 생성, 참가, 초대 관리
├── main_trip/           # 홈 화면 및 현재 진행 중인 여행
├── trip_list/           # 과거/현재 여행 목록
├── schedule/            # 일정 관리 (제안, 확정, 완료)
├── settlement/          # 비용 정산 기능
├── trip_image/          # 사진 관리 및 위치 매칭
├── user/                # 사용자 인증 및 관리
├── notice/              # 알림 및 핑 시스템
├── naver/               # 네이버 지도 장소 검색
└── w2m/                 # When2Meet 일정 조율
```

각 기능 모듈은 다음과 같은 구조를 따릅니다:
- `model/` - 데이터 모델
- `repository/` - API 통신 레이어
- `provider/` - Riverpod 상태 관리
- `view/` or `screen/` - UI 화면
- `component/` - 재사용 가능한 UI 컴포넌트

## 🔧 개발 명령어

### 코드 생성
```bash
# JSON 직렬화 및 Retrofit API 클라이언트 생성
dart run build_runner build --delete-conflicting-outputs

# 파일 변경 감지 및 자동 생성 (개발 중 유용)
dart run build_runner watch --delete-conflicting-outputs
```

### 코드 품질
```bash
# 정적 분석
flutter analyze

# 코드 포맷팅
dart format .

# 테스트 실행
flutter test
```

### 빌드
```bash
# Android APK
flutter build apk --release

# Android App Bundle (플레이스토어용)
flutter build appbundle --release

# iOS
flutter build ios --release
```

### 아이콘 및 스플래시 스크린
```bash
# 앱 아이콘 생성
flutter pub run flutter_launcher_icons

# 스플래시 스크린 생성
flutter pub run flutter_native_splash:create
```

## 🏗 아키텍처 개요

### 상태 관리 (Riverpod)

앱은 Riverpod을 사용하여 상태를 관리합니다:

- **StateNotifierProvider**: 복잡한 비즈니스 로직과 상태 변경
- **FutureProvider**: 비동기 데이터 페칭
- **Provider**: 의존성 주입 (Dio, GoRouter 등)

### API 통신

- **Retrofit**: 타입 안전한 API 클라이언트 정의
- **Dio**: HTTP 클라이언트
- **CustomInterceptor**: 자동 토큰 주입 및 갱신

```dart
// API 호출 시 자동으로 액세스 토큰 주입
@Headers({'accessToken': 'true'})
Future<UserResponseModel> getMe();
```

### 라우팅

GoRouter를 사용하여 선언적 라우팅 및 딥링크를 처리합니다:

- 인증 상태 기반 라우트 보호
- 비인증 사용자의 딥링크 URL 보존
- 커스텀 페이지 전환 애니메이션

### 딥링크

여행 초대 기능을 위한 딥링크를 지원합니다:

**URL 스킴**: `yeogiga://trip/invite/:tripId`

**동작 흐름**:
1. 초대 링크 클릭
2. 비로그인 시 로그인 페이지로 이동 (초대 URL 보존)
3. 로그인 후 자동으로 여행 참가 처리
4. 여행 상세 화면으로 이동

## 🔐 인증 및 보안

- **Kakao Login**: 카카오 소셜 로그인
- **JWT 토큰**: 액세스/리프레시 토큰 방식
- **자동 토큰 갱신**: 401 에러 시 자동으로 토큰 재발급 및 재시도
- **Flutter Secure Storage**: 토큰 암호화 저장

## 🔔 푸시 알림 (FCM)

Firebase Cloud Messaging을 통한 실시간 위치 추적:

- **백그라운드 핸들러**: 앱이 백그라운드에 있어도 위치 정보 수집
- **자동 위치 전송**: 현재 GPS 좌표를 서버에 자동 전송
- **여행 일차 계산**: 여행 시작일 기준 현재 며칠째인지 계산

## 🎨 디자인 시스템

- **폰트**: Pretendard (9개 굵기: 100~900)
- **반응형 디자인**: flutter_screenutil (디자인 기준: 393×852)
- **아이콘**: SVG 형식
- **컬러 팔레트**: `lib/common/const/colors.dart`

## 📦 주요 의존성

```yaml
# 상태 관리
flutter_riverpod: ^2.6.1

# 네트워킹
dio: ^5.8.0+1
retrofit: ^4.4.2

# 라우팅
go_router: ^7.0.0

# Firebase
firebase_core: ^3.13.1
firebase_messaging: ^15.2.6

# 인증
kakao_flutter_sdk_user: ^1.9.7+3
kakao_flutter_sdk_auth: ^1.9.7+3

# 지도
flutter_naver_map: ^1.3.1

# 보안
flutter_secure_storage: ^9.2.4

# UI
flutter_screenutil: ^5.9.3
flutter_svg: ^2.0.7
```

## 🌿 브랜치 전략

- **main**: 프로덕션 브랜치 (안정 버전)
- **Feature(\*)**: 기능별 브랜치 (예: `Feature(IL-362)-딥링크(여행초대)`)

## 📝 커밋 규칙

```
Feature: 새로운 기능 추가
UI: UI/UX 개선
Fix: 버그 수정
Refactor: 코드 리팩토링
Docs: 문서 수정
Test: 테스트 추가/수정
Chore: 빌드 설정, 의존성 업데이트 등
```

## 🐛 알려진 이슈

- iOS 시뮬레이터에서 네이버 지도 로딩이 느릴 수 있습니다 (실제 기기에서는 정상)
- FCM 백그라운드 핸들러는 위치 권한이 항상 허용되어야 합니다

## 🤝 기여하기

1. 기능 브랜치 생성 (`Feature(ISSUE-번호)-기능명`)
2. 변경사항 커밋
3. 브랜치 푸시
4. Pull Request 생성

## 📄 라이선스

Private project - All rights reserved

## 👥 팀

Team Ilmansa

---

**버전**: 1.0.0+3
