# Firebase 프로젝트 설정 완벽 가이드

## 📋 사전 준비물

- Google 계정
- Node.js 설치 (Firebase CLI 사용)
- Flutter SDK 설치
- 프로젝트 루트: `C:\Users\yu\Desktop\prj\trickal_coupon`

---

## 1단계: Firebase 프로젝트 생성

### 1-1. Firebase Console 접속

브라우저에서 다음 URL 접속:
```
https://console.firebase.google.com/
```

### 1-2. 새 프로젝트 만들기

1. **"프로젝트 추가"** 또는 **"Add project"** 클릭
2. 프로젝트 이름 입력: `trickcal-coupon-notifier` (또는 원하는 이름)
3. **계속** 클릭
4. Google Analytics 사용 여부 선택 (선택사항, 추천: 사용)
   - 사용하는 경우: Analytics 계정 선택 또는 새로 생성
5. **프로젝트 만들기** 클릭
6. 프로젝트 생성 완료 대기 (약 30초~1분)

### 1-3. Firestore Database 생성

1. 왼쪽 메뉴에서 **Firestore Database** 클릭
2. **데이터베이스 만들기** 클릭
3. 보안 규칙 선택:
   - **테스트 모드로 시작** 선택 (나중에 보안 규칙 배포 예정)
4. Cloud Firestore 위치 선택:
   - 추천: **asia-northeast3 (서울)** 또는 **asia-northeast1 (도쿄)**
5. **사용 설정** 클릭

### 1-4. Cloud Messaging (FCM) 활성화

FCM은 Firebase 프로젝트 생성 시 자동으로 활성화되지만, 확인 필요:

1. 왼쪽 메뉴에서 **프로젝트 설정** (톱니바퀴 아이콘) 클릭
2. **Cloud Messaging** 탭 클릭
3. **Cloud Messaging API** 상태 확인
   - 비활성화되어 있으면 **사용 설정** 클릭

---

## 2단계: Firebase CLI 설치

### 2-1. Node.js 설치 확인

터미널에서 확인:
```bash
node --version
npm --version
```

설치되어 있지 않으면 https://nodejs.org 에서 다운로드

### 2-2. Firebase CLI 설치

```bash
npm install -g firebase-tools
```

### 2-3. Firebase CLI 로그인

```bash
firebase login
```

- 브라우저가 열리고 Google 계정 로그인 요청
- 프로젝트를 생성한 계정으로 로그인
- 터미널에 "Success!" 메시지 확인

### 2-4. Firebase CLI 로그인 확인

```bash
firebase projects:list
```

방금 생성한 프로젝트가 목록에 표시되어야 함

---

## 3단계: Firebase 프로젝트와 연결

### 3-1. .firebaserc 파일 수정

프로젝트 루트에 `.firebaserc` 파일이 있는지 확인:

```bash
cd C:\Users\yu\Desktop\prj\trickal_coupon
type .firebaserc  # Windows
# 또는
cat .firebaserc   # Git Bash/Linux
```

파일이 없으면 생성:
```bash
echo '{"projects":{"default":"trickcal-coupon-notifier"}}' > .firebaserc
```

파일 내용 확인 및 수정:
```json
{
  "projects": {
    "default": "trickcal-coupon-notifier"
  }
}
```

**주의**: `trickcal-coupon-notifier`를 실제 Firebase 프로젝트 ID로 변경해야 합니다.

**프로젝트 ID 확인 방법**:
1. Firebase Console > 프로젝트 설정
2. "프로젝트 ID" 항목 확인
3. `.firebaserc` 파일의 `default` 값을 해당 ID로 수정

---

## 4단계: FlutterFire CLI 설치 및 설정

### 4-1. FlutterFire CLI 설치

```bash
dart pub global activate flutterfire_cli
```

### 4-2. PATH 확인

FlutterFire CLI가 설치되었는지 확인:

```bash
flutterfire --version
```

**오류 발생 시**:
- Windows: `%USERPROFILE%\AppData\Local\Pub\Cache\bin`을 PATH에 추가
- Mac/Linux: `~/.pub-cache/bin`을 PATH에 추가

### 4-3. FlutterFire 설정 실행

```bash
cd mobile
flutterfire configure
```

**대화형 프롬프트**:

1. **"Select a Firebase project"**
   - 방향키로 `trickcal-coupon-notifier` 선택
   - Enter 키 누름

