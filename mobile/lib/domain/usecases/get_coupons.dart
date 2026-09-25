import '../entities/coupon.dart';
import '../repositories/coupon_repository.dart';

/// 쿠폰 목록을 조회하는 Use Case
class GetCoupons {
  final CouponRepository _couponRepository;

  GetCoupons(this._couponRepository);

  /// 모든 쿠폰 이력 조회
  ///
  /// [limit]: 조회할 최대 개수 (기본 50개)
  ///
  /// Returns: 쿠폰 목록 (최신순)
  Future<List<Coupon>> call({int limit = 50}) async {
    return await _couponRepository.getAllCoupons(limit: limit);
  }
}
