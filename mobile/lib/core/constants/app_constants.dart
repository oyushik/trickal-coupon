/// 앱 전역 상수
class AppConstants {
  // ========== 앱 정보 ==========
  static const String appName = '쿠폰스탕스';
  static const String appVersion = '1.0.0';
  static const String organizationId = 'io.trickcal';
  static const String packageName = 'trickcal_coupon_notifier';

  // ========== URL ==========
  static const String couponRedemptionUrl =
      'https://coupon.a.prod.service.trickcal.io/';
  static const String naverLoungeUrl =
      'https://game.naver.com/lounge/Trickcal/board/31';

  // ========== Firestore 컬렉션 이름 ==========
  static const String usersCollection = 'users';
  static const String couponsCollection = 'coupons';
  static const String processedFeedsCollection = 'processed_feeds';

  // ========== 로컬 저장소 키 ==========
  static const String uidStorageKey = 'user_uid';
  static const String themeKey = 'theme_mode';
  static const String firstLaunchKey = 'is_first_launch';
  static const String notificationEnabledKey = 'notification_enabled';

  // ========== JavaScript 자동 입력 ==========
  static const String userIdInputId = 'UserId';
  static const String couponCodeInputId = 'CouponCode';

  // ========== 기타 설정 ==========
  static const int defaultCouponLimit = 50;
  static const int streamCouponLimit = 20;
  static const Duration splashDuration = Duration(seconds: 2);

  // Private constructor to prevent instantiation
  AppConstants._();
}