2. **"Which platforms should your configuration support?"**
   - 스페이스바로 다음 플랫폼 선택:
     - `[x] android` (필수)
     - `[x] ios` (iOS 빌드 시 필요)
     - `[ ] macos` (선택)
     - `[x] web` (웹 테스트 시 편리)
   - Enter 키 누름

3. **Android 앱 ID 확인**:
   - 기본값: `io.trickcal.trickcal_coupon_notifier`
   - 그대로 사용 (Enter)

4. **iOS 앱 ID 확인** (iOS 선택한 경우):
   - 기본값 그대로 사용 (Enter)

### 4-4. 생성된 파일 확인

다음 파일들이 자동 생성되어야 함:

```
mobile/
├── lib/
│   └── firebase_options.dart  ✅ 자동 생성됨!
├── android/
│   └── app/
│       └── google-services.json  ✅ 자동 생성됨!
└── ios/
    └── Runner/
        └── GoogleService-Info.plist  ✅ 자동 생성됨!
```

### 4-5. firebase_options.dart 확인

`mobile/lib/firebase_options.dart` 파일 열어서 내용 확인:

```dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      // ...
    }
  }
  // ... (Firebase 설정 값들)
}
```

이 파일이 제대로 생성되었으면 성공! ✅

---

## 5단계: main.dart 수정

### 5-1. 주석 해제

`mobile/lib/main.dart` 파일 열기:

**수정 전**:
```dart
// TODO: Firebase 설정 후 주석 해제
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  // TODO: Firebase 설정 후 주석 해제
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // FCM 초기화
  // await FcmConfig.initialize();

  runApp(const ProviderScope(child: MyApp()));
}
```

**수정 후**:
```dart
import 'firebase_options.dart';  // ✅ 주석 해제

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화
  await Firebase.initializeApp(  // ✅ 주석 해제
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FCM 초기화
  await FcmConfig.initialize();  // ✅ 주석 해제

  runApp(const ProviderScope(child: MyApp()));
}
```

---

## 6단계: Android 설정 (Android 빌드 시)

### 6-1. AndroidManifest.xml 권한 추가

파일 경로: `mobile/android/app/src/main/AndroidManifest.xml`

`<manifest>` 태그 안에 권한 추가:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- 인터넷 권한 (필수) -->
    <uses-permission android:name="android.permission.INTERNET"/>

    <!-- 알림 권한 (Android 13+에서 필수) -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <application>
        <!-- 기존 내용 유지 -->
    </application>
