import '../entities/coupon.dart';

/// 쿠폰 관련 비즈니스 로직을 담당하는 Repository 인터페이스
abstract class CouponRepository {
  // ========== 쿠폰 조회 ==========

  /// 모든 쿠폰 이력 조회 (최신순)
  Future<List<Coupon>> getAllCoupons({int limit = 50});

  /// 특정 날짜의 쿠폰 조회
  Future<List<Coupon>> getCouponsByDate(DateTime date);

  /// 특정 쿠폰 상세 조회
  Future<Coupon?> getCouponById(String feedId);

  /// 쿠폰 실시간 스트림 (최신 N개)
  Stream<List<Coupon>> getCouponsStream({int limit = 20});

  // ========== 쿠폰 등록 URL 생성 ==========

  /// 쿠폰 입력 웹뷰 URL 생성
  ///
  /// [uid]: 사용자 UID
  /// [couponCode]: 쿠폰 코드
  ///
  /// Returns: https://coupon.a.prod.service.trickcal.io/ 형태의 URL
  String getCouponRedemptionUrl({String? uid, String? couponCode});
}
