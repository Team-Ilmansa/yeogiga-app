# ✅ Continuous Integration (CI)

## 🔍 개요
CI는 main 브랜치에 코드가 push될 때 자동으로 실행되는 빌드 및 테스트 프로세스입니다. 이를 통해 코드 품질을 사전에 검증할 수 있습니다.

## ⚙️ 트리거 조건
- `main` 브랜치에 push 이벤트 발생 시

## 🛠 사용 도구
- Codemagic
- Flutter
- GitHub

## 🚀 실행 순서
1. Flutter 의존성 설치 (`flutter pub get`)
2. 코드 정적 분석 (`flutter analyze`)
3. 단위 테스트 실행 (`flutter test`)
4. AAB 빌드 (실패 시 배포 중단)

## 📂 관련 파일
- `codemagic.yaml`
- `key.properties` (자동 생성됨)