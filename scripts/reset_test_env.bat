@echo off
REM ========================================
REM 테스트 환경 초기화 스크립트
REM ========================================

echo ========================================
echo 테스트 환경 초기화 시작
echo ========================================
echo.

echo [1/3] Android 에뮬레이터 앱 제거...


cd 'C:\Users\yu\Desktop\prj\trickal_coupon\mobile'
flutter install --uninstall-only
cd 'C:\Users\yu\Desktop\prj\trickal_coupon'
firebase firestore:delete users --recursive --force
firebase firestore:delete processed_feeds --recursive --force
firebase firestore:delete coupons --recursive --force
cd 'C:\Users\yu\Desktop\prj\trickal_coupon\mobile'
flutter build apk --release && flutter install --release



echo ✅ 앱 제거 완료
echo.

echo [2/3] Firestore 데이터 정리...
cd 'C:\Users\yu\Desktop\prj\trickal_coupon'
firebase firestore:delete users --recursive --force
firebase firestore:delete processed_feeds --recursive --force
firebase firestore:delete coupons --recursive --force
echo ✅ Firestore 정리 완료
echo.

@REM echo [3/3] 앱 재설치...
@REM cd mobile
@REM flutter install
@REM echo ✅ 앱 설치 완료
@REM echo.

echo ========================================
echo ✅ 초기화 완료!
echo ========================================
echo.
echo 💡 다음 단계:
echo 1. 앱을 실행하고 UID를 등록하세요
echo 2. Firebase Console에서 FCM 토큰이 등록되었는지 확인하세요
echo 3. 테스트를 진행하세요
echo.
pause
