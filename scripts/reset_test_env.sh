#!/bin/bash

# ========================================
# 테스트 환경 초기화 스크립트 (Linux/Mac)
# ========================================

echo "[1/3] Android 에뮬레이터 앱 데이터 초기화..."
echo ""

# 앱 데이터 삭제 (Android KeyStore, SharedPreferences 등 모두 삭제)
adb shell pm clear com.example.trickcal_coupon_notifier

echo ""
echo "[2/3] 앱 재설치..."
cd ../mobile
flutter install

echo ""
echo "[3/3] Firestore 데이터 정리 안내"
echo "Firebase Console에서 수동으로 정리하세요:"
echo "1. https://console.firebase.google.com/project/trickcal-coupon-notifier/firestore"
echo "2. users 컬렉션의 모든 문서 삭제"
echo "3. processed_feeds 컬렉션의 20251013 관련 문서 삭제"
echo ""

echo "========================================"
echo "초기화 완료!"
echo "========================================"
