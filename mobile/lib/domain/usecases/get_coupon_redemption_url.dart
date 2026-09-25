import '../repositories/coupon_repository.dart';

/// 쿠폰 입력 웹뷰 URL을 생성하는 Use Case
class GetCouponRedemptionUrl {
  final CouponRepository _couponRepository;

  GetCouponRedemptionUrl(this._couponRepository);

  /// 쿠폰 입력 페이지 URL 생성
  ///
  /// [uid]: 사용자 UID (옵션)
  /// [couponCode]: 쿠폰 코드 (옵션)
  ///
  /// Returns: 쿠폰 입력 사이트 URL
  String call({String? uid, String? couponCode}) {
    return _couponRepository.getCouponRedemptionUrl(
      uid: uid,
      couponCode: couponCode,
    );
  }
}
