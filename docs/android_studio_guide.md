# Android Studio에서 Flutter 앱 실행 가이드

## 📋 사전 준비

- Android Studio 설치 완료 ✅ (버전 2025.1.4 확인됨)
- Flutter 플러그인 설치 (아래 참고)

---

## 1단계: Flutter 플러그인 설치 확인

### 1-1. Android Studio 실행
- Android Studio 아이콘 더블클릭

### 1-2. 플러그인 확인
1. **File** > **Settings** (또는 **Ctrl + Alt + S**)
2. 왼쪽 메뉴에서 **Plugins** 클릭
3. **Installed** 탭에서 다음 확인:
   - **Flutter** 플러그인
   - **Dart** 플러그인

### 1-3. 플러그인 설치 (없는 경우)
1. **Marketplace** 탭 클릭
2. 검색창에 "Flutter" 입력
3. **Flutter** 플러그인 설치 클릭
   - Dart 플러그인도 자동으로 설치됨
4. Android Studio 재시작

---

## 2단계: 프로젝트 열기

### 2-1. 프로젝트 열기
1. Android Studio 시작 화면에서 **Open** 클릭
2. 다음 경로로 이동:
   ```
   C:\Users\yu\Desktop\prj\trickal_coupon\mobile
   ```
3. `mobile` 폴더 선택 후 **OK** 클릭

### 2-2. Pub Get 실행 (자동)
- 프로젝트가 열리면 자동으로 `flutter pub get` 실행됨
- 하단에 진행 상황 표시

---

## 3단계: 실행 기기 선택

### 3-1. 상단 툴바 확인
Android Studio 상단 툴바에서:
```
[기기 선택 드롭다운] ▼  |  ▶ Run  |  🐛 Debug
```

### 3-2. 실행 가능한 기기 옵션

#### 옵션 1: Edge (웹)
- 드롭다운에서 **Edge (web)** 선택
- 가장 빠르게 테스트 가능

#### 옵션 2: Android 에뮬레이터
1. 드롭다운 클릭
2. **Open Android AVD Manager** 선택
3. 에뮬레이터 생성 또는 기존 에뮬레이터 선택
4. ▶ 버튼 클릭하여 에뮬레이터 실행
5. 에뮬레이터 실행 후 드롭다운에서 선택

#### 옵션 3: 실제 Android 기기
1. USB 디버깅 활성화
   - 개발자 옵션 > USB 디버깅 ON
2. USB로 기기 연결
3. "이 컴퓨터를 항상 허용" 체크
4. 드롭다운에서 기기 선택

---

## 4단계: 앱 실행

### 4-1. Run (일반 실행)
- 상단 툴바에서 **▶ Run** 버튼 클릭
- 또는 **Shift + F10**

### 4-2. Debug (디버그 모드)
- 상단 툴바에서 **🐛 Debug** 버튼 클릭
- 또는 **Shift + F9**
- 브레이크포인트 설정 가능

### 4-3. Hot Reload 사용
앱 실행 중 코드 수정 시:
- **Hot Reload**: `r` 키 또는 번개 아이콘 ⚡
- **Hot Restart**: `R` 키 또는 새로고침 아이콘 🔄

---

## 5단계: 실행 확인

### 5-1. Run 탭 확인
- 하단 **Run** 탭에서 로그 확인
- Firebase 초기화 메시지 확인:
  ```
  ✅ FCM 초기화 완료
  📱 FCM 토큰: ...
  ```

### 5-2. 앱 화면 확인
- UID 입력 화면이 표시되어야 함

---

## 🎯 추천 실행 방법

### 개발 중: Edge (웹)
- **장점**: 빠른 시작, Hot Reload 빠름
- **단점**: FCM 일부 기능 제한

### 실제 테스트: Android 에뮬레이터
- **장점**: 실제 기기와 유사한 환경
- **단점**: 에뮬레이터 시작 시간 필요

### 최종 테스트: 실제 기기
- **장점**: 실제 사용 환경, FCM 완전 테스트
- **단점**: USB 연결 필요

---

## 🛠️ Android 에뮬레이터 생성 (처음 사용 시)

### AVD Manager에서 생성
1. Android Studio 상단: **Tools** > **Device Manager**
2. **Create Device** 클릭
3. 기기 선택:
   - 추천: **Pixel 8** 또는 **Pixel 7**
4. 시스템 이미지 선택:
   - 추천: **Android 14 (API 34)** - Google APIs
   - Download 클릭 (첫 실행 시)
5. AVD Name 입력: `Pixel_8_API_34`
6. **Finish** 클릭

---

## 📱 실행 시 주의사항

### Android 라이선스 문제
첫 실행 시 라이선스 오류가 발생하면:

**PowerShell에서 실행**:
```powershell
flutter doctor --android-licenses
```
- 모든 라이선스에 `y` 입력

### Gradle 빌드 시간
- Android 첫 빌드는 5~10분 소요 가능
- 이후 빌드는 훨씬 빠름

---

## 🔍 문제 해결

### 문제 1: "No devices found"
**해결**:
1. Edge 선택: 드롭다운 > **Edge (web)**
2. 에뮬레이터 실행 후 재선택

### 문제 2: "Gradle build failed"
**해결**:
```bash
cd C:\Users\yu\Desktop\prj\trickal_coupon\mobile\android
.\gradlew clean
```

### 문제 3: Flutter 플러그인이 인식 안 됨
**해결**:
1. **File** > **Invalidate Caches**
2. **Invalidate and Restart** 클릭

---

## ⚡ 단축키 모음

| 기능 | 단축키 |
|------|--------|
| Run | `Shift + F10` |
| Debug | `Shift + F9` |
| Stop | `Ctrl + F2` |
| Hot Reload | `Ctrl + \` (백슬래시) |
| Hot Restart | `Ctrl + Shift + \` |
| Find Action | `Ctrl + Shift + A` |

---

## 📊 Android Studio vs VS Code

| 기능 | Android Studio | VS Code |
|------|----------------|---------|
| Flutter 지원 | ✅ 완벽 | ✅ 완벽 |
| 에뮬레이터 관리 | ✅ 내장 | ⚠️ 별도 실행 |
| 무게 | ⚠️ 무거움 | ✅ 가벼움 |
| Android 네이티브 코드 | ✅ 최적 | ⚠️ 제한적 |

---

**작성일**: 2025-10-16
**다음 단계**: 앱 실행 후 UID 입력 테스트
