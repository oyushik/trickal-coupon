# Firebase Functions 배포 가이드

## 1. 사전 준비

### Firebase 프로젝트 생성
1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. 새 프로젝트 생성
3. 프로젝트 ID 확인 (예: `trickcal-coupon-notifier`)

### Firebase CLI 설치
```bash
npm install -g firebase-tools
```

### Firebase 로그인
```bash
firebase login
```

## 2. 프로젝트 설정

### .firebaserc 파일 수정
```bash
# 프로젝트 루트에서
nano .firebaserc
```

`your-project-id`를 실제 Firebase 프로젝트 ID로 변경:
```json
{
  "projects": {
    "default": "trickcal-coupon-notifier"
  }
}
```

## 3. Firestore 보안 규칙 배포

```bash
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
```

## 4. Cloud Functions 배포

### Python 환경 확인
```bash
cd functions
python --version  # Python 3.11 이상 필요
```

### 의존성 확인
`functions/requirements.txt` 파일이 올바른지 확인

### Functions 배포
```bash
# 프로젝트 루트에서
firebase deploy --only functions
```

배포 후 자동으로 생성되는 함수:
- `scheduled_coupon_scraper`: 1분마다 자동 실행
- `manual_coupon_scraper`: HTTP 엔드포인트 (수동 테스트용)

## 5. Cloud Scheduler 설정 확인

### Scheduler 확인
1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. Cloud Scheduler 페이지로 이동
3. `scheduled_coupon_scraper` 작업이 생성되었는지 확인
4. 스케줄: `every 1 minutes` (매분 실행)

### 타임존 설정 (선택사항)
기본적으로 UTC 기준으로 실행됩니다. 한국 시간으로 변경하려면:
```bash
gcloud scheduler jobs update pubsub scheduled_coupon_scraper \
  --time-zone="Asia/Seoul"
```

## 6. 수동 테스트

### HTTP 엔드포인트로 테스트
배포 후 출력되는 URL로 접속:
```bash
curl https://REGION-PROJECT_ID.cloudfunctions.net/manual_coupon_scraper
```

또는 Firebase Console에서:
1. Functions > manual_coupon_scraper 선택
2. "트리거" 탭에서 URL 확인
3. 브라우저에서 해당 URL 접속

## 7. 로그 확인

### Firebase Console에서 로그 확인
```bash
firebase functions:log
```

또는:
1. [Firebase Console](https://console.firebase.google.com/) 접속
2. Functions 섹션으로 이동
3. 함수 선택 > 로그 탭

### 실시간 로그 스트리밍
```bash
firebase functions:log --only scheduled_coupon_scraper
```

## 8. 환경 변수 설정 (선택사항)

민감한 정보를 환경 변수로 관리:
```bash
firebase functions:config:set scraping.interval="1"
firebase functions:config:set notification.enabled="true"
```

## 9. 배포 문제 해결

### 배포 실패 시
```bash
# 상세 로그 확인
firebase deploy --only functions --debug

# 특정 함수만 재배포
firebase deploy --only functions:scheduled_coupon_scraper
```

### 권한 오류 시
Google Cloud Console에서 다음 API 활성화:
- Cloud Functions API
- Cloud Scheduler API
- Cloud Firestore API
- Firebase Cloud Messaging API

## 10. 비용 관리

### 무료 할당량 (Blaze 플랜 기준)
- Cloud Functions: 월 200만 호출
- Firestore: 읽기 5만건, 쓰기 2만건, 삭제 2만건
- Cloud Scheduler: 월 3개 작업 무료

### 예상 비용 (1분마다 실행 시)
- 호출 횟수: 약 43,200회/월 (1분 × 60 × 24 × 30)
- **무료 할당량 내 충분히 사용 가능**

### 비용 모니터링
1. [Google Cloud Console](https://console.cloud.google.com/) 접속
2. 결제 > 예산 및 알림 설정

## 11. 업데이트 배포

코드 수정 후 재배포:
```bash
# Functions만 재배포
firebase deploy --only functions

# 전체 재배포
firebase deploy
```

## 12. 배포 체크리스트

- [ ] Firebase 프로젝트 생성 완료
- [ ] `.firebaserc` 파일 프로젝트 ID 수정
- [ ] Firestore 규칙 배포
- [ ] Cloud Functions 배포 성공
- [ ] Cloud Scheduler 작업 생성 확인
- [ ] 수동 테스트 (HTTP 엔드포인트) 성공
- [ ] 로그에서 정상 실행 확인
- [ ] FCM 토큰 등록 확인 (Flutter 앱 연동 후)

## 다음 단계

Flutter 앱을 개발하여 FCM 토큰을 Firestore에 등록하면, 자동으로 푸시 알림이 전송됩니다!
