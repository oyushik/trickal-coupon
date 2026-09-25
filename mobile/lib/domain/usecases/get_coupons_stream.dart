import '../entities/coupon.dart';
import '../repositories/coupon_repository.dart';

/// 쿠폰 실시간 스트림을 가져오는 Use Case
class GetCouponsStream {
  final CouponRepository _couponRepository;

  GetCouponsStream(this._couponRepository);

  /// 쿠폰 실시간 스트림
  ///
  /// [limit]: 조회할 최대 개수 (기본 20개)
  ///
  /// Returns: 쿠폰 목록 스트림 (최신순)
  Stream<List<Coupon>> call({int limit = 20}) {
    return _couponRepository.getCouponsStream(limit: limit);
  }
}