</manifest>
```

### 6-2. build.gradle 수정 (Android SDK 버전)

파일 경로: `mobile/android/app/build.gradle`

`defaultConfig` 섹션 확인:

```gradle
android {
    defaultConfig {
        applicationId "io.trickcal.trickcal_coupon_notifier"
        minSdkVersion 21  // Firebase 최소 요구 버전
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}
```

### 6-3. Google Services Plugin 확인

파일 경로: `mobile/android/build.gradle`

파일 끝에 다음 라인이 있는지 확인 (없으면 추가):

```gradle
dependencies {
    classpath 'com.google.gms:google-services:4.4.0'
}
```

파일 경로: `mobile/android/app/build.gradle`

파일 끝에 다음 라인이 있는지 확인 (없으면 추가):

```gradle
apply plugin: 'com.google.gms.google-services'
```

---

## 7단계: Flutter 의존성 설치

```bash
cd mobile
flutter clean
flutter pub get
```

---

## 8단계: 앱 실행 테스트

### 8-1. 웹에서 테스트 (가장 빠름)

```bash
cd mobile
flutter run -d chrome
```

### 8-2. Android 에뮬레이터에서 테스트

1. Android Studio에서 에뮬레이터 실행
2. 터미널에서:
```bash
cd mobile
flutter run
```

### 8-3. 실제 Android 기기에서 테스트

1. USB 디버깅 활성화
2. 기기 연결
3. 터미널에서:
```bash
flutter devices  # 기기 확인
flutter run
```

---

## 9단계: Firebase 연동 확인

### 9-1. 앱 실행 후 확인 사항

앱이 정상적으로 실행되면:

1. **UID 입력 화면**이 표시됨
2. UID 입력 후 "시작하기" 클릭
3. **에러 없이 홈 화면으로 이동**하면 성공!

### 9-2. Firestore 데이터 확인

Firebase Console에서:

1. **Firestore Database** 메뉴 클릭
2. `users` 컬렉션 생성 확인
3. UID를 입력한 경우, 해당 문서 확인:
   - `fcm_token`: FCM 토큰 값
   - `uid`: 입력한 UID
   - `created_at`: 생성 시간

### 9-3. FCM 토큰 확인

앱 실행 시 콘솔 로그 확인:
```
✅ FCM 초기화 완료
📱 FCM 토큰: AbCdEf1234567890...
```

---

## 10단계: Firestore 보안 규칙 배포

### 10-1. 보안 규칙 파일 확인

파일 경로: `firebase/firestore.rules`

내용 확인:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users 컬렉션: 인증된 사용자만 자신의 문서 읽기/쓰기
    match /users/{userId} {
      allow read, write: if true; // 개발 중에는 모두 허용
    }

    // Coupons 컬렉션: 모두 읽기 가능
    match /coupons/{couponId} {
      allow read: if true;
      allow write: if false; // Cloud Functions만 쓰기 가능
    }

    // Processed Feeds 컬렉션: Cloud Functions만 접근
    match /processed_feeds/{feedId} {
      allow read, write: if false;
    }
  }
}
```

### 10-2. 보안 규칙 배포

```bash
cd C:\Users\yu\Desktop\prj\trickal_coupon
firebase deploy --only firestore:rules
```

### 10-3. Firestore 인덱스 배포

```bash
firebase deploy --only firestore:indexes
```

---

## ✅ 최종 체크리스트

완료한 항목에 체크:

- [ ] Firebase 프로젝트 생성
- [ ] Firestore Database 생성
- [ ] Firebase CLI 설치 및 로그인
- [ ] `.firebaserc` 파일 수정 (프로젝트 ID)
- [ ] FlutterFire CLI 설치
- [ ] `flutterfire configure` 실행
- [ ] `firebase_options.dart` 파일 생성 확인
- [ ] `google-services.json` 파일 생성 확인 (Android)
- [ ] `main.dart` 주석 해제
- [ ] `flutter pub get` 실행
- [ ] 앱 실행 테스트
- [ ] Firestore에 데이터 저장 확인
- [ ] FCM 토큰 발급 확인
- [ ] Firestore 보안 규칙 배포

---

## 🐛 문제 해결

### 문제 1: `flutterfire: command not found`

**원인**: FlutterFire CLI가 PATH에 없음

**해결**:
```bash
# Windows (PowerShell 관리자 권한)
$env:Path += ";$env:USERPROFILE\AppData\Local\Pub\Cache\bin"

# 또는 시스템 환경 변수에 영구 추가
# 제어판 > 시스템 > 고급 시스템 설정 > 환경 변수
```

### 문제 2: `firebase_options.dart` 파일이 생성되지 않음

**원인**: FlutterFire CLI 실행 중 오류 발생

**해결**:
```bash
# Firebase 로그아웃 후 재로그인
firebase logout
firebase login

# 다시 시도
cd mobile
flutterfire configure --force
```

### 문제 3: Android 빌드 시 "google-services.json" 오류

**원인**: `google-services.json` 파일이 없거나 잘못된 위치

**해결**:
1. `mobile/android/app/google-services.json` 파일 존재 확인
2. 없으면 Firebase Console에서 수동 다운로드:
   - 프로젝트 설정 > Android 앱 > `google-services.json` 다운로드
   - `mobile/android/app/` 폴더에 복사

### 문제 4: iOS 빌드 시 "GoogleService-Info.plist" 오류

**원인**: iOS 설정 파일이 Xcode 프로젝트에 추가되지 않음

**해결**:
1. Xcode에서 `mobile/ios/Runner.xcworkspace` 열기
2. `GoogleService-Info.plist` 파일을 Runner 폴더에 드래그
3. "Copy items if needed" 체크
4. "Add to targets: Runner" 체크

### 문제 5: Firestore 권한 오류

**오류 메시지**: `PERMISSION_DENIED: Missing or insufficient permissions`

**해결**:
1. Firebase Console > Firestore Database > 규칙
2. 테스트 모드로 임시 변경:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```
3. 나중에 보안 규칙 배포로 복원

---

## 📚 참고 문서

- [FlutterFire 공식 문서](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase CLI 문서](https://firebase.google.com/docs/cli)

---

**작성일**: 2025-10-16
**다음 단계**: Cloud Functions 배포 (Backend)
