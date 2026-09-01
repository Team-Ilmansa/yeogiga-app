# 여기가

여러 명이 함께 여행을 준비하고 진행 상황을 공유할 수 있도록 만든 Flutter 모바일 앱입니다. 여행 생성과 초대, 날짜 조율, 장소 일정, 공지, 위치 공유, 사진, 정산 기능을 하나의 여행 단위로 관리합니다.

현재 Android와 iOS를 대상으로 개발하고 있으며, 대부분의 데이터는 별도 백엔드 API를 통해 조회하고 저장합니다.

## 구현 범위

- 아이디와 비밀번호를 이용한 회원가입 및 로그인
- 카카오 로그인과 신규 소셜 사용자의 닉네임 설정
- 여행 생성, 수정, 참여, 탈퇴, 삭제 및 초대 링크 공유
- 여행 가능 날짜 입력과 참여자별 가능 날짜 비교
- 네이버 장소 검색과 지도 기반 일정 등록
- 제안, 확정, 완료 단계의 일정 관리와 순서 변경
- 여행별 공지와 집결지 등록
- 진행 중인 여행의 멤버 위치 표시와 종료된 여행 지도
- 여행 사진 업로드, 일정 배정, 이동, 즐겨찾기, 저장 및 공유
- 여행별 정산 생성, 수정, 삭제와 참여자 완료 상태 관리
- 현재 위치 기반 날씨 조회
- Firebase Cloud Messaging을 이용한 알림 및 위치 동기화 처리

## 기술 구성

| 영역 | 사용 기술 |
| --- | --- |
| 애플리케이션 | Flutter, Dart |
| 상태 관리 | Riverpod, StateNotifier, AsyncValue |
| 네트워크 | Dio, Retrofit |
| 라우팅 | GoRouter |
| 인증 정보 저장 | Flutter Secure Storage |
| 푸시 | Firebase Core, Firebase Messaging, Flutter Local Notifications |
| 지도 및 장소 | Flutter Naver Map, Naver Place Search API |
| 소셜 로그인 | Kakao Flutter SDK |
| 위치 | Geolocator |
| 직렬화 및 코드 생성 | json_serializable, build_runner, retrofit_generator |

`pubspec.lock`에 기록된 현재 의존성은 Dart 3.8.0 이상과 Flutter 3.29.0 이상을 요구합니다. 로컬과 CI에서 같은 결과를 내려면 팀에서 사용하는 Flutter 버전을 맞춰야 합니다.

## 프로젝트 구조

```text
lib/
├── common/       공통 컴포넌트, 라우터, Dio, 권한, FCM 처리
├── user/         회원가입, 로그인, 계정 복구, 프로필
├── main_trip/    홈 화면과 대표 여행
├── trip/         여행 생성, 상세, 초대, 여행 지도
├── trip_list/    여행 목록 조회와 상태
├── w2m/          여행 가능 날짜 조율
├── schedule/     제안·확정·완료 일정과 장소 지도
├── notice/       공지와 집결지
├── settlement/   정산 내역과 완료 상태
├── trip_image/   여행 사진 업로드와 분류
├── naver/        네이버 장소 검색
└── dev/          개발용 화면
```

기능 폴더는 필요에 따라 다음 계층을 조합합니다.

- `model`: API 응답과 화면에서 사용하는 데이터 모델
- `repository`: Dio 또는 Retrofit 기반 API 호출
- `provider`: Riverpod 상태와 비즈니스 흐름
- `view`, `screen`: 화면
- `component`: 화면 내부에서 재사용하는 UI

일반적인 데이터 흐름은 다음과 같습니다.

```text
View -> Provider 또는 StateNotifier -> Repository -> Backend API
```

공통 Dio 인터셉터는 인증 요청에 액세스 토큰을 추가하고, 401 응답에서 토큰 재발급과 원래 요청 재시도를 처리합니다. 라우트와 인증 리다이렉트 규칙은 `lib/user/provider/auth_provider.dart`와 `lib/common/provider/go_router.dart`에 있습니다.

## 로컬 실행 준비

현재 저장소만 받은 상태에서는 바로 실행할 수 없습니다. 다음 설정 파일은 저장소에 포함되어 있지 않으므로 팀의 개발 환경 또는 서비스 콘솔에서 받아야 합니다.

- `.env`
- `lib/firebase_options.dart`
- `android/app/google-services.json`
- Android 릴리스 빌드용 `android/key.properties`와 키스토어

iOS용 `GoogleService-Info.plist`는 현재 저장소에 있지만, 사용할 Firebase 프로젝트와 일치하는지 확인해야 합니다.

### 환경 변수

프로젝트 루트에 `.env`를 만들고 다음 값을 설정합니다.

```dotenv
API_BASE_URL=
WEATHER_API_KEY=
NAVER_MAP_API_CLIENT_ID=
NAVER_PLACE_SEARCH_CLIENT_ID=
NAVER_PLACE_SEARCH_CLIENT_SECRET=
KAKAO_NATIVE_APP_KEY=
```

