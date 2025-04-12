# 🚀 Continuous Deployment (CD)

## 🔍 개요
CD는 빌드 성공 후 앱을 자동으로 스토어에 배포하는 과정입니다. 현재는 Google Play 내부 테스트 트랙에 자동 업로드되도록 구성되어 있습니다.

## 📱 배포 대상
- Android AAB → Google Play 내부 테스트 트랙

## 🔐 인증 설정
- `CM_KEYSTORE` (Base64 인코딩된 서명 키)
- `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` (Google API 서비스 계정 JSON)

## ⚙️ Codemagic 설정

```yaml
publishing:
  google_play:
    credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
    track: internal
    artifact_type: aab