`API_BASE_URL`을 비워 두면 안 됩니다. API 주소에는 코드에서 사용하는 `/api/v1` 기준 경로가 포함되어야 합니다.

`.env`는 Flutter 애플리케이션 자산으로 패키징됩니다. 현재 장소 검색 구현은 네이버 클라이언트 시크릿을 이 파일에서 읽으므로, 배포용 비밀값을 안전하게 보관하는 구조가 아닙니다. 운영 배포 전에는 시크릿이 필요한 장소 검색 요청을 백엔드에서 처리하도록 변경해야 합니다.

### Firebase 설정

FlutterFire 설정 결과물인 `lib/firebase_options.dart`와 플랫폼별 Firebase 설정 파일이 필요합니다. Firebase 프로젝트를 새로 연결할 경우 FlutterFire CLI로 다시 생성하고, 기존 프로젝트를 사용할 경우 팀에서 관리하는 설정을 사용합니다.

### 의존성 설치와 코드 생성

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

모델 또는 Retrofit repository의 annotation을 변경한 뒤에는 코드 생성 명령을 다시 실행합니다. 생성된 `.g.dart` 파일은 현재 저장소 관리 대상입니다.

### 실행

```bash
flutter devices
flutter run -d <device-id>
```

위치, 알림, 카메라와 사진 접근 기능은 실제 기기 권한에 영향을 받습니다. 백그라운드 위치 및 푸시 동작은 에뮬레이터보다 Android와 iOS 실제 기기에서 확인하는 것이 좋습니다.

## 딥링크

앱 내부 라우터에는 다음 초대 경로가 있습니다.

```text
/trip/invite/:tripId
/invite/:tripId
```

모바일 설정에는 `yeogiga` 커스텀 스킴이 등록되어 있습니다. 공유 기능에서 생성하는 주소는 `https://yeogiga.com/invite/...` 형식이므로, HTTPS 링크를 앱으로 직접 열려면 Android App Links, iOS Universal Links 또는 웹 리다이렉트 설정이 별도로 필요합니다. 해당 외부 설정은 현재 저장소에서 확인할 수 없습니다.

## 개발 명령

### 분석과 테스트

```bash
flutter analyze
flutter test
```

현재 `test/widget_test.dart`는 Flutter 기본 카운터 예제로 남아 있어 실제 애플리케이션을 검증하지 못합니다. Provider와 주요 사용자 흐름에 맞는 테스트로 교체해야 합니다.

### 포맷

```bash
dart format lib test
```

### Android 빌드

```bash
flutter build apk --release
flutter build appbundle --release
```

릴리스 빌드에는 `android/key.properties`와 키스토어가 필요합니다. Codemagic에서는 관련 파일을 환경 변수로 생성합니다.

### iOS 빌드

```bash
flutter build ios --release
```

iOS 빌드는 Xcode 서명, Firebase, APNs, 위치 및 백그라운드 모드 설정을 함께 확인해야 합니다.

## CI와 배포

`codemagic.yaml`은 `main` 브랜치 push 시 다음 작업을 수행합니다.

1. Android 키스토어와 `key.properties` 생성
2. Flutter 의존성 설치
3. 정적 분석
4. 테스트
5. Android App Bundle 빌드
6. Google Play 내부 테스트 트랙 배포

현재 설정은 `.env`, Firebase 설정 파일을 생성하지 않으며 App Bundle 빌드 명령이 두 번 실행됩니다. CI를 사용하기 전에 필요한 파일 주입 방식과 빌드 단계를 정리해야 합니다.

자세한 설정은 [CI.md](./CI.md)와 [CD.md](./CD.md)를 참고합니다.

## 현재 점검 사항

코드 검토에서 확인된 문제와 수정 조건은 [PROJECT_REVIEW_FINDINGS.yaml](./PROJECT_REVIEW_FINDINGS.yaml)에 정리되어 있습니다. 우선 확인할 항목은 다음과 같습니다.

- 여행 목록을 백엔드 분류 조건별로 조회하고 쿼리 단위로 상태를 분리할 것
- 로그인 직후와 앱 복원 시 여행 목록 초기화 흐름을 통일할 것
- 여행별 Provider 상태를 `tripId` 기준으로 격리할 것
- 위치 획득 실패 시 `0,0` 좌표를 전송하지 않을 것
- 초대 링크의 로그인 전후 리다이렉트 값을 전체 URI로 보존할 것
- 토큰 재발급과 FCM 등록 흐름의 경쟁 상태를 제거할 것
- 클라이언트 자산과 로그에서 비밀값과 토큰을 제거할 것
- 실제 앱 동작을 검증하는 테스트를 추가할 것

## 라이선스

비공개 프로젝트입니다. 별도 허가 없이 코드와 자산을 배포할 수 없습니다.
